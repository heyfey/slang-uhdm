#!/usr/bin/env bash
# r11u8 — STATIC census of the leak shape, deliberately OVER-BROAD.
#
# slang leaks only when a macro-body LINE CONTINUATION whose backslash is
# preceded by whitespace is followed by a token that opens (or expands to a
# macro that opens) a `" stringification.  This scanner reports every file
# holding a line that ends in <whitespace>\ whose NEXT line's first token is a
# `" marker or a macro reference — a superset, so a file it does not list
# cannot leak.
for f in "$@"; do
  [ -f "$f" ] || continue
  n=$(awk '
    prev ~ /[ \t]\\[ \t\r]*$/ {
      line = $0
      sub(/^[ \t]+/, "", line)
      if (line ~ /^`"/ || line ~ /^`[A-Za-z_]/) c++
    }
    { prev = $0 }
    END { print c+0 }' "$f")
  [ "$n" -gt 0 ] && echo "$n $f"
done
exit 0
