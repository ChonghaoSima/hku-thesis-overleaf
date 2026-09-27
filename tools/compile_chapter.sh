#!/usr/bin/env bash
# Compile one chapter on its own, with the full thesis preamble.
#   tools/compile_chapter.sh <key>        e.g. tools/compile_chapter.sh occnet
# Reads ch-<key>/<key>.tex, ch-<key>/<key>_appendix.tex (if present) and cites
# from references.bib plus ch-<key>/<key>.bib (if present).
# Output goes to build/chapters/<key>/ so several chapters can compile in parallel.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

key="${1:?usage: tools/compile_chapter.sh <key>}"
out="build/chapters/$key"
mkdir -p "$out"
root="$out/test_$key.tex"

bibs="references"
[ -f "ch-$key/$key.bib" ] && bibs="$bibs,ch-$key/$key"
appendix=""
[ -f "ch-$key/${key}_appendix.tex" ] && appendix="\\appendix\\input{ch-$key/${key}_appendix}"

cat >"$root" <<EOF
\\let\\mypdfximage\\pdfximage
\\def\\pdfximage{\\immediate\\mypdfximage}
\\documentclass[a4paper,12pt,default,numbered,print]{Classes_final/PhDThesisPSnPDF}
\\input{Preamble_final/packages}
\\input{Preamble_final/preamble}
\\input{thesis_macros}
\\makeatletter
\\DeclareRobustCommand\\onedot{\\futurelet\\@let@token\\@onedot}
\\def\\@onedot{\\ifx\\@let@token.\\else.\\null\\fi\\xspace}
\\makeatother
\\title{Chapter test: $key}
\\author{Chonghao Sima}
\\begin{document}
\\mainmatter
\\input{ch-$key/$key}
$appendix
\\bibliographystyle{unsrtnat}
\\bibliography{$bibs}
\\end{document}
EOF

if BIBINPUTS=".:" timeout 900 latexmk -g -pdf -interaction=nonstopmode -halt-on-error \
     -outdir="$out" "$root" >"$out/latexmk.out" 2>&1; then
  status="ok"
else
  status="FAILED"
fi
log="$out/test_$key.log"
echo "compile: $status   pdf: $out/test_$key.pdf   log: $log"
grep -nE "^! |LaTeX Error|Undefined control sequence" "$log" | head -20
echo "undefined references: $(grep -cE "Reference .* undefined" "$log")"
echo "undefined citations:  $(grep -cE "Citation .* undefined" "$log")"
echo "overfull hbox > 10pt: $(grep -cE 'Overfull \\hbox \(([1-9][0-9]+(\.[0-9]+)?)pt' "$log")"
[ "$status" = "ok" ]
