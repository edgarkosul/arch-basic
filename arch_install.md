# Ручная установка ArchLinux

Первым делом необходимо настроить доступ к Интернет, без интернета установка Arch невозможна, так как практически все пакеты тянутся из сети.

Если компьютер физически подключен к Интернет чрез LAN разъем, то скорее всего ничего настраивать не нужно.

### Подключение к сети WI-FI

Рекомендую подключатся к wi-fi используя утилиту iwd предустановленную на Live системе загруженной со съемного носителя.

Запустить утилиту в интерактивном режиме:

```
iwctl
```

В интерактивном режиме приглашение командной строки имеет вид `[iwd]#`

Вывести список доступных команд:

```
[iwd]# help
```

Запрос названий всех  Wi-Fi устройств:

```
[iwd]# device list
```

Допустим интерфейс скорее всего имеет название `wlan0`

Сканирование всех доступных Wi-Fi  сетей:

```
[iwd]# station wlan0 scan
```

После этого можно вывести список обнаруженных сетей:

```
[iwd]# station wlan0 get-networks
```

Подключится к выбранной доступной сети следующей командой:

```
[iwd]# station wlan0 connect SSID
```

В приведенном примере SSID это имя сети. Можно вводить без кавычек, если имя не имеет пробелов. Если для подключения к сети необходим пароль, то появится соответствующий запрос.

Автоматическая установка времени службой NTP:

`timedatectl set-ntp true`

Обновить список пакетов репозитория pacman:

`pacman -Sy`

Вывести информацию о дисках и созданных на них разделах, и точке  их монтирования, для получения информации о именах дисках для дальнейшей работы с ними:

`lsblk`

Подключаем русскую раскладку, (наверное можно обойтись во время установки и без возможности набирать в консоли кириллицу):

`loadkeys ru`

Сменить шрифт в консоли, на поддерживающий кириллицу:

`setfont cyr-sun16`

Запустить утилиту для работы с диском и его разделами, открыв в программе сразу раздел на котором планировалось установить Arch Linux:

`cfdisk /dev/nvme0n1p4`

#### Дальнейшие команды объединены в скрипт `mount.sh` для удобства

С помощью утилиты `cfdisk` создать раздел на диске с типом файловая система Linux, для дальнейшего его форматирования:

`mkfs.btrfs -L "Arch Linux" /dev/nvme0n1p4`

Временно смонтировать созданный раздел в директорию /mnt для дальнейшего создания подтомов btrfs (subvolumes):

`mount /dev/nvme0n1p4 /mnt`

Перейти в смонтированную директорию:

`cd /mnt`

Создать желаемые подтома btrfs:

```bash
btrfs subvolume create @
btrfs subvolume create @.snapshots
btrfs subvolume create @home
btrfs subvolume create @log
btrfs subvolume create @pkgs
```

Перейти в домашнюю директорию
`cd`

Отмонтировать временно смонтированный раздел:
`umount /mnt`

Правильно смонтировать  корневую директорию:

```bash
mount -o noatime,space_cache=v2,compress=zstd,ssd,discard=async,subvol=@ /dev/nvme0n1p4 /mnt
```

Создать директории для точек монтирования разделов и созданных подтомов btrfs:

`mkdir -p /mnt/{boot/efi,.snapshots,home,var/log,/var/cache/pacman/pkg,win10}`

Правильно смонтировать разделы и подтома с необходимыми ключами:

```bash
mount -o noatime,space_cache=v2,compress=zstd,ssd,discard=async,subvol=@.snapshots /dev/nvme0n1p4 /mnt/.snapshots
mount -o noatime,space_cache=v2,compress=zstd,ssd,discard=async,subvol=@home /dev/nvme0n1p4 /mnt/home
mount -o noatime,space_cache=v2,compress=zstd,ssd,discard=async,subvol=@log /dev/nvme0n1p4 /mnt/var/log
mount -o noatime,space_cache=v2,compress=zstd,ssd,discard=async,subvol=@pkgs /dev/nvme0n1p4 /mnt/var/cache/pacman/pkg
mount /dev/nvme0n1p3 /mnt/win10
mount /dev/nvme0n1p1 /mnt/boot/efi
```

Установить в корневую директорию будущей операционной системы базовые и необходимые пакеты и ядро Linux:

`pacstrap /mnt base base-devel linux-zen linux-zen-headers linux-firmware  vim git intel-ucode btrfs-progs`

Генерировать файл fstab на основе уже смонтированных разделов и подтомов btrfs для автоматического монтирования разделов при загрузке системы:

`genfstab -U /mnt >> /mnt/etc/fstab`

#### конец скрипта mount.sh

Изменить текущую корневую директорию системы на корневую директорию будущей системы:
`arch-chroot /mnt`
`
Разкоментировать строки с необходимыми локациями в файле(ru_RU.UTF-8 и en_US.UTF-8):

`vim /etc/locale.gen`

Генерировать файлы локализации:

`locale-gen`

Для включения автоматического обнаружения других операционных систем следует добавить/разкоментировать  в файл `/etc/default/grub` строку:

`GRUB_DISABLE_OS_PROBER="false"`

Далее будет использован скрипт автоматической установки с публичного репозитория с GitHub:

```bash
git clone https://github.com/edgarkosul/arch-basic.git
cd arch-basic
chmod +x base-uefi.sh
cd /
./arch-basic/base-uefi.sh
```



Редактировать конфигурацию скрипта mkinitcpio создающего начальный виртуальный загрузочный диск Linux:

`vim /etc/mkinitcpio.conf`
В раздел MODULES добавить модули btrfs и nvidia:

`MODULES=(btrfs nvidia)`

Запустить скрипт генерации:
`mkinitcpio -p linux-zen`

Выйти из chroot

`exit`

Отмонтировать разделы:

`umount -R /mnt`

Перезагрузиться:

`reboot`

После презагрузки, сменить шрифт в консоли:

`setfont ter-132n`

Список доступных шрифтов (при желании там можно найти кириллический шрифт):

`cat /usr/share/kbd/consolefonts/`



