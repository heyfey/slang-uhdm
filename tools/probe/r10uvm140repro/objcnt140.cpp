// r10uvm140 — DISTINCT-OBJECT counter over one database's Serializer arena.
// § retNamedTdWinsOverCanon140 re-points a POINTER; it must never mint or drop
// a typespec.  "A copy where golden shares is AWAY", so the count is scored
// explicitly, on the ARENA (not on the dump, where a re-binding changes how
// many times an object is PRINTED and the weaklyReferenced tail reorders).
// Rows: OBJ <label> enum=<n> struct=<n> union=<n> class=<n> logic=<n> all=<n>
// MEASUREMENT ONLY — the judge is the official uhdm-cmp.
//   usage: objcnt140 <db.uhdm> [label]
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
using namespace UHDM;
int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: objcnt140 <db> [label]\n"); return 2; }
  std::string label = argc > 2 ? argv[2] : argv[1];
  Serializer s;
  if (s.Restore(std::string(argv[1])).empty()) { printf("EMPTY\t%s\n", label.c_str()); return 3; }
  long e = 0, st = 0, u = 0, c = 0, l = 0, all = 0;
  for (auto& kv : s.AllObjects()) {
    const any* a = (const any*)kv.first;
    if (!a) continue;
    switch (a->UhdmType()) {
      case uhdmenum_typespec:   e++;  all++; break;
      case uhdmstruct_typespec: st++; all++; break;
      case uhdmunion_typespec:  u++;  all++; break;
      case uhdmclass_typespec:  c++;  all++; break;
      case uhdmlogic_typespec:  l++;  all++; break;
      default: break;
    }
  }
  printf("OBJ\t%s\tenum=%ld\tstruct=%ld\tunion=%ld\tclass=%ld\tlogic=%ld\tall=%ld\n",
         label.c_str(), e, st, u, c, l, all);
  return 0;
}
