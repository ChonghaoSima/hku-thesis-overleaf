#!/usr/bin/env python3
"""Apply verified metadata corrections to references.bib.

    python3 tools/apply_bib_fixes.py corrections.json [more.json ...]

Each JSON file is a list of {"key": ..., "status": "fix", "corrected": {...}}.
A corrected value of null deletes the field; "entry_type" changes the entry type.
Titles are wrapped in an extra brace pair so the bibliography style keeps their case.
"""
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BIB = os.path.join(ROOT, "references.bib")


def entry_span(text, key):
    m = re.search(r"@(\w+)\s*\{\s*" + re.escape(key) + r"\s*,", text)
    if not m:
        return None
    depth, j = 0, text.find("{", m.start())
    for k in range(j, len(text)):
        depth += text[k] == "{"
        depth -= text[k] == "}"
        if depth == 0:
            return m.start(), k + 1, m.group(1)
    return None


def parse_fields(body):
    """Return an ordered list of (name, raw_value) from the text after 'key,'."""
    fields, i = [], 0
    while True:
        m = re.compile(r"\s*,?\s*([A-Za-z_\-]+)\s*=\s*").match(body, i)
        if not m:
            break
        name, j = m.group(1).lower(), m.end()
        if j < len(body) and body[j] == "{":
            depth, k = 0, j
            while k < len(body):
                depth += body[k] == "{"
                depth -= body[k] == "}"
                if depth == 0:
                    break
                k += 1
            fields.append((name, body[j:k + 1]))
            i = k + 1
        elif j < len(body) and body[j] == '"':
            k = body.find('"', j + 1)
            fields.append((name, body[j:k + 1]))
            i = k + 1
        else:
            k = j
            while k < len(body) and body[k] not in ",\n}":
                k += 1
            fields.append((name, body[j:k].strip()))
            i = k
    return fields


def main():
    text = open(BIB, encoding="utf-8").read()
    applied, missing = 0, []
    for path in sys.argv[1:]:
        for rec in json.load(open(path, encoding="utf-8")):
            if rec.get("status") != "fix" or not rec.get("corrected"):
                continue
            span = entry_span(text, rec["key"])
            if not span:
                missing.append(rec["key"])
                continue
            start, end, etype = span
            raw = text[start:end]
            body = raw[raw.find(",") + 1:-1]
            fields = dict(parse_fields(body))
            order = [name for name, _ in parse_fields(body)]
            corr = dict(rec["corrected"])
            etype = corr.pop("entry_type", None) or etype
            for name, value in corr.items():
                name = name.lower()
                if value is None:
                    fields.pop(name, None)
                    continue
                value = str(value)
                if name == "title":
                    value = "{" + value + "}"
                fields[name] = "{" + value + "}"
                if name not in order:
                    order.append(name)
            order = [n for n in order if n in fields]
            new = "@%s{%s,\n%s\n}" % (etype.lower(), rec["key"],
                                      ",\n".join("  %s = %s" % (n, fields[n]) for n in order))
            text = text[:start] + new + text[end:]
            applied += 1
    open(BIB, "w", encoding="utf-8").write(text)
    print(f"applied {applied} corrections; missing keys: {missing}")


if __name__ == "__main__":
    main()
