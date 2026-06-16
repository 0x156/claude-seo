#!/usr/bin/env bash
# Rilascia una modifica al plugin: alza la patch version, committa, pusha.
# Uso:
#   ./bump.sh                 → bump patch (2.2.0 → 2.2.1) + commit "release vX.Y.Z" + push
#   ./bump.sh "messaggio"     → usa il messaggio dato invece di "release vX.Y.Z"
#
# Perché serve: 'claude plugin update' nei container aggiorna SOLO se il
# numero di versione cambia. Bumpare = il segnale di "ho rilasciato qualcosa".
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

MANIFEST=".claude-plugin/plugin.json"
[ -f "$MANIFEST" ] || { echo "✗ $MANIFEST non trovato — sei nella root del plugin?"; exit 1; }

OLD=$(python3 -c "import json; print(json.load(open('$MANIFEST'))['version'])")
NEW=$(python3 -c "
v='$OLD'.split('.')
v[-1]=str(int(v[-1])+1)
print('.'.join(v))
")

# scrivi la nuova versione preservando il resto del file
python3 -c "
import json
p='$MANIFEST'
d=json.load(open(p))
d['version']='$NEW'
json.dump(d, open(p,'w'), indent=2, ensure_ascii=False)
open(p,'a').write('\n')
"

MSG="${1:-release v$NEW}"
git add "$MANIFEST"
# includi eventuali altre modifiche già in staging/working tree
git add -A
git commit -m "$MSG (v$NEW)"
echo "✓ $OLD → $NEW, commit creato. Push? [invio per pushare, Ctrl-C per annullare]"
read -r _
git push
echo "✓ pushato v$NEW"
