// v11u319 bindcls <db.uhdm>: every ref_obj the listener reaches (each once): line:col name -> its actual's type and name,
// classed DEF when the actual sits under a definition (design AllModules) and ELAB otherwise, UNBOUND when it has none.
// The binding census the record walk does not key on. Fail-closed on $FENCED (4 names, word boundary on the path).
#include <uhdm/uhdm.h>
#include <uhdm/VpiListener.h>
#include <iostream>
#include <regex>
#include <set>
#include <sstream>
#include <cstdlib>
using namespace UHDM;
std::set<const any*> defMods;
struct L : VpiListener {
  std::set<const any*> seen;
  void enterAny(const any* o, vpiHandle) override {
    if (!seen.insert(o).second || o->UhdmType() != uhdmref_obj) return;
    auto* r = (const ref_obj*)o; const any* a = r->Actual_group();
    std::string cls = "UNBOUND";
    if (a) { cls = "ELAB"; for (const any* p = a->VpiParent(); p; p = p->VpiParent()) if (defMods.count(p)) { cls = "DEF"; break; }
             cls += ":" + std::string(UhdmName(a->UhdmType())) + ":" + std::string(a->VpiName()); }
    std::cout << o->VpiLineNo() << ":" << o->VpiColumnNo() << " " << r->VpiName() << " " << cls << "\n";
  }
};
int main(int argc, char** argv) {
  const char* fe = getenv("FENCED"); if (!fe || !*fe || argc < 2) { std::cerr << "bindcls: FENCED unset\n"; return 2; }
  std::istringstream is(fe); std::string f; int n = 0;
  while (is >> f) { ++n; if (std::regex_search(std::string(argv[1]), std::regex("(^|[^A-Za-z0-9_])" + f + "([^A-Za-z0-9_]|$)"))) { std::cerr << "bindcls: fenced refused\n"; return 2; } }
  if (n != 4) { std::cerr << "bindcls: FENCED not 4 names\n"; return 2; }
  Serializer s; auto ds = s.Restore(std::string(argv[1]));
  for (auto h : ds) { auto* d = (const design*)((uhdm_handle*)h)->object; if (d->AllModules()) for (auto* m : *d->AllModules()) defMods.insert(m); }
  L l; for (auto h : ds) l.listenDesigns({h});
  return 0;
}
