#!/bin/bash
# setup linux dependencies

set -o errexit
set -o nounset
set -o pipefail

sudo apt-get -qq update
sudo apt-get -qq install -y "vim" "git" "curl" "jq" "tree" "awscli" "tmux" "xclip" "terminator" \
                        "acpi" "xbacklight" "xautolock" \
                        "openssh-client" "openssh-server" \
                        "dmsetup"
