#!/bin/sh -e
# This file should be put into /usr/local/bin

if [ ! -f Makefile ]; then
	echo -n "Downloading Makefile... "
	wget -q https://raw.githubusercontent.com/fclairamb/easymake/master/Makefile -O Makefile && echo "OK" || echo "FAILED"
else
	echo "Makefile already exists !"
fi

if [ ! -d src ]; then
	echo -n "Creating src... "
	mkdir -p src && echo "OK" || echo "FAILED"
else
	echo "src dir already exists !"
fi
