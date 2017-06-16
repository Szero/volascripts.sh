#!/usr/bin/env bash

set -uo pipefail
IFS=$'\n\t'

VOLAUPLOAD_SH_VER=(1 2)
STUFF2VOLA_SH_VER=(1 2)
CURLBAR_VER=(1 1)


check_version() {
    local path_to_script
    local version
    # how to make stuff like that portable??
    if ! path_to_script="$(which "$1" 2>/dev/null | head -qn 1)"; then
        return 1
    fi

    if version=$(grep -oE "^$2.*" "$path_to_script"); then
            echo -n "$version" | cut -d'=' -f2
            return 0
    fi
    #return 1 if script exists but its without versioning
    return 1
}

add_path() {
if ! [[ $PATH =~ $2 ]]; then
    echo -e "\nAdding $1 to your PATH ..."
    rc="$HOME/.$(basename "$SHELL")rc"
    echo -e "export PATH=\"$PATH:$1\"" >> "$rc"
fi
}

install_volauploadsh() {
    echo -e "\nInstalling volaupload.sh ...\n"
    curl --progress-bar -L "https://rawgit.com/Szero/volascripts.sh/master/volaupload.sh" -o "$1/volaupload.sh"
    chmod a+rx "$1/volaupload.sh"
}

install_stuff2volash() {
    echo -e "\nInstalling stuff2vola.sh ...\n"
    curl --progress-bar -L "https://rawgit.com/Szero/volascripts.sh/master/stuff2vola.sh" -o "$1/stuff2vola.sh"
    chmod a+rx "$1/stuff2vola.sh"
}

install_curlbar() {
    echo -e "\nInstalling curlbar ...\n"
    curl --progress-bar -L "https://gist.githubusercontent.com/Szero/cd496ca43df4b871df75818ebcc40233/raw/68d0864421cbf7ca2dccfc4033463692bf442562/curlbar" -o "$1/curlbar"
    chmod a+rx "$1/curlbar"
}

version_check() {
    local version
    local -a ver=( "${@:3:5}" )
    if version=$(check_version "$1" "$2"); then
        if [[ $(echo "$version" | cut -d'.' -f1) -ge ${ver[0]} ]] && \
           [[ $(echo "$version" | cut -d'.' -f2) -ge ${ver[1]} ]]; then
            echo -e "\nYour $1 version is up to date!"
            return 0
        fi
    fi
    return 1

}
installing() {
    if [[ -z "$(which youtube-dl)" ]] ; then
        echo -e "\nyoutube-dl wasn't detected, installing ...\n"
        curl --progress-bar -L "https://yt-dl.org/downloads/latest/youtube-dl" -o "$1/youtube-dl"
        chmod a+rx "$1/youtube-dl"
    fi
    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]] && [[ "${BASH_VERSINFO[1]}" -ge 3 ]]; then
        if ! version_check "curlbar" "__CURLBAR_VERSION__" "${CURLBAR_VER[@]}" ; then
            install_curlbar "$1"
        fi
    else
        echo -e "\nYour bash version is incompatible with curlbar. Please install bash 4.3 or higher in order to use it.\n"
    fi
    if ! version_check "volaupload.sh" "__VOLAUPLOADSH_VERSION__" "${VOLAUPLOAD_SH_VER[@]}" ; then
        install_volauploadsh "$1"
    fi
    if ! version_check "stuff2vola.sh" "__STUFF2VOLASH_VERSION__" "${STUFF2VOLA_SH_VER[@]}" ; then
        install_stuff2volash "$1"
    fi
}

if [[ $UID -ne 0 ]]; then
    echo -e "\nInstalling volascripts locally (for current user) ..."
    dir="$HOME/.local/bin"
    regex="$HOME/\.local/bin"
else
    echo -e "\nInstalling volascripts globally (for all users) ..."
    dir="/usr/local/bin"
    regex=$dir
fi

mkdir -p "$dir"
installing "$dir"
add_path "$dir" "$regex"
echo -e "\nAll done!"
