#!/usr/bin/env bash
# r10buvm12repro/predict12.sh — NAME THE MOVERS BEFORE ANY BYTE IS COMPARED.
#
#   usage: predict12.sh <pristine_workdir_root> [outfile]
#
# Reads ONLY the PRISTINE databases (never the patched ones, never golden) and
# prints, straight out of the object model, every object
# § externProtoInBodyCallBinds12 can possibly touch.  `extern` / `pure virtual`
# is a slang FLAG, but it has an exact UHDM shadow -- a class_defn method
# LISTING with NO `Stmt` and either `vpiAccessType == 2` (vpiExternAcc) or
# `vpiDPIPure` -- so the prediction is readable out of a pristine database.
#
#   CAND A  a `func_call` whose nearest class_defn ancestor is class C, whose
#           enclosing method is NOT an out-of-body definition (`oob=0`), whose
#           NAME matches a PROTOTYPE listing of C ITSELF, declared ABOVE the
#           enclosing method (or the call sits in a class-PROPERTY initializer,
#           `eline=0`, where every prototype is in scope), and whose current
#           link is NOT that prototype object -> the law WILL move it.
#   CAND B  a `func_call` with NO class_defn ancestor whose name matches some
#           class prototype -> the law must NOT reach it.  A CONTROL.
#   CAND C  the CAND A shape but inside an OUT-OF-BODY definition (`oob=1`) ->
#           the law must NOT reach it.  A CONTROL: golden leaves every one of
#           these bare (`uvm_default_factory::m_matches_type_override`, all six).
#           Out-of-body-ness is read from BOTH shadows, because the ELAB view
#           MOVES the definition listing into the class_defn and the parent test
#           alone would call every ELAB out-of-body body in-body: `oob=1` (the
#           enclosing method is parented at a package) OR `emeth=0` (the
#           enclosing listing carries vpiMethod 0, which only an out-of-body
#           DEFINITION or a free function does).
#
# A run that reaches nothing must never read as perfection: databases visited
# and census failures are COUNTED, and a run that reached zero databases is
# FATAL.
set -u
W=${1:?pristine workdir root}
O=${2:-/tmp/r10buvm12_predict.txt}
CEN=/tmp/r10buvm12cen
[ -x "$CEN" ] || { echo "FATAL: no census $CEN (run build12.sh)"; exit 3; }
[ -d "$W" ] || { echo "FATAL: no workdir $W"; exit 3; }
: > "$O"
n=0; fail=0
while read -r db; do
  n=$((n+1))
  t=$(mktemp)
  if ! timeout 1800 "$CEN" "$db" X > "$t" 2>/dev/null; then fail=$((fail+1)); rm -f "$t"; continue; fi
  if grep -q '^RESTORE_FAIL' "$t"; then fail=$((fail+1)); rm -f "$t"; continue; fi
  rel=${db#"$W"/}
  awk -v rel="$rel" '
    function fld(s,k) { for(i=1;i<=NF;i++) if($i ~ ("^" k "=")) return substr($i,length(k)+2); return "" }
    $1=="PR" {
      cls=fld($0,"cls"); nme=fld($0,"name"); lc=fld($0,"loc");
      kd=fld($0,"kind"); pr=fld($0,"proto");
      if (pr=="1" && kd=="function") {
        # a class may prototype the same name once; keep the FIRST (declaration
        # order is the file order the listing is written in)
        k=cls "\034" nme; if (!(k in ploc)) { ploc[k]=lc; split(lc,z,":"); pline[k]=z[1]+0 }
      }
      if (pr=="1") anyproto[nme]=1
      next }
    $1=="TC" {
      key=fld($0,"key"); lnk=fld($0,"lnk"); tl=fld($0,"tl");
      cls=fld($0,"cls"); el=fld($0,"eline")+0; oob=fld($0,"oob");
      if (fld($0,"emeth")=="0" && el != 0) oob="1"   # an OOB definition listing
      split(key,f,"|"); kind=f[3]; nme=f[4]; sub(/@.*/,"",nme);
      if (kind != "func_call") next
      tc[++nt]=key "\034" lnk "\034" tl "\034" cls "\034" el "\034" oob "\034" nme
      next }
    END {
      for (j=1;j<=nt;j++) {
        split(tc[j],a,"\034");
        key=a[1]; lnk=a[2]; tl=a[3]; cls=a[4]; el=a[5]+0; oob=a[6]; nme=a[7];
        if (cls=="-") {
          if (nme in anyproto && lnk=="0") printf "CAND B %s %s\n", rel, key
          continue }
        k=cls "\034" nme
        if (!(k in ploc)) continue
        if (el != 0 && pline[k] >= el) continue      # prototype declared BELOW
        want="function@" ploc[k]
        if (lnk=="1" && tl==want) continue           # already the prototype
        if (oob=="1") { printf "CAND C %s %s\n", rel, key; continue }
        printf "CAND A %s %s lnk=%s tl=%s want=%s\n", rel, key, lnk, tl, want
      }
    }' "$t" >> "$O"
  rm -f "$t"
done < <(find "$W" -name slang.uhdm | LC_ALL=C sort)
echo "predict12: databases=$n census_fail=$fail  candidate OBJECTS=$(wc -l < "$O")"
[ "$n" -gt 0 ] || { echo "FATAL: reached NO databases"; exit 5; }
for r in A B C; do
  echo "-- CAND $r objects=$(awk -v r=$r '$2==r' "$O" | wc -l) databases=$(awk -v r=$r '$2==r{print $3}' "$O" | sort -u | wc -l)"
  awk -v r=$r '$2==r{print $3}' "$O" | sort | uniq -c | sort -rn | head -20 | sed 's/^/   /'
done
echo "-> $O"
