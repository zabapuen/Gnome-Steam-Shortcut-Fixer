#!/bin/bash

WATCH_DIRS=(
    "$HOME/.local/share/applications"
    "$(xdg-user-dir DESKTOP)"
)

fix_shortcut() {
    local file="$1"

    [ -f "$file" ] || return

    execLine=$(grep '^Exec=' "$file" | cut -d= -f2-)

    if [[ "$execLine" =~ rungameid/([0-9]+) ]]; then
        appId="${BASH_REMATCH[1]}"

        currentIcon=$(grep '^Icon=' "$file" | cut -d= -f2)

        if [ "$currentIcon" = "steam_icon_${appId}" ]; then
            return
        fi

        echo "Fixing $file (appid $appId)"

        sed -i "s/^Icon=.*/Icon=steam_icon_${appId}/" "$file"

        if ! grep -q "^StartupWMClass=" "$file"; then
            echo "StartupWMClass=steam_app_${appId}" >> "$file"
        fi
    fi
}

inotifywait -m -e create -e moved_to "${WATCH_DIRS[@]}" --format '%w%f' |
while read -r file
do
    if [[ "$file" == *.desktop ]]; then
        sleep 1
        fix_shortcut "$file"
    fi
done

