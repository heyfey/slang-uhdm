# r10buvm30 — streaming census of a uhdm-dump.
#
# The dump is an INDENT TREE: `\_<kind>: …` opens an object at its own indent
# and every FIELD of that object is printed at indent+2 — including
# `|vpiParent:` whose value is ANOTHER `\_<kind>:` line at indent+2.  So the
# owner of a field line at indent I is the object opened at indent I-2, and
# nothing else: keying on "the last object seen" mis-attributes every object
# that prints a vpiParent (the first cut of this script lost exactly the
# parented minus operations it was written to count).
#
# Emits, per database:
#   NEG  a `constant` whose vpiDecompile starts with '-'   (a FOLDED negation)
#   MOP  an `operation` with vpiOpType 1                   (an UNFOLDED minus)
# each tagged with the top-level design section it sits in.
/^\|uhdm[A-Za-z]+:/ { sect = substr($0, 2, length($0) - 2); next }
{
  s = $0
  ind = match(s, /[^ ]/) - 1
  body = substr(s, ind + 1)
  if (substr(body, 1, 2) == "\\_") {
    kind = body; sub(/:.*/, "", kind); kind = substr(kind, 3)
    loc = ""
    if (match(body, /line:[0-9]+:[0-9]+, endln:[0-9]+:[0-9]+/))
      loc = substr(body, RSTART + 5, RLENGTH - 5)
    K[ind] = kind; L[ind] = loc
    # a shallower object invalidates everything deeper
    for (d in K) if (d + 0 > ind) { delete K[d]; delete L[d] }
    D[ind] = ""; SZ[ind] = ""; CT[ind] = ""
    next
  }
  if (substr(body, 1, 1) == "|") {
    f = substr(body, 2); v = f; sub(/:.*/, "", f); sub(/^[^:]*:/, "", v)
    o = ind - 2
    if (!(o in K)) next
    if (K[o] == "constant") {
      if (f == "vpiDecompile" && substr(v, 1, 1) == "-") D[o] = v
      else if (f == "vpiSize") SZ[o] = v
      else if (f == "vpiConstType") {
        CT[o] = v
        if (D[o] != "") {
          print "NEG\t" TEST "\t" MODE "\t" sect "\t" L[o] "\t" D[o] "\t" SZ[o] "\t" CT[o]
          D[o] = ""
        }
      }
    } else if (K[o] == "operation" && f == "vpiOpType" && v == "1") {
      print "MOP\t" TEST "\t" MODE "\t" sect "\t" L[o]
    }
  }
}
