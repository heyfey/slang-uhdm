// r10uvm140 — A-PRIORI MOVER PREDICTOR over the PRISTINE databases.
//
// § retNamedTdWinsOverCanon140 changes ONE thing: which typespec object a
// FUNCTION RETURN's ref_typespec binds when the return type names a typedef
// whose canonical type is shared with another typedef.  In a PRISTINE
// database that situation leaves a signature that needs no source and no
// patched build to read:
//
//   there is a `function` whose `Return()` variable's `Typespec()`
//   `Actual_typespec()` is an enum_typespec / struct_typespec A, and some
//   OTHER typespec B in the same database carries `Typedef_alias -> A`
//   (B is an ALIAS OF the typedef A, i.e. the canonical-type scan the law
//   replaces had at least two answers to choose between).
//
// Every cell the law can move is one of those; the reverse does not hold (a
// function that spelled the BASE keeps its old answer), so this is a
// deliberate OVER-approximation: a database it does NOT name CANNOT move, and
// the byte-mover audit must be a SUBSET of the databases it names.
//
// Rows:  CAND <db> <function> <bound-ts-kind> <bound-ts-name> aliases=<n>
// Tail:  TOTAL <db> cands=<n> aliasedts=<n>
//
// MEASUREMENT ONLY — the judge is the official uhdm-cmp.
//   usage: pred140 <db.uhdm> [<label>]
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <map>
#include <string>
using namespace UHDM;

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: pred140 <db> [label]\n"); return 2; }
  std::string label = argc > 2 ? argv[2] : argv[1];
  Serializer s;
  auto restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { printf("EMPTY\t%s\n", label.c_str()); return 3; }
  // (1) every typespec that some OTHER typespec aliases.
  std::map<const typespec*, int> aliased;
  for (auto& kv : s.AllObjects()) {
    const any* a = (const any*)kv.first;
    if (!a) continue;
    const BaseClass* bc = (const BaseClass*)a;
    const typespec* t = any_cast<const typespec*>(bc);
    if (!t) continue;
    const ref_typespec* al = t->Typedef_alias();
    if (!al) continue;
    const typespec* tgt = al->Actual_typespec();
    if (tgt && tgt != t) aliased[tgt]++;
  }
  // (2) function returns bound to one of them.
  int cands = 0;
  for (auto& kv : s.AllObjects()) {
    const any* a = (const any*)kv.first;
    if (!a || a->UhdmType() != uhdmfunction) continue;
    const variables* rv = ((const function*)a)->Return();
    if (!rv) continue;
    const ref_typespec* rt = rv->Typespec();
    if (!rt) continue;
    const typespec* act = rt->Actual_typespec();
    if (!act) continue;
    UHDM_OBJECT_TYPE k = act->UhdmType();
    if (k != uhdmenum_typespec && k != uhdmstruct_typespec) continue;
    auto it = aliased.find(act);
    if (it == aliased.end()) continue;
    cands++;
    printf("CAND\t%s\t%s\t%s\t%s\taliases=%d\n", label.c_str(),
           std::string(((const function*)a)->VpiFullName()).c_str(),
           std::string(UhdmName(k)).c_str(),
           std::string(act->VpiName()).c_str(), it->second);
  }
  printf("TOTAL\t%s\tcands=%d\taliasedts=%d\n", label.c_str(), cands,
         (int)aliased.size());
  return 0;
}
