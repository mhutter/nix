{ pkgs, ... }:
let
  kill = "${pkgs.coreutils}/bin/kill";

in
{
  systemd.user.services.languagetool = {
    Unit.Description = "Languagetool HTTP server";

    Service = {
      PIDFile = "/run/language-tool.pid";
      Restart = "always";
      ExecStart = "${pkgs.languagetool}/bin/languagetool-http-server";
      ExecReload = "${kill} -HUP $MAINPID";
      ExecStop = "${kill} -QUIT $MAINPID";
    };

    Install.WantedBy = [ "default.target" ];
  };
}
