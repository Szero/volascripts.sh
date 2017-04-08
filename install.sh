#!/usr/bin/env bash

IFS=""

add_path() {
if ! [[ $PATH =~ $1 ]]; then
    rc="$HOME/.$(basename "$SHELL")rc"
    echo -e "export PATH=\"$PATH:$1\"" >> "$rc"
fi
}

installing() {
    if ! [[ $(whereis -b youtube-dl | cut -d':' -f2) ]] ; then
        echo -e "\nyoutube-dl wasn't detected, installing ...\n"
        curl --progress-bar -L "https://yt-dl.org/downloads/latest/youtube-dl" -o "$1/youtube-dl"
        chmod a+rx "$1/youtube-dl"
    fi

    echo -e "\nInstalling volaupload.sh ...\n"
    curl --progress-bar -L "https://rawgit.com/Szero/volascripts.sh/master/volaupload.sh" -o "$1/volaupload.sh"
    chmod a+rx "$1/volaupload.sh"

    echo -e "\nInstalling vid2vola.sh ...\n"
    curl --progress-bar -L "https://rawgit.com/Szero/volascripts.sh/master/vid2vola.sh" -o "$1/vid2vola.sh"
    chmod a+rx "$1/vid2vola.sh"
}

if [[ $UID -ne 0 ]]; then
    echo "Installing volascripts locally ..."
    dir="$HOME/.local/bin"
else
    echo "Installing volascripts globally (for all users) ..."
    dir="/usr/local/bin"
fi

mkdir -p "$dir"
installing "$dir"
add_path "$dir"
echo -e "\nAll done!"
