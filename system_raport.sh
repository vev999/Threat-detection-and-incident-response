#!/usr/bin/env bash

set -u
set -o pipefail

REPORT_DIR="${HOME}/raporty"
TIMESTAMP="$(date '+%F_%H-%M-%S')"
HOSTNAME_FQDN="$(hostname 2>/dev/null || uname -n)"
REPORT_FILE="${REPORT_DIR}/raport_${HOSTNAME_FQDN}_${TIMESTAMP}.txt"

mkdir -p "$REPORT_DIR"

log_section() {
    local title="$1"
    {
        echo
        echo "============================================================"
        echo "$title"
        echo "============================================================"
    } >> "$REPORT_FILE"
}

run_cmd() {
    local description="$1"
    shift
    {
        echo
        echo "--- $description"
        eval "$@" 2>&1
    } >> "$REPORT_FILE"
}

run_cmd_sudo() {
    local description="$1"
    shift
    {
        echo
        echo "--- $description"
        if command -v sudo >/dev/null 2>&1; then
            sudo bash -c "$*" 2>&1
        fi
    } >> "$REPORT_FILE"
}

{
    echo "RAPORT SYSTEMOWY"
    echo "Data: $(date '+%F %T %Z')"
    echo "Host: $HOSTNAME_FQDN"
    echo "Użytkownik uruchamiający: $(whoami)"
    echo "Kernel: $(uname -r 2>/dev/null)"
} > "$REPORT_FILE"

log_section "PROCESY"
run_cmd "Procesy użytkownika kali" "ps -u kali -f"
run_cmd "Top procesów wg pamięci" "ps aux --sort=-%mem | head"
run_cmd "Top procesów wg CPU" "ps aux --sort=-%cpu | head"
run_cmd "Procesy użytkownika root" "ps -U root -f"
run_cmd "Procesy systemd" "ps -C systemd -f"
run_cmd "Procesy z PPID=1" "ps -ef | awk '\$3==1'"

log_section "APLIKACJE"
run_cmd "Lista pakietów dpkg" "dpkg -l"
run_cmd "Pakiet openssh-server" "dpkg -l | grep openssh-server"
run_cmd "Instalacja vsftpd w logach dpkg" "zgrep ' install vsftpd:' /var/log/dpkg.log*"
run_cmd "Pakiety zainstalowane w ciągu ostatnich 7 dni" \
"zgrep ' install ' /var/log/dpkg.log* | awk -v d=\"\$(date -d '7 days ago' +%F)\" '\$1 >= d'"

log_section "OTWARTE PORTY"
run_cmd_sudo "Uruchomienie usługi ssh" "systemctl start ssh"
run_cmd_sudo "Uruchomienie usługi apache2" "systemctl start apache2"
run_cmd "Nasłuchujące porty TCP/UDP" "ss -tuln"
run_cmd_sudo "Procesy używające portu 22" "lsof -i :22"

log_section "USŁUGI"
run_cmd_sudo "Uruchomienie usługi ssh" "systemctl start ssh"
run_cmd_sudo "Uruchomienie usługi apache2" "systemctl start apache2"
run_cmd "Aktywne usługi" "systemctl list-units --type=service --state=running"
run_cmd "Włączone usługi" "systemctl list-unit-files --type=service --state=enabled"

log_section "UŻYTKOWNICY"
run_cmd "Wszyscy użytkownicy z /etc/passwd" "cut -d: -f1 /etc/passwd"
run_cmd "Użytkownicy z powłoką interaktywną" "grep -E '(/bin/bash|/bin/sh|/bin/zsh)' /etc/passwd"
run_cmd "Grupa sudo" "grep sudo /etc/group"

log_section "PLIKI"
run_cmd_sudo "Pliki zmienione w /etc w ciągu 7 dni" "find /etc -type f -mtime -7"
run_cmd_sudo "Pliki większe niż 1G" "find / -type f -size +1G 2>/dev/null"

log_section "KOMENDY"
run_cmd_sudo "Historia poleceń roota" "cat /root/.zsh_history"

log_section "CRON"
run_cmd_sudo "Crontab roota" "crontab -l"

log_section "LOGI"
run_cmd_sudo "Log vsftpd" "cat /var/log/vsftpd.log"
run_cmd_sudo "Logowania Accepted dla ssh" "journalctl -u ssh | grep Accepted"

log_section "KERNEL I CZAS PRACY"
run_cmd "Wersja kernela" "uname -r"
run_cmd "Uptime" "uptime"

log_section "PARAMETRY KOMPUTERA"
run_cmd "Pamięć RAM" "free -h"
run_cmd "Liczba rdzeni CPU" "cat /proc/cpuinfo | grep 'cores'"
run_cmd "Taktowanie CPU" "cat /proc/cpuinfo | grep 'MHz'"
run_cmd "Użycie dysków" "df -h"

log_section "USTAWIENIA SIECIOWE"
run_cmd "Adresy IP i interfejsy" "ip a"
run_cmd "Konfiguracja DNS" "cat /etc/resolv.conf"
run_cmd "Sąsiedzi ARP/NDP" "ip neigh"
run_cmd "Tablica routingu" "ip route"
run_cmd "Status linków" "ip link"

log_section "BEZPIECZEŃSTWO"
run_cmd_sudo "Reguły iptables" "iptables -L"
run_cmd "SELinux status" "sestatus"
run_cmd_sudo "AppArmor status" "aa-status"

{
    echo
    echo "============================================================"
    echo "KONIEC RAPORTU"
    echo "Plik raportu: $REPORT_FILE"
    echo "============================================================"
} >> "$REPORT_FILE"

echo "Raport zapisano do: $REPORT_FILE"
