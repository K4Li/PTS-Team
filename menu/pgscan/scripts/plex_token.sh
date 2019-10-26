#!/bin/sh -e
#########################################################################
# Title:         Retrieve Plex Token                                    #
# Author(s):     Werner Beroux (https://github.com/wernight)            #
# URL:           https://github.com/wernight/docker-plex-media-server   #
# Description:   Prompts for Plex login and prints Plex access token.   #
#########################################################################
#                           MIT License                                 #
#########################################################################
template=/opt/plexguide/menu/roles/plex_autoscan/templates/config.json.j2.backup
templatebackup=/opt/plexguide/menu/roles/plex_autoscan/templates/config.json.j2

PLEX_LOGIN=$(cat /var/plexguide/plex.user)
PLEX_PASSWORD=$(cat /var/plexguide/plex.pw)

curl -qu "${PLEX_LOGIN}":"${PLEX_PASSWORD}" 'https://plex.tv/users/sign_in.xml' \
    -X POST -H 'X-Plex-Device-Name: PlexMediaServer' \
    -H 'X-Plex-Provides: server' \
    -H 'X-Plex-Version: 0.9' \
    -H 'X-Plex-Platform-Version: 0.9' \
    -H 'X-Plex-Platform: xcid' \
    -H 'X-Plex-Product: Plex Media Server'\
    -H 'X-Plex-Device: Linux'\
    -H 'X-Plex-Client-Identifier: XXXX' --compressed >/tmp/plex_sign_in
X_PLEX_TOKEN=$(sed -n 's/.*<authentication-token>\(.*\)<\/authentication-token>.*/\1/p' /tmp/plex_sign_in)
if [ -z "$X_PLEX_TOKEN" ]; then
    cat /tmp/plex_sign_in
    rm -f /tmp/plex_sign_in
    >&2 echo 'Failed to retrieve the X-Plex-Token.'
    exit 1
fi
cp -r $template $templatebackup
echo $X_PLEX_TOKEN >/opt/appdata/pgscan/plex.token
sed -i 's/plex_auth_token/'$X_PLEX_TOKEN'/g' $template