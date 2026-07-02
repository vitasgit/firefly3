#!/bin/bash

# --- Конфигурация ---
DEV=/dev/sda3
MNT=/mnt/linux-backup
BACKUP_SCRIPT="/home/vitaly/firefly3/firefly-iii-backuper.sh"
DEST_DIR="$MNT/myBackup/firefly_backups"

# --- Монтирование диска ---
if mountpoint -q "$MNT"; then
    echo "Диск уже смонтирован"
else
    sudo mount "$DEV" "$MNT"
    if [ $? -ne 0 ]; then
        echo "Ошибка монтирования" >&2
        exit 1
    fi
fi

# --- Создание папки для архивов ---
mkdir -p "$DEST_DIR"

# --- Формирование имени архива с датой/временем ---
ARCHIVE_NAME="firefly-$(date +%Y%m%d_%H%M%S).tar.gz"
ARCHIVE_PATH="$DEST_DIR/$ARCHIVE_NAME"

# --- Запуск скрипта бэкапа ---
echo "Запускаем бэкап Firefly III в $ARCHIVE_PATH"
"$BACKUP_SCRIPT" backup "$ARCHIVE_PATH"   # БЕЗ no_files (бэкапим всё)

# --- Проверка результата ---
if [ $? -eq 0 ]; then
    echo "✅ Бэкап успешно создан: $ARCHIVE_PATH"
else
    echo "❌ Ошибка при выполнении бэкапа" >&2
fi

# --- Ротация старых архивов (оставляем последние 7) ---
if [ -d "$DEST_DIR" ]; then
    find "$DEST_DIR" -name "firefly-*.tar.gz" -type f -mtime +7 -delete
else
    echo "⚠️ Папка $DEST_DIR не найдена, ротация пропущена"
fi

# --- Размонтирование диска ---
sudo umount "$MNT"
if mountpoint -q "$MNT"; then
    echo "❌ Диск не размонтирован" >&2
else
    echo "✅ Диск размонтирован"
fi

