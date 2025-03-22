# Configuration specific to mobile workstations
{ pkgs, ... }:

{
  services.autorandr.enable = true;
  environment.systemPackages = [ pkgs.arandr ];
}
