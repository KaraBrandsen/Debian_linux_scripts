#!/bin/bash

crontab -l > root_cron
echo "0 0 */12 * * /usr/bin/env figlet "$(hostname)" -w 100 | /usr/games/lolcat -f > /run/hostname_motd" >> root_cron
crontab root_cron
rm root_cron

