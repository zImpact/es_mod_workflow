# Reusable-workflow с набором линтеров и деплоем в мастерскую для модов на "Бесконечное лето"
## Проверка орфографии, возможных ошибок в коде и поиск маркеров (workflow *lint_es_mod.yml*)
Данный workflow - это переиспользуемая конфигурация GitHub-Actions, которая запускает серию проверок для модов на "Бесконечное лето". Workflow состоит из трех шагов:
1. Подготовка окружения
    * Скачивание и кэширование нужной версии Ren'Py SDK (по умолчанию указана версия 8.1.3)
    * Загрузка и распаковка "чистой версии" "Бесконечного лета" из Google Drive. Версия архива (для кэширования) и ID объекта в Google Drive задаются через входные параметры.
2. Запуск проверок (линтеров)
    * Marker Lint: проверяет мод на наличие маркеров (например **# TODO** и **# FIXME**), заданных через конфигурационный файл

    ![image](https://github.com/user-attachments/assets/fa435392-fedf-49d9-86f8-122cfd57ef09)

    * Text Lint: проверяет текст мода на орфографические, стилистические и пунктуационные ошибки

    ![image](https://github.com/user-attachments/assets/9270b1d7-48f7-4af9-a444-68970aee937b)

    * Basic Lint: встроенный линтер из Ren'Py SDK для проверки проблем с кодом

    ![image](https://github.com/user-attachments/assets/cec5be52-1a64-47dc-9a12-c539d0397550)

3. Вывод отчетов
    Отчет по каждому из шагов выводится в вкладку Actions внутри репозитория

    ![image](https://github.com/user-attachments/assets/d33160c2-3014-47d8-83ba-0f1672567b68)

## Добавление workflow *lint_es_mod.yml* к себе в репозиторий
1. Создание файла вызова workflow

В корне репозитория по пути `.github/workflows/` необходимо создать файл, например `lint.yml` со следующим содержимым:
```yml
name: Lint ES Mod

on:
  push:
    branches: main

jobs:
  lint:
    uses: zImpact/es_mod_workflow/.github/workflows/lint_es_mod.yml@v2.0.7
    with:
      project_name: "Название вашего мода"     # ОБЯЗАТЕЛЬНО: Название мода
      sdk_version: "8.1.3"                     # Можно оставить значение по умолчанию
      google_drive_id: "ВАШ_GOOGLE_DRIVE_ID"   # ID архива с игрой
      es_ver: "1"                              # Версия архива для кэширования
      grammar_check_files: "scenario/main.rpy" # Файлы или папка для text-lint
      exclusions: "exclusions.yml"             # Файл со словами исключениями
      output_type: "markdown"                  # Формат вывода отчета
      folder: "code"                           # Папка для marker-lint
      markers: "markers.yml"                   # Файл с маркерами для проверки
      run_marker_lint: true                    # Запустить проверку маркеров
      run_text_lint: true                      # Запустить текстовый линт
      run_basic_lint: true                     # Запустить базовую проверку через Ren’Py линтер
```

2. Настройка параметров
* `project_name`: название мода, будет использоваться для формирования пути, куда копируются файлы репозитория для проверки. Например, если мод лежит по пути `Everlasting Summer/game/MyMod`, то в качестве значения параметра `project_name` нужно указать `MyMod`
* `sdk_version`: версия Ren`Py SDK. По умолчанию указано значение "8.1.3"
* `google_drive_id`: ID архива с игрой на Google Drive. Можно использовать "1MM3B6VRDXJDwQphj_sWuG8AthqIu8s-y" либо указать свой
* `es_ver`: версия игры, используется для кэширования
* `grammar_check_files`: список файлов для проверки в шаге `Text Lint`. Возможные варианты:
    * Проверка одного файла
      ```yaml
        grammar_check_files: code/scenario.rpy```
    * Проверка нескольких файлов
      ```yaml
      grammar_check_files: |
          code/bsar_sotp_scenario.rpy
          code/bsar_insomnia_scenario.rpy
      ```
    * Проверка целой папки
      ```yaml
      grammar_check_files: code/scenario
      ```
* `exclusions`: путь к файлам с исключениями для проверки `Text Lint`. Файл должен быть формата `.yml`. Слова, указанные в данном файле не будут восприниматься линтеров как ошибки. Пример файла:
```yaml
words:
  - "Нит"
  - "опознаю"
  - "Ниту"
  - "Ниточнику"
  - "Пионерчика"
  - "красноволосыми"
  - "врывов"
  - "пара-тройка"
```

* `output_type`: формат вывода отчетов. Для GitHub Actions нужно оставить `markdown`, чтобы отчет автоматически скопировался в переменную окружения и вывелся в раздел `Actions`. Так же возможен вариант `console`
* `folder`: путь к папке для поиска маркеров шагом `Marker Lint`. 
* `markers`: путь к файлу с маркерами. Маркеры задаются в файле формата `.yml`. Пример файла:
```yaml
markers:
  - "# TODO"
  - "# FIXME"
```
* `run_marker_lint:`: нужно ли запускать поиск макеров (по умолчанию true)
* `run_text_lint`: нужно ли запускать линтер текста (по умолчанию true)
* `run_basic_lint`: нужно ли запускать линтер кода (по умолчанию true)  

## Деплой мода в Steam Workshop (workflow *deploy_to_steam.yml*)
Данный workflow предоставляет возможность публиковать или обновлять предмет в мастерской Steam напрямую из GitHub-репозитория.

## Добавление workflow *deploy_to_steam.yml* к себе в репозиторий
1. Создание секретов 
В настройках репозитория - `Settings -> Secrets and variables -> Actions -> Repository secrets` необходимо добавить следующие секреты:
* `STEAM_USERNAME`: логин аккаунта, с которого будет публиковаться предмет
* `STEAM_PASSWORD`: пароль от аккаунта
* `STEAM_SHARED_SECRET`: shared_secret от аккаунта, получить можно, например, используя *Steam Desktop Authenticator*

2. Создание конфига деплоя
В любом удобном месте внутри репозитория необходимо создать файл формата `.yml` со следующим содержимым:
```yaml
appid: "331470"                    # ID игры в Steam - для "Бесконечного лета" это 331470
publishedfileid: "null"            # ID мода - null или ID опубликованного предмета      
visibility: "2"                    # Видимость - 0: публичный, 1: для друзей, 2: для себя               
title: "Мой мод!"                  # Название предмета
changenote: "Добавили новый текст" # Описание изменений
previewfile: "deploy/avatar.png"   # Аватар предмета
project_name: "project"            # Название мода
exclusions:                        # Файлы, которые НЕ БУДУТ загружены в мастерскую
  - ".git"
  - ".github"
  - ".gitattributes"
  - ".vscode"
  - "scripts"
  - "steamcmd"
  - "build"
  - "README.md"
  - "deploy"

```

3. Настройка параметров
* `appid`: ID игры в Steam, предмет для которой будет загружен. Для "Бесконечного лета" нужно установить **331470**
* `publishedfileid`: ID предмета в мастерской. При первой загрузке нужно указать значение `null` для создания нового предмета. При обновлении мода, значение поля нужно поменять на ID созданного предмета, например `3418334944`
* `visibility`: видимость предмета в мастерской. 
  * **0**: для всех
  * **1**: только друзьям
  * **2**: для себя
* `title`: название предмета в мастерской
* `changenote`: описание обновления
* `previewfile`: изображение предмета
* `project_name`: название мода, будет использоваться для формирования пути, куда копируются файлы репозитория для проверки. Например, если мод лежит по пути `Everlasting Summer/game/MyMod`, то в качестве значения параметра `project_name` нужно указать `MyMod`
* `exclusions`: список файлов, которые не будут загружены в мастерскую

4. Создание файла вызова workflow
В корне репозитория по пути `.github/workflows/` необходимо создать файл, например `deploy.yml` со следующим содержимым:
```yml
name: Deploy to Steam Workshop

on:
  workflow_dispatch:

jobs:
  deploy:
    uses: zImpact/es_mod_workflow/.github/workflows/deploy_to_steam.yml@v2.0.7
    with:
      steam_config_path: "deploy/config.yml"
      lint_workflow_file: "lint.yml"
      branch: "main"
      check_lint_status: false
    secrets:
      STEAM_USERNAME: "${{ secrets.STEAM_USERNAME }}"
      STEAM_PASSWORD: "${{ secrets.STEAM_PASSWORD }}"
      STEAM_SHARED_SECRET: "${{ secrets.STEAM_SHARED_SECRET }}"
```

5. Деплой
Для деплоя необходимо перейти в раздел `Actions` репозитория, слева будет список workflow. Необходимо выбрать то название, которое было указано в `.yml` файле

# Важные особенности
1. Описание предмета, который будет загружен, берется из файла README.md в корне репозитория и конвертируется в Steam-формат с использованием библиотеки [`md2steam`](https://pypi.org/project/md2steam/1.0.1/)
2. Если workflow *deploy_to_steam* используется отдельно от *lint_es_mod*, то важно в `deploy.yml` указать значение переменной `check_lint_status` равной `false`