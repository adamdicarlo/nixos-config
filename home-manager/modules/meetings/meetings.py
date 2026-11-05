#!/usr/bin/env python3
"""Hard-to-miss meeting reminders for Sway, backed by gcalcli.

Subcommands:
  check  Fetch the agenda, cache it, and raise an alert for imminent meetings.
         Run every minute by a systemd user timer.
  bar    Print the next meeting as JSON for a Wayle custom module.
  join   Open the video link of the current (or next) meeting.
  alert  Show the modal overlay. Spawned by `check`.
"""

import argparse
import hashlib
import json
import os
import re
import subprocess
import sys
from datetime import datetime, timedelta
from pathlib import Path

LEAD = timedelta(minutes=int(os.environ.get("MEETINGS_LEAD_MINUTES", "2")))
# How late an alert may still fire, e.g. after resuming from suspend.
GRACE = timedelta(minutes=1)
# Cached agenda older than this is shown as stale in the bar.
STALE = timedelta(minutes=20)

RUNTIME_DIR = Path(os.environ.get("XDG_RUNTIME_DIR", "/tmp")) / "meetings"
STATE_DIR = Path(
    os.environ.get("XDG_STATE_HOME", Path.home() / ".local" / "state")
) / "meetings"
CACHE = RUNTIME_DIR / "agenda.json"
ALERTED = STATE_DIR / "alerted"

URL_RE = re.compile(r"https?://\S+")


def now():
    return datetime.now().astimezone()


def parse_local(date, time):
    return datetime.fromisoformat(f"{date}T{time}").astimezone()


def fetch_agenda():
    start = now() - timedelta(hours=4)
    end = now() + timedelta(days=1)
    calendar = os.environ.get("MEETINGS_CALENDAR")
    out = subprocess.run(
        [
            "gcalcli", "--nocolor", "agenda", "--tsv", "--nodeclined",
            "--details", "id", "--details", "url",
            "--details", "conference", "--details", "location",
            *(["--calendar", calendar] if calendar else []),
            start.strftime("%Y-%m-%dT%H:%M"), end.strftime("%Y-%m-%dT%H:%M"),
        ],
        check=True, capture_output=True, text=True,
    ).stdout

    lines = out.splitlines()
    if not lines:
        return []
    header = lines[0].split("\t")
    events = []
    for line in lines[1:]:
        row = dict(zip(header, line.split("\t")))
        if not row.get("start_time"):
            continue  # all-day event
        events.append({
            "id": row.get("id", ""),
            "title": row.get("title", "") or "(untitled)",
            "start": parse_local(row["start_date"], row["start_time"]).isoformat(),
            "end": parse_local(row["end_date"], row["end_time"]).isoformat(),
            "url": meeting_url(row),
        })
    events.sort(key=lambda e: e["start"])
    return events


def meeting_url(row):
    uri = row.get("conference_uri", "")
    if uri.startswith("http"):
        return uri
    if row.get("hangout_link"):
        return row["hangout_link"]
    match = URL_RE.search(row.get("location", ""))
    return match.group(0) if match else ""


def write_cache(events):
    RUNTIME_DIR.mkdir(parents=True, exist_ok=True)
    tmp = CACHE.with_suffix(".tmp")
    tmp.write_text(json.dumps({"fetched": now().isoformat(), "events": events}))
    tmp.replace(CACHE)


def read_cache():
    try:
        data = json.loads(CACHE.read_text())
    except (OSError, ValueError):
        return None, []
    events = data["events"]
    for e in events:
        e["start"] = datetime.fromisoformat(e["start"])
        e["end"] = datetime.fromisoformat(e["end"])
    return datetime.fromisoformat(data["fetched"]), events


def alert_key(event):
    return f"{event['id']}|{event['start']}"


def cmd_check(_args):
    events = fetch_agenda()
    write_cache(events)

    STATE_DIR.mkdir(parents=True, exist_ok=True)
    try:
        alerted = set(ALERTED.read_text().splitlines())
    except OSError:
        alerted = set()

    t = now()
    for event in events:
        start = datetime.fromisoformat(event["start"])
        key = alert_key(event)
        if key in alerted or not (-GRACE <= start - t <= LEAD):
            continue
        unit = "meeting-alert-" + hashlib.sha1(key.encode()).hexdigest()[:12]
        subprocess.run(
            [
                "systemd-run", "--user", "--collect", "--quiet",
                # The wrapper, not sys.argv[0], so the overlay gets its GI env.
                f"--unit={unit}", os.environ.get("MEETINGS_SELF", sys.argv[0]),
                "alert",
                "--title", event["title"], "--start", event["start"],
                "--url", event["url"],
            ],
            check=True,
        )
        alerted.add(key)
        # One overlay at a time; any other due meeting gets the next tick.
        break

    # Forget alerts for meetings that started more than a day ago.
    cutoff = t - timedelta(days=1)
    alerted = {
        k for k in alerted
        if datetime.fromisoformat(k.split("|", 1)[1]) > cutoff
    }
    ALERTED.write_text("".join(f"{k}\n" for k in sorted(alerted)))


def humanize(delta):
    minutes = max(0, round(delta.total_seconds() / 60))
    if minutes < 60:
        return f"{minutes}m"
    return f"{minutes // 60}h{minutes % 60:02d}m"


def current_or_next(events, t):
    current = [e for e in events if e["start"] <= t < e["end"]]
    if current:
        # The most recently started one is most likely the one that matters.
        return current[-1]
    upcoming = [e for e in events if e["start"] > t]
    return upcoming[0] if upcoming else None


def cmd_bar(_args):
    fetched, events = read_cache()
    t = now()
    if fetched is None or t - fetched > STALE:
        print(json.dumps({
            "text": "calendar unavailable",
            "tooltip": "No fresh agenda; check `systemctl --user status meetings-check`",
            "alt": "error",
        }))
        return

    event = current_or_next(events, t)
    if event is None or event["start"].date() != t.date() and event["start"] > t:
        tooltip = f"Next: {event['start']:%a %H:%M}  {event['title']}" if event else ""
        print(json.dumps({
            "text": "No more meetings today", "tooltip": tooltip, "alt": "none",
        }))
        return

    if event["start"] <= t:
        text = f"{event['title']} now ({humanize(event['end'] - t)} left)"
        alt = "now"
    else:
        text = f"{event['title']} in {humanize(event['start'] - t)}"
        alt = "soon" if event["start"] - t <= timedelta(minutes=15) else "later"

    today = [e for e in events if e["end"] > t and e["start"].date() == t.date()]
    tooltip = "\n".join(
        f"{e['start']:%H:%M}–{e['end']:%H:%M}  {e['title']}" for e in today
    )
    print(json.dumps({"text": text, "tooltip": tooltip, "alt": alt}))


def open_url(url):
    env = dict(os.environ)
    env.pop("LD_PRELOAD", None)
    subprocess.Popen(["xdg-open", url], env=env, start_new_session=True,
                     stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def cmd_join(_args):
    _, events = read_cache()
    t = now()
    # Prefer a meeting about to start over one that is wrapping up.
    soon = [e for e in events if t < e["start"] <= t + timedelta(minutes=5)]
    event = soon[0] if soon else current_or_next(events, t)
    # Don't join tomorrow's meeting from a bar that says there are none today.
    if event and event["url"] and event["start"].date() == t.date():
        open_url(event["url"])
    else:
        open_url("https://calendar.google.com/")


def focused_output():
    try:
        outputs = json.loads(subprocess.run(
            ["swaymsg", "-t", "get_outputs"],
            check=True, capture_output=True, text=True,
        ).stdout)
    except (OSError, subprocess.CalledProcessError, ValueError):
        return None
    return next((o["name"] for o in outputs if o.get("focused")), None)


CSS = """
window.backdrop { background-color: rgba(17, 17, 27, 0.8); }
.card {
  background-color: #1e1e2e;
  border: 3px solid #f38ba8;
  border-radius: 18px;
  padding: 40px 64px;
}
.heading { color: #f38ba8; font-size: 18px; font-weight: bold; letter-spacing: 2px; }
.title { color: #cdd6f4; font-size: 34px; font-weight: bold; }
.when { color: #f9e2af; font-size: 20px; }
.card button { font-size: 18px; padding: 10px 28px; }
"""


def cmd_alert(args):
    # gtk4-layer-shell must be loaded before libwayland-client, which for
    # PyGObject means preloading it. Only this subcommand needs it.
    lib = os.environ.get("MEETINGS_LAYER_SHELL_LIB")
    if lib and lib not in os.environ.get("LD_PRELOAD", ""):
        env = dict(os.environ, LD_PRELOAD=lib)
        os.execve(sys.executable, [sys.executable, *sys.argv], env)

    import gi
    gi.require_version("Gtk", "4.0")
    gi.require_version("Gdk", "4.0")
    gi.require_version("Gtk4LayerShell", "1.0")
    from gi.repository import Gdk, Gio, GLib, Gtk
    from gi.repository import Gtk4LayerShell as LayerShell

    start = datetime.fromisoformat(args.start)
    app = Gtk.Application(
        application_id="dev.adamdicarlo.MeetingAlert",
        flags=Gio.ApplicationFlags.NON_UNIQUE,
    )

    def layer_window(monitor, keyboard):
        win = Gtk.Window(application=app, title="Meeting alert")
        LayerShell.init_for_window(win)
        LayerShell.set_namespace(win, "meeting-alert")
        LayerShell.set_layer(win, LayerShell.Layer.OVERLAY)
        LayerShell.set_monitor(win, monitor)
        for edge in (LayerShell.Edge.TOP, LayerShell.Edge.BOTTOM,
                     LayerShell.Edge.LEFT, LayerShell.Edge.RIGHT):
            LayerShell.set_anchor(win, edge, True)
        LayerShell.set_exclusive_zone(win, -1)
        LayerShell.set_keyboard_mode(win, keyboard)
        win.add_css_class("backdrop")
        return win

    def card(close):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=14,
                      halign=Gtk.Align.CENTER, valign=Gtk.Align.CENTER)
        box.add_css_class("card")

        heading = Gtk.Label(label="MEETING")
        heading.add_css_class("heading")
        title = Gtk.Label(label=args.title, wrap=True, max_width_chars=40,
                          justify=Gtk.Justification.CENTER)
        title.add_css_class("title")
        when = Gtk.Label()
        when.add_css_class("when")

        def tick():
            delta = start - now()
            secs = abs(int(delta.total_seconds()))
            mmss = f"{secs // 60}:{secs % 60:02d}"
            rel = f"starts in {mmss}" if delta.total_seconds() > 0 else f"started {mmss} ago"
            when.set_label(f"{start:%H:%M} · {rel}")
            return GLib.SOURCE_CONTINUE

        tick()
        GLib.timeout_add_seconds(1, tick)

        buttons = Gtk.Box(spacing=16, halign=Gtk.Align.CENTER, margin_top=16)
        dismiss = Gtk.Button(label="Dismiss")
        dismiss.connect("clicked", lambda _b: close())
        if args.url:
            join = Gtk.Button(label="Join")
            join.add_css_class("suggested-action")

            def on_join(_b):
                open_url(args.url)
                close()

            join.connect("clicked", on_join)
            buttons.append(join)
            default = join
        else:
            default = dismiss
        buttons.append(dismiss)

        for widget in (heading, title, when, buttons):
            box.append(widget)
        return box, default

    def activate(_app):
        provider = Gtk.CssProvider()
        provider.load_from_string(CSS)
        Gtk.StyleContext.add_provider_for_display(
            Gdk.Display.get_default(), provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION,
        )

        monitors = list(Gdk.Display.get_default().get_monitors())
        focused = focused_output()
        primary = next(
            (m for m in monitors if m.get_connector() == focused), monitors[0]
        )

        windows = []

        def close():
            for w in windows:
                w.destroy()

        for monitor in monitors:
            if monitor is primary:
                continue
            win = layer_window(monitor, LayerShell.KeyboardMode.NONE)
            windows.append(win)
            win.present()

        # Presented last so it ends up on top and holds keyboard focus.
        win = layer_window(primary, LayerShell.KeyboardMode.EXCLUSIVE)
        child, default = card(close)
        win.set_child(child)
        keys = Gtk.EventControllerKey()

        def on_key(_c, keyval, _code, _state):
            if keyval == Gdk.KEY_Escape:
                close()
                return True
            return False

        keys.connect("key-pressed", on_key)
        win.add_controller(keys)
        windows.append(win)
        win.present()
        default.grab_focus()

    app.connect("activate", activate)
    app.run([sys.argv[0]])


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest="cmd", required=True)
    sub.add_parser("check").set_defaults(func=cmd_check)
    sub.add_parser("bar").set_defaults(func=cmd_bar)
    sub.add_parser("join").set_defaults(func=cmd_join)
    alert = sub.add_parser("alert")
    alert.add_argument("--title", required=True)
    alert.add_argument("--start", required=True, help="ISO 8601 start time")
    alert.add_argument("--url", default="")
    alert.set_defaults(func=cmd_alert)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
