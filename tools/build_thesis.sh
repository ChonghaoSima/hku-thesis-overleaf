#!/usr/bin/env bash
# Build the full thesis into build/main.pdf.
#   tools/build_thesis.sh
# pdflatex writes one .aux per \include'd file under build/<dir>/, and does not
# create those directories itself, so they are created here first.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

find . -name '*.tex' -not -path './build/*' -not -path './.git/*' -printf '%h\n' \
  | sort -u | sed 's#^\.#build#' | xargs mkdir -p

if BIBINPUTS=".:" timeout 1200 latexmk -g -pdf -interaction=nonstopmode -halt-on-error \
     -outdir=build main.tex >build/latexmk.out 2>&1; then
  status="ok"
else
  status="FAILED"
fi
log="build/main.log"
echo "build: $status   pdf: build/main.pdf   log: $log"
grep -nE "^! |LaTeX Error|Undefined control sequence" "$log" | head -20
echo "pages: $(pdfinfo build/main.pdf 2>/dev/null | awk '/^Pages/{print $2}')"
echo "undefined references: $(grep -cE "Reference .* undefined" "$log")"
echo "undefined citations:  $(grep -cE "Citation .* undefined" "$log")"
echo "overfull hbox > 10pt: $(grep -cE 'Overfull \\hbox \(([1-9][0-9]+(\.[0-9]+)?)pt' "$log")"
[ "$status" = "ok" ]
