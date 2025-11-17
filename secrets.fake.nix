rec {
  user = {
    name = "";
    email = "";
    workEmail = "";
    hashedPassword = "";
  };

  rbw-settings = {
    base_url = "";
    email = user.email;
  };

  sshHosts.rhea = {
    hostname = "rhea";
    port = 22;
  };
  wg = {
    endpoint = "";
    publicKey = "";
  };
  dockerRegistryMirror = "";
  customCACertificates = [ ];
}
