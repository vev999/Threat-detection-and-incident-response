# Threat-detection-and-incident-response

#### Skrypt Bash automatyzujący zbieranie informacji o systemie Linux oraz generowanie przejrzystego raportu diagnostycznego.

---
#### Narzędzie agreguje dane z różnych obszarów systemu, takich jak procesy, usługi, użytkownicy, sieć, bezpieczeństwo czy logi, i zapisuje je w jednym pliku tekstowym. Raport rozpoczyna się aktualną datą oraz nazwą hosta, co ułatwia archiwizację i analizę wielu systemów.

---

## Funkcjonalności 
- zbieranie informacji o procesach (CPU, RAM, systemowe)
- lista zainstalowanych pakietów oraz ostatnich instalacji
- analiza otwartych portów i aktywnych usług
- przegląd użytkowników i uprawnień
- dostęp do historii poleceń i zadań cron
- analiza logów systemowych (SSH, vsftpd)
- informacje o kernelu i czasie działania systemu
- parametry sprzętowe (RAM, CPU, dysk)
- konfiguracja sieci
- podstawowe informacje bezpieczeństwa (iptables, SELinux, AppArmor)
---
# Wynik działania

Raport zapisywany jest w katalogu: `~/raporty/` i posiada nazwę w formacie: `raport_<hostname>_<data>.txt`


---

## Uruchomienie ##

`chmod +x raport_systemowy.sh`
`./raport_systemowy.sh`
