set -u
T=${GVFENCE68:?}
: > "$2"
find $1 -name 'slang.uhdm' 2>/dev/null | sort | while read -r f; do
  n=$("$T" "$f" 2>/dev/null | wc -l)
  [ "$n" -gt 0 ] && echo "$f $n" >> "$2"
done
echo "DBS_WITH_CELLS $(wc -l < "$2")"
