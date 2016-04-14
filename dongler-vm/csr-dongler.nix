{
  dongler = {config, pkgs, ...}: {
    # Minimal install
    environment.noXlibs = true;
    services.xserver.enable = false;
    i18n.supportedLocales = [ (config.i18n.defaultLocale + "/UTF-8") ];

    #  Bluez 5
    hardware.bluetooth.enable = true;
    nixpkgs.config.packageOverrides = pkgs : {
      bluez = pkgs.bluez5;
    };

    # CLI packages
    environment.systemPackages = with pkgs; [
      bluez usbutils
    ];
  };
}
