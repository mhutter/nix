{ ... }:
{
  networking.wireguard.interfaces.rhea0 = {
    ips = [ "10.10.10.2/24" ];
    privateKeyFile = "/nix/persist/var/lib/wireguard/rhea0/private";
    peers = [
      {
        endpoint = "116.202.233.38:45516";
        allowedIPs = [ "10.10.10.1/32" ];
        publicKey = "kMkIhO73xw93VgWE6pkhYUTGx91Ptsnm+lXPrT+opTs=";
        presharedKeyFile = "/nix/persist/var/lib/wireguard/rhea0/psk";
      }
    ];
  };
}
