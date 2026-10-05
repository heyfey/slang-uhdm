// (r11u244: copied from r11u242repro/drivers)
// r11u242: paramids <db.uhdm> <param name> - for every parameter of that name: its id, parent kind/id, its Ranges'
// ids, and its typespec's kind/id with that typespec's Ranges' ids (object identity uhdm-dump hides).
// Fail-closed fence check on the path: $FENCED must hold four names, none in the path.
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <filesystem>
#include <sstream>
#include <string>
using namespace UHDM;
static std::string ids(const VectorOfrange* v) {
  std::string s; if (!v) return "-";
  for (auto* r : *v) s += "#" + std::to_string(r->UhdmId()) + "(par#" + std::to_string(r->VpiParent() ? r->VpiParent()->UhdmId() : 0) + ")";
  return s;
}
int main(int argc, char** argv) {
  if (argc < 3) { fprintf(stderr, "usage: paramids db name\n"); return 2; }
  const char* f = getenv("FENCED");
  if (!f) { fprintf(stderr, "paramids: FENCED unset\n"); return 2; }
  std::istringstream is(f); std::string w; int n = 0;
  while (is >> w) { n++; if (strstr(argv[1], w.c_str())) { fprintf(stderr, "paramids: fenced path refused\n"); return 2; } }
  if (n != 4) { fprintf(stderr, "paramids: FENCED not 4 names\n"); return 2; }
  Serializer s; s.Restore(std::filesystem::path(argv[1]));
  for (auto& kv : s.AllObjects()) {
    auto* o = (const BaseClass*)kv.first;
    if (!o || o->UhdmType() != uhdmparameter || o->VpiName() != argv[2]) continue;
    auto* p = (const parameter*)o;
    auto* par = p->VpiParent();
    const typespec* t = p->Typespec() ? p->Typespec()->Actual_typespec() : nullptr;
    printf("param#%u %s par=%s#%u ranges=%s ts=%s#%u", p->UhdmId(), std::string(p->VpiFullName()).c_str(),
           par ? std::string(UhdmName(par->UhdmType())).c_str() : "-", par ? par->UhdmId() : 0, ids(p->Ranges()).c_str(),
           t ? std::string(UhdmName(t->UhdmType())).c_str() : "-", t ? t->UhdmId() : 0);
    if (t && t->UhdmType() == uhdmarray_typespec) printf(" tsranges=%s", ids(((const array_typespec*)t)->Ranges()).c_str());
    printf("\n");
  }
  return 0;
}
