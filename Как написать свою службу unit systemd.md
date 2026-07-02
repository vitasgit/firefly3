---
tags:
  - линукс
---
---

Связи:
- связь1

---

Источник:
- [ДОБАВЛЯЕМ BASH СКРИПТ В АВТОЗАГРУЗКУ SYSTEMD | УПРАВЛЕНИЕ ДЕМОНАМИ LINUX | СОЗДАНИЕ UNIT SYSTEMD - YouTube](https://www.youtube.com/watch?v=SGHjEDVhb38&t=68s)
- [GitHub - kirumipat/SYSTEMD-UNIT: Creating a Linux service with systemd](https://github.com/kirumipat/SYSTEMD-UNIT)
- https://newadmin.ru/sozdanie-prostogo-systemd-unit/

---

Ключевые идеи:
 - [[#Каталоги хранения юнитов]]
 - [[# Как написать свой юнит]]
 - [[#SELinux блокирует службу, скрипты]]

---

### Каталоги хранения юнитов

- /usr/lib/systemd/system – юниты поставляемые вместе с системой и устанавливаемыми приложениями
- /run/systemd/system – юниты созданные динамически (в рантайме)
- /etc/systemd/system – юниты системного администратора (тут и будем хранить наши)

---

### Как написать свой юнит

1) создать файл скрипта (Желательно в директории без латиницы например: /home/vitaly/)
hello.sh
первая строка должна быть #!/bin/bash 
(не `#!/usr/bin/bash`)

лучше называть с маленькой буквы

```shell
#!/bin/bash

echo "hello" >> hello.txt
date >> hello.txt
echo "" >> hello.txt  # Добавляет пустую строку

```

---

2) разрешить запуск скрипта
```shell
sudo chmod u+x hello.sh
```

---

3) Переходим в директорию с сервисами
```shell
cd /etc/systemd/system
```

4) Создаем файл юнита (службы)
```shell
sudo nano hello.service
```

---

5) Настройки юнита
```shell
[Unit]
Description=Backup files script
After=network.target

[Service]
Type=oneshot
User=root
Restart=on-failure
ExecStart=/home/vitaly/scripts/hello.sh
RemainAfterExit=yes

[Install]
WantedBy=default.target

```

Пояснения:
After – зависимость, т.е. в данном случае запускать юнит только после запуска network.target

User=vitaly - от какого пользователя запускать службу, не обязательно

Restart=on-failure -  перезапуск службы, не обязательно

ExecStart – полный путь к исполняемому файлу программы с параметрами запуска

WantedBy=default.target - указывает на каком урове запуска стартует сервис

oneshot – удобен для скриптов, которые выполняют одно задание и завершаются. При необходимости можно задать параметр RemainAfterExit=yes, чтобы systemd считал процесс активным даже после его завершения.

---

6) запускаем юнит и добавляем в автозагрузку

```shell
sudo systemctl start hello.service
sudo systemctl enable hello.service
```

---

### SELinux блокирует службу, скрипты

Ошибка:
```text
Job for hello.service failed because the control process exited with error code.
See "systemctl status hello.service" and "journalctl -xeu hello.service" for details.
```
Надо отключить SELinux или сделать так, чтобы SELinux разрешал выполнять скрипт

---

Чтобы проверить что SELinux блокирует:
```shell
sudo ausearch -m avc -ts recent # или sudo journalctl -t setroubleshoot
```

или через графический интерфейс

---

Чтобы разрешить доступ, можно создать локальный ==модуль политики==.
разрешить этот доступ сейчас, выполнив:

```shell
sudo su
ausearch -c '(hello.sh)' --raw | audit2allow -M my-hellosh
semodule -X 300 -i my-hellosh.pp
sudo systemctl daemon-reload # перегрузить службы
```

---

==или== можно установить ==правильный контекст== для SELinux (раюотает если в директории нет кириллицы)
```shell
# Установите контекст для исполняемого файла
sudo semanage fcontext -a -t bin_t "/home/vitaly/scripts/hello.sh"
sudo restorecon -v /home/vitaly/scripts/hello.sh
sudo systemctl daemon-reload  # перегрузить службы

# Проверьте контекст
ls -Z /home/vitaly/scripts/hello.sh
```