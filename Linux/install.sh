#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
source lib.sh

sudo apt-get -qq update
sudo apt-get -qq install -y "vim" "git" "curl" "jq" "tree" "awscli" "tmux" "xclip" "terminator" \
                        "acpi" "ack-grep" "xbacklight" "xautolock" \
                        "openssh-client" "openssh-server" \
                        "dmsetup"
sudo dpkg-divert --local --divert /usr/bin/ack --rename --add /usr/bin/ack-grep
