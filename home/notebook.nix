# Common Home-Manager configuration for mobile workstations

{ pkgs, ... }:

let
  hotplug_monitor = pkgs.writeShellApplication {
    name = "hotplug_monitor";
    runtimeInputs = with pkgs; [ dasel feh gawk gnugrep xorg.xrandr ];
    text = builtins.readFile ./bin/hotplug_monitor.sh;
  };

in
{
  # Fix screen layout on login
  xsession.windowManager.i3.config.startup = [{ command = "${hotplug_monitor}/bin/hotplug_monitor"; notification = false; }];

  home.packages = [
    hotplug_monitor
  ];
}
