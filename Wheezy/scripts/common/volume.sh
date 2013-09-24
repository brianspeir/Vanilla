#!/bin/bash


# Volume ------------------------------------------------------------------- #

#
echo "Zeroing out the free space."
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY
