# For some reason, when Nix' Shebang is used, the PATH variable is not populated properly
if [[ "$PATH" != *"/usr/bin"* ]]; then
  export PATH="${PATH}:/usr/local/sbin:/usr/local/bin:/usr/bin"
fi

### Configuration
INTERNAL="eDP1"

# Redirect output to journalctl
exec &> >(logger -t hotplug_monitor)
set -x

#
# Environment Detection
#
 
# Detect some required stuff. Expects $USER to be set
HOME="${HOME:-"/home/${USER}"}"
DISPLAY="${DISPLAY:-:0}"
if [ -z "${XAUTHORITY:-}" ]; then
  XAUTHORITY="$(find /tmp -maxdepth 1 -name 'xauth_*' -type f -user "$USER" | head -1)"
fi

if [ -z "$XAUTHORITY" ]; then
  # Assuming X server was not started yet, exiting
  exit
fi

export HOME DISPLAY XAUTHORITY

#
# Helper functions
#

# Set the terminal font size to the specified value
function set_font_size() {
  dasel put -f "${HOME}/.config/alacritty/alacritty.toml" -t int -v "$1" font.size
}

# Output some useful information
env | sort

# Get the first monitor that is NOT the built-in screen
# Sometimes it's card0, sometimes card1
MONITOR="$(grep '^connected$' /sys/class/drm/card?/*/status -l | \
  xargs -n1 dirname | \
  xargs -n1 basename | \
  cut -d- -f2- | \
  tr -d '-' |\
  grep -Ev "^(${INTERNAL}|Unknown)$" |\
  head -n1 || :)"

if [ -n "$MONITOR" ]; then
  echo -n "Waiting for $MONITOR"
  # Wait until monitor is visible in xrandr. May take some time after it is plugged in.
  while ! xrandr | grep -q "^${MONITOR} connected"; do echo -n .; sleep .1; done
  echo
  echo "Switching to external monitor $MONITOR"
  xrandr \
    --output "$MONITOR" --auto --primary \
    --output "$INTERNAL" --off
  set_font_size 11

else
  echo "Switching to internal monitor $INTERNAL"
  xrandr --output "$INTERNAL" --auto --primary
  set_font_size 9

fi

feh --bg-fill "${HOME}/Pictures/wallpaper.png"
