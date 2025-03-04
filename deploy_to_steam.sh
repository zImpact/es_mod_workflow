#!/bin/bash

STEAM_USER=$1
STEAM_PASS=$2
STEAM_2FA=$3
CONFIG_PATH=$4

if [ ! -f "$CONFIG_PATH" ]; then
  echo "Ошибка: Конфигурационный файл $CONFIG_PATH не найден!"
  exit 1
fi

if [ -f "README.MD" ]; then
  DESCRIPTION=$(sed ':a;N;$!ba;s/\n/ /g' README.MD)
else
  echo "Ошибка: README.MD не найден!"
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

if [ "$PUBLISHED_ID" = "null" ] || [ -z "$PUBLISHED_ID" ]; then
  echo "Публикуем новый элемент Workshop для appid $APPID"
  PUBLISHED_ID=0
  PREVIEWFILE=$(yq eval '.previewfile' "$CONFIG_PATH")
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
  "previewfile" "$PREVIEWFILE"
}
VDF
else
  echo "Обновляем существующий элемент Workshop с ID $PUBLISHED_ID"
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
fi

steamcmd +login "$STEAM_USER" "$STEAM_PASS" "$STEAM_2FA" \
         +workshop_build_item "$(pwd)/workshop.vdf" +quit
