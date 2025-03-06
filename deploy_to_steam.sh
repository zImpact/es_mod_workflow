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
  DESCRIPTION=$(python3 -c "from md2steam import markdown_to_steam_bbcode; print(markdown_to_steam_bbcode(open('README.md').read()))")
else
  echo "Ошибка: README.md не найден!"
  exit 1
fi

PUBLISHED_ID=$(yq eval '.publishedfileid' "$CONFIG_PATH")
VISIBILITY=$(yq eval '.visibility' "$CONFIG_PATH")
TITLE=$(yq eval '.title' "$CONFIG_PATH")
CHANGE_NOTE=$(yq eval '.changenote' "$CONFIG_PATH")
APPID=$(yq eval '.appid' "$CONFIG_PATH")
PREVIEW_FILENAME_PATH=$(yq eval '.previewfile' "$CONFIG_PATH")
PREVIEW_FILE="$(pwd)/${PREVIEW_FILENAME_PATH}"
PROJECT_NAME=$(yq eval '.project_name' "$CONFIG_PATH")
EXCLUSIONS=$(yq eval '.exclusions[]' "$CONFIG_PATH")

if [ -z "$APPID" ] || [ "$APPID" = "null" ]; then
  echo "Ошибка: Steam appid не указан в $CONFIG_PATH"
  exit 1
fi

SOURCE_FOLDER="$(pwd)"
echo "Исходная директория: $SOURCE_FOLDER"
echo "Содержимое исходной директории:"
ls -la "$SOURCE_FOLDER"

RSYNC_EXCLUDES=""
for pattern in $EXCLUSIONS; do
  RSYNC_EXCLUDES+=" --exclude=${pattern}"
done
RSYNC_EXCLUDES+=" --exclude=${PROJECT_NAME}"
RSYNC_EXCLUDES+=" --exclude=build"
echo "Исключения для rsync: ${RSYNC_EXCLUDES}"

BUILD_PARENT="${SOURCE_FOLDER}/build"
BUILD_FOLDER="${BUILD_PARENT}/${PROJECT_NAME}"

echo "Подготавливаем папку сборки: ${BUILD_FOLDER}"
rm -rf "$BUILD_FOLDER"
mkdir -p "$BUILD_FOLDER"

rsync -av $RSYNC_EXCLUDES "${SOURCE_FOLDER}/" "$BUILD_FOLDER/"

echo "Содержимое папки сборки ($BUILD_FOLDER):"
ls -la "$BUILD_FOLDER"

CONTENT_FOLDER="$BUILD_FOLDER"

if [ "$PUBLISHED_ID" = "null" ] || [ -z "$PUBLISHED_ID" ]; then
  echo "Публикуем новый элемент Workshop для appid $APPID"
  PUBLISHED_ID=0
else
  echo "Обновляем существующий элемент Workshop с ID $PUBLISHED_ID"
fi

cat > workshop.vdf <<VDF
"workshopitem"
{
  "appid" "$APPID"
  "publishedfileid" "$PUBLISHED_ID"
  "contentfolder" "$BUILD_PARENT"
  "visibility" "$VISIBILITY"
  "title" "$TITLE"
  "description" "$DESCRIPTION"
  "changenote" "$CHANGE_NOTE"
  "previewfile" "$PREVIEW_FILE"
}
VDF

echo "Вывод workshop.vdf для дебага:"
cat workshop.vdf

steamcmd +login "$STEAM_USER" "$STEAM_PASS" "$STEAM_2FA" \
         +workshop_build_item "$(pwd)/workshop.vdf" +quit
