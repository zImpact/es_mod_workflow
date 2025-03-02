#!/bin/bash

STEAM_USER=$1
STEAM_PASS=$2
STEAM_2FA=$3
CONFIG_PATH=$4  # Путь к конфигу, переданный в workflow

if [ ! -f "$CONFIG_PATH" ]; then
  echo "Error: Config file $CONFIG_PATH not found!"
  exit 1
fi

PUBLISHED_ID=$(jq -r '.publishedfileid' "$CONFIG_PATH")
VISIBILITY=$(jq -r '.visibility' "$CONFIG_PATH")
TITLE=$(jq -r '.title' "$CONFIG_PATH")
DESCRIPTION=$(jq -r '.description' "$CONFIG_PATH")
CHANGE_NOTE=$(jq -r '.changenote' "$CONFIG_PATH")
APPID=$(jq -r '.appid' "$CONFIG_PATH")

if [ -z "$APPID" ] || [ "$APPID" = "null" ]; then
  echo "Error: Steam appid not specified in $CONFIG_PATH"
  exit 1
fi

if [ "$PUBLISHED_ID" = "null" ] || [ -z "$PUBLISHED_ID" ]; then
  echo "Publishing **new** workshop item for appid $APPID"
  PUBLISHED_ID=0
else
  echo "Updating **existing** workshop item ID $PUBLISHED_ID"
fi

cat > workshop.vdf <<VDF
"workshopitem"
{
  "appid" "$APPID"
  "publishedfileid" "$PUBLISHED_ID"
  "contentfolder" "$(pwd)"
  "visibility" "$VISIBILITY"
  "title" "$TITLE"
  "description" "$DESCRIPTION"
  "changenote" "$CHANGE_NOTE"
}
VDF

steamcmd +login "$STEAM_USER" "$STEAM_PASS" "$STEAM_2FA" \
         +workshop_build_item "$(pwd)/workshop.vdf" +quit