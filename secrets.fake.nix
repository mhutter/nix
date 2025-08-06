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

  sshHosts = { };
  wg = {
    endpoint = "";
    publicKey = "";
  };
  dockerRegistryMirror = "";
  customCACertificates = [ ];
}
