{ secrets, ... }:
{
  networking.wg-quick.interfaces = secrets.wg-quick.interfaces;
}
