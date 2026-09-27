#!/usr/bin/env python3
"""Merge chapter bibliographies into references.bib and remove duplicates.

    python3 tools/merge_bib.py [extra.bib ...] [--dry-run]

Sources, in priority order: references.bib, any extra .bib files given on the
command line, then ch-*/*.bib. An entry whose key already exists is dropped.
An entry with a different key but the same normalised title as an earlier
entry is treated as a duplicate: it is dropped and every \\cite of its key in
the thesis .tex files is rewritten to the surviving key. Merged chapter .bib
files are deleted afterwards (git keeps their history).
"""
import glob
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CITE_RE = re.compile(r"(\\(?:cite|citep|citet|citeauthor|citeyear|nocite)\*?(?:\[[^\]]*\])*\{)([^}]*)(\})")


def parse_entries(text):
    """Yield (entry_type, key, raw_text) for each @entry in a BibTeX string."""
    i = 0
    while True:
        at = text.find("@", i)
        if at < 0:
            return
        brace = text.find("{", at)
        if brace < 0:
            return
        etype = text[at + 1:brace].strip().lower()
        if not re.fullmatch(r"[a-z]+", etype):
            i = at + 1
            continue
        depth, j = 0, brace
        while j < len(text):
            if text[j] == "{":
                depth += 1
            elif text[j] == "}":
                depth -= 1
                if depth == 0:
                    break
            j += 1
        raw = text[at:j + 1]
        i = j + 1
        if etype in ("comment", "preamble"):
            continue
        if etype == "string":
            yield etype, None, raw
            continue
        key = raw[brace - at + 1:].split(",", 1)[0].strip()
        yield etype, key, raw


def field(raw, name):
    m = re.search(r"\b" + name + r"\s*=\s*", raw, re.I)
    if not m:
        return ""
    j = m.end()
    if j < len(raw) and raw[j] == "{":
        depth, k = 0, j
        while k < len(raw):
            if raw[k] == "{":
                depth += 1
            elif raw[k] == "}":
                depth -= 1
                if depth == 0:
                    return raw[j + 1:k]
            k += 1
    if j < len(raw) and raw[j] == '"':
        k = raw.find('"', j + 1)
        return raw[j + 1:k]
    return raw[j:].split(",", 1)[0]


def protect_title(raw):
    """Wrap a braced title in an extra brace pair so unsrtnat keeps its case."""
    m = re.search(r"\btitle\s*=\s*\{", raw, re.I)
    if not m:
        return raw
    j = m.end() - 1
    depth, k = 0, j
    while k < len(raw):
        if raw[k] == "{":
            depth += 1
        elif raw[k] == "}":
            depth -= 1
            if depth == 0:
                break
        k += 1
    inner = raw[j + 1:k]
    if inner.startswith("{"):
        d, q = 0, 0
        for q, ch in enumerate(inner):
            d += ch == "{"
            d -= ch == "}"
            if d == 0:
                break
        if q == len(inner) - 1:
            return raw
    return raw[:j + 1] + "{" + inner + "}" + raw[k:]


def norm_title(t):
    return re.sub(r"[^a-z0-9]", "", re.sub(r"\\[a-zA-Z]+", "", t).lower())


def main():
    dry = "--dry-run" in sys.argv
    extras = [a for a in sys.argv[1:] if not a.startswith("--")]
    ref_path = os.path.join(ROOT, "references.bib")
    chapter_bibs = sorted(glob.glob(os.path.join(ROOT, "ch-*", "*.bib")))
    sources = [ref_path] + [os.path.abspath(e) for e in extras] + chapter_bibs

    kept, by_key, by_title, strings, rename = [], {}, {}, [], {}
    dropped_same_key, conflicts = 0, []
    for src in sources:
        text = open(src, encoding="utf-8", errors="replace").read()
        for etype, key, raw in parse_entries(text):
            if etype == "string":
                strings.append(raw)
                continue
            if key in by_key:
                dropped_same_key += 1
                t_old, t_new = norm_title(field(by_key[key], "title")), norm_title(field(raw, "title"))
                if t_old and t_new and t_old != t_new:
                    conflicts.append((key, os.path.relpath(src, ROOT), field(by_key[key], "title"), field(raw, "title")))
                continue
            t = norm_title(field(raw, "title"))
            if t and len(t) > 12 and t in by_title and by_title[t] != key:
                rename[key] = by_title[t]
                continue
            by_key[key] = raw
            if t:
                by_title.setdefault(t, key)
            kept.append((src, key, raw))

    # rewrite citations of duplicate keys in all thesis .tex files
    changed_files = 0
    if rename:
        for tex in glob.glob(os.path.join(ROOT, "**", "*.tex"), recursive=True):
            if "/build/" in tex:
                continue
            s = open(tex, encoding="utf-8").read()

            def fix(m):
                keys = [k.strip() for k in m.group(2).split(",")]
                out = []
                for k in keys:
                    k = rename.get(k, k)
                    if k not in out:
                        out.append(k)
                return m.group(1) + ",".join(out) + m.group(3)

            new = CITE_RE.sub(fix, s)
            if new != s:
                changed_files += 1
                if not dry:
                    open(tex, "w", encoding="utf-8").write(new)

    print(f"sources: {len(sources)}  entries kept: {len(kept)}  "
          f"same-key duplicates dropped: {dropped_same_key}  "
          f"title duplicates renamed: {len(rename)}  tex files rewritten: {changed_files}")
    for old, new in sorted(rename.items()):
        print(f"  {old} -> {new}")
    for key, src, t_old, t_new in conflicts:
        print(f"  KEY CONFLICT {key} ({src}): kept '{t_old[:60]}', dropped '{t_new[:60]}'")
    if dry:
        return

    with open(ref_path, "w", encoding="utf-8") as f:
        f.write("% Merged bibliography of the thesis (tools/merge_bib.py).\n\n")
        for s in dict.fromkeys(strings):
            f.write(s + "\n\n")
        current = None
        for src, key, raw in kept:
            if src != current:
                f.write(f"% ---- from {os.path.relpath(src, ROOT)} ----\n\n")
                current = src
            f.write(protect_title(raw.strip()) + "\n\n")
    for b in chapter_bibs:
        os.remove(b)


if __name__ == "__main__":
    main()
