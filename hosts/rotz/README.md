# System-specific Instructions

## Mobile Broadband Setup

Due to a bug in `nm-applet`, it will crash when trying to prompt for a PIN, so some extra steps are required:

```sh
# nmcli won't auto-start the ModemManager service
sudo systemctl start ModemManager.service

# Print details about modem:
mmcli -m 0
# It will likely say "lock: sim-pin"

# Unlock and remove the PIN:

mmcli --sim=0 --pin=**** --disable-pin

# Now you should be able to configure the wwan connection.
# Select "Swisscom GPRS"
```
