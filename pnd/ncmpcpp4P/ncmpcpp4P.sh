#!/bin/sh

# We don't want to let the program write its configuration, savestates
# etc. to the NAND.  So we need to export our HOME environment
# variable first.
export HOME=./

# There may be libs, that the program needs and that are not on the
# NAND by default.  So we need to export the LD_LIBRARY_PATH
# environment variable to point to the libs we will package into our
# pnd.
export LD_LIBRARY_PATH=LD_LIBRARY_PATH:./lib

# Discover the current path
curr_path=`cd ./; pwd`

# Compose a sed pattern
sed_pattern=`printf "s@~/@${curr_path}/@"`

# Create the directory structure
mkdir music
mkdir playlists
mkdir .ncmpcpp

# Generate an mpd.conf from the template if it doesn't exist
if [[ ! -f mpd.conf ]]; then
    sed -e $sed_pattern mpd.conf.template > mpd.conf
fi

# Emerge terminal.opts config file
if [[ ! -f terminal.opts ]]; then
    cp terminal.opts.template terminal.opts
fi

# Emerge ncmpcpp config files in the appdata folder
if [[ ! -f .ncmpcpp/config ]]; then
    cp config.template .ncmpcpp/config
fi
if [[ ! -f .ncmpcpp/keys ]]; then
    cp keys.template .ncmpcpp/keys
fi

# Now we need to launch both mpd and ncmpcpp but before we kill all
# previous mpd instances
killall -9 mpd

# Start mpd
./bin/mpd --verbose --create-db --stdout mpd.conf

# Start a terminal running ncmpcpp
/usr/bin/terminal `cat terminal.opts` -x $curr_path/bin/ncmpcpp4P

# Kill the mpd daemon on exit
kill `cat pid`




