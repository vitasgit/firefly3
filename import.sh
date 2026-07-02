#!/bin/bash

# --- НАСТРОЙКИ ---
CONTAINER="firefly_iii_importer"
CSV_DIR="/home/vitaly/firefly3/транзакции"
CONFIG_DIR="/home/vitaly/firefly3/шаблоны"
ARCHIVE_DIR="$CSV_DIR/archive"

# шаблон для кредитной карты (как пример)
# TEMPLATE_FILE="tbank_credit_template.json"
# ВАЖНО: для fedora нужно учитывать SElinux, по-умолчанию он не дает докеру доступ к пользовательским каталогом. Это можно исправить, добавив суффик :z - /home/vitaly/Документы/firefly3/шаблоны:/data/configs:z
CREDIT_TEMPLATE="tbank-credit.json"


# Создаем папку для архива, если её нет
mkdir -p "$ARCHIVE_DIR"

echo "импорт: $CSV_DIR"
echo "----------------------------------------"

# Если скрипту передали конкретный файл (например: ./import-firefly.sh file.csv), берем его
if [ "$#" -gt 0 ]; then
    files=("$CSV_DIR/$1")
else
    # Иначе берем все CSV файлы из папки
    files=("$CSV_DIR"/*.csv)
fi

# Перебираем файлы
for file in "${files[@]}"; do
    # Проверяем, существует ли файл (защита от пустой папки)
    [ -e "$file" ] || continue

    filename=$(basename "$file")
    echo "импорт: $filename"

    # Автоматически назначаем файлу правильную метку безопасности для Docker
    # Это исправляет ошибку Permission denied для файлов, скачанных из браузера
    chcon -t container_file_t "$file" 2>/dev/null

    # Запускаем CLI импорт внутри контейнера
    # volumes(директории) берем из файла docker-compose.yml. В файле(docker-compose.yml) они уже должны быть заранее записаны
    # так же, нужно установить переменную окружения (docker-compose.yml) importer: IMPORT_DIR_ALLOWLIST=/your/directory
    # подробнее можно прочитать в доке firefly3
    #docker exec "$CONTAINER" php artisan importer:import "/data/configs/$CREDIT_TEMPLATE" "/data/transactions/$filename"
    output=$(docker exec "$CONTAINER" php artisan importer:import "/data/configs/$CREDIT_TEMPLATE" "/data/transactions/$filename" 2>&1)
    echo "$output"

    # Проверяем результат
    if echo "$output" | grep -q "Done!"; then
        mv "$file" "$ARCHIVE_DIR/"
        echo "✅ ОК. Файл обработан и перемещен в архив."
    else
        echo "❌ Критическая ошибка при импорте. Файл оставлен в папке транзакции."
    fi
    echo "----------------------------------------"
done

