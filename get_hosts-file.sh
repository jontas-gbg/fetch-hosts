#!/bin/bash

#
# Använder Peter Lows blacklist hosts fil (https://github.com/pgl)
# och Frellwit's svenska hostsfile (https://github.com/lassekongo83)
#
# De båda hosts-filerna slås ihop till en.
# Körs som en systemd-timer en gång per vecka
# Skriver till en egen logfil för snabb åtkomst initalt.
# (Lokal logfil kan skippas till förmån för journalctl)
#
# At your service, jontas@gmx.com
#

# Konstanter för sökvägar
AD_BLOCK_HOSTS_URL="https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext"
FRELLWITS_HOSTS_URL="https://raw.githubusercontent.com/lassekongo83/Frellwits-filter-lists/master/Frellwits-Swedish-Hosts-File.txt"
CACHE_FILE1="/tmp/adblock_hosts.txt"
CACHE_FILE2="/tmp/frellwits_hosts.txt"
TEMP_FILE="/tmp/combined_hosts.txt"
TARGET_FILE="/etc/hosts"
LOG_DIR="$HOME/.logs"
LOG_FILE="$LOG_DIR/hosts_update.log"

# Skapa ~/.logs om den inte finns
mkdir -p "$LOG_DIR"

# FuEnkel funktion för loggning
log() {
  echo "$(date +%s) $1" >> "$LOG_FILE"
}

# Hämta båda filerna med timeout och kontrollera HTTP-status
curl -s -m 10 "$AD_BLOCK_HOSTS_URL" -o "$CACHE_FILE1" || log "curl $AD_BLOCK_HOSTS_URL misslyckades: $(curl -s -m 10 "$AD_BLOCK_HOSTS_URL" 2>&1)"
curl -s -m 10 "$FRELLWITS_HOSTS_URL" -o "$CACHE_FILE2" || log "curl $FRELLWITS_HOSTS_URL misslyckades: $(curl -s -m 10 "$FRELLWITS_HOSTS_URL" 2>&1)"

# Slå samman filerna och ta bort dubbletter
cat "$CACHE_FILE1" "$CACHE_FILE2" | sort | uniq > "$TEMP_FILE"

# Dubbelkoll så att vi inte tankar ner tomma filer.
if [[ $(stat -c%s "$TEMP_FILE") -gt 100 && $(wc -l < "$TEMP_FILE") -gt 10 ]]; then
  # Kopiera filen och skriv till logfilen
  sudo cp "$TEMP_FILE" "$TARGET_FILE" && log "Hosts-filen uppdaterad: $(date +'%Y-%m-%d %H:%M:%S')" || log "Fel vid kopiering: $(date +'%Y-%m-%d %H:%M:%S')"
else
  log "Felaktig filstorlek eller antal rader: $(stat -c%s "$TEMP_FILE") bytes, $(wc -l < "$TEMP_FILE") rader"
fi

# Ta bort temporära filer
rm "$CACHE_FILE1" "$CACHE_FILE2" "$TEMP_FILE"
