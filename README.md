# firefly3
Информационная система учета личных финансов на базе Firefly III.

Хостится на docker.
БД: postgresql(16-alpine)

import.sh - скрипт для автоматического импорта CVS транзакций.
CVS транзакции берутся из лк банка. Прогоняются через [CLI Firefly III Data Importer](https://docs.firefly-iii.org/how-to/data-importer/advanced/cli/).
При успешном импорте - архивируются.


firefly-iii-backuper.sh - скрипт для бэкапа и восстановленя БД(postgresql) и окружения (docker).
Скрипт модифицирован для postgresql.
Автор скрипта dawid-czarnecki: https://gist.github.com/dawid-czarnecki/8fa3420531f88b2b2631250854e23381

firefly-backup-wrapper.sh - скрипт для автоматического выполнения бэкапа, работает в связке с соответствующей службой.
