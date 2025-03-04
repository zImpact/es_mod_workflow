#!/bin/bash

STEAM_USER=$1
STEAM_PASS=$2
STEAM_2FA=$3
CONFIG_PATH=$4

if [ ! -f "$CONFIG_PATH" ]; then
  echo "Ошибка: Конфигурационный файл $CONFIG_PATH не найден!"
  exit 1
fi

if [ -f "README.md" ]; then
  DESCRIPTION=$(sed ':a;N;$!ba;s/\n/ /g' README.md)
else
  echo "Ошибка: README.md не найден!"
  exit 1
fi

PUBLISHED_ID=$(yq eval '.publishedfileid' "$CONFIG_PATH")
VISIBILITY=$(yq eval '.visibility' "$CONFIG_PATH")
TITLE=$(yq eval '.title' "$CONFIG_PATH")
CHANGE_NOTE=$(yq eval '.changenote' "$CONFIG_PATH")
APPID=$(yq eval '.appid' "$CONFIG_PATH")

if [ -z "$APPID" ] || [ "$APPID" = "null" ]; then
  echo "Ошибка: Steam appid не указан в $CONFIG_PATH"
  exit 1
fi

CONTENT_FOLDER="$(pwd)"

if [ "$PUBLISHED_ID" = "null" ] || [ -z "$PUBLISHED_ID" ]; then
  echo "Публикуем новый элемент Workshop для appid $APPID"
  PUBLISHED_ID=0
  PREVIEW_FILENAME_PATH=$(yq eval '.previewfile' "$CONFIG_PATH")
  PREVIEW_FILE="${CONTENT_FOLDER}/${PREVIEW_FILENAME_PATH}"
  
  cat > workshop.vdf <<VDF
"workshopitem"
{
  "appid" "$APPID"
  "publishedfileid" "$PUBLISHED_ID"
  "contentfolder" "$CONTENT_FOLDER"
  "visibility" "$VISIBILITY"
  "title" "$TITLE"
  "description" "$DESCRIPTION"
  "changenote" "$CHANGE_NOTE"
  "previewfile" "$PREVIEW_FILE"
}
VDF
else
  echo "Обновляем существующий элемент Workshop с ID $PUBLISHED_ID"
  cat > workshop.vdf <<VDF
"workshopitem"
{
  "appid" "$APPID"
  "publishedfileid" "$PUBLISHED_ID"
  "contentfolder" "$CONTENT_FOLDER"
  "visibility" "$VISIBILITY"
  "title" "$TITLE"
  "description" "$DESCRIPTION"
  "changenote" "$CHANGE_NOTE"
}
VDF
fi

echo "workshop.vdf contents for debug:"
cat workshop.vdf

steamcmd +login "$STEAM_USER" "$STEAM_PASS" "$STEAM_2FA" \
         +workshop_build_item "$(pwd)/workshop.vdf" +quit
