#!/bin/bash
TRIGGER=/var/run/reboot-required
PACKAGES=/var/run/reboot-required.pkgs

if [ -e $TRIGGER ]; then
  sleep $[RANDOM%30]m;
  echo "Restarting nginx due to upgraded packages:"
  cat $PACKAGES
  service nginx stop # runit will restart
  rm $TRIGGER
  rm $PACKAGES
fi
