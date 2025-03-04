{
  config,
  inputs,
  pkgs,
  ...
}: let
  firefox-addons =
    import inputs.firefox-addons {inherit (pkgs) fetchurl lib stdenv;};
in {
  imports = [
    # ./modules/tridactyl.nix
  ];

  # cribbed and adapted from Charlotte Van Petegem's configs
  # at https://git.chvp.be/chvp/nixos-config
  programs.firefox = {
    enable = true;
    package = pkgs.firefox.override {
      pkcs11Modules = [];
      extraPolicies = {
        DisableFirefoxAccounts = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        FirefoxHome = {
          Pocket = false;
          Snippets = false;
        };
        OfferToSaveLogins = false;
        PasswordManagerEnabled = false;
        UserMessaging = {
          SkipOnboarding = true;
          ExtensionRecommendations = false;
        };
      };
    };
    # nativeMessagingHosts.ff2mpv = true;
    # nativeMessagingHosts.tridactyl = true;
    nativeMessagingHosts = [
      pkgs.ff2mpv
      pkgs.tridactyl-native
    ];
    profiles.default = {
      extensions.packages = with firefox-addons; [
        bitwarden
        decentraleyes
        don-t-fuck-with-paste
        dracula-dark-colorscheme
        facebook-container
        ff2mpv
        # tree-style-tab
        tridactyl
        ublock-origin
        umatrix
      ];
      search = {
        engines = {
          "Nix Packages" = {
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = ["@np"];
          };
          "Nix Options" = {
            urls = [
              {
                template = "https://search.nixos.org/options";
                params = [
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = ["@no"];
          };
          Bing.metaData.hidden = true;
          Google.metaData.alias = "@g";
        };
        force = true;
        order = ["DuckDuckGo" "Google"];
      };
      settings = {
        "app.shield.optoutstudies.enabled" = false;
        "browser.aboutConfig.showWarning" = false;
        "browser.contentblocking.category" = "custom";
        "browser.download.dir" = "${config.home.homeDirectory}/Downloads";
        "browser.newtabpage.activity-stream.feeds.recommendationprovider" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.enabled" = false;
        "browser.safebrowsing.malware.enabled" = false;
        "browser.safebrowsing.phishing.enabled" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.startup.homepage" = "about:blank";
        "browser.startup.page" = 3;
        "dom.security.https_only_mode" = true;
        "extensions.htmlaboutaddons.recommendations.enabled" = false;
        "gfx.webrender.all" = true;
        "gfx.webrender.enabled" = true;
        "layers.acceleration.force-enabled" = true;
        "network.cookie.cookieBehavior" = 1;
        "privacy.annotate_channels.strict_list.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "security.identityblock.show_extended_validation" = true;
        "svg.context-properties.content.enabled" = true;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "toolkit.telemetry.cachedClientID" = "c0ffeec0-ffee-c0ff-eec0-ffeec0ffeec0";
        "userChrome.Tabs.Option6.Enabled" = true;
      };
    };
  };
}
