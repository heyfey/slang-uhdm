// v11u294 parents <db.uhdm> [kind-substring]: every object whose kind name contains the substring (default
// "typespec"), with its line:col-endline:endcol, its vpiParent's kind and location, in UhdmId order.  A case
// database only: refuses a path naming a fenced test (FENCED in the environment, fail-closed).
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <cstdio>
#include <cstdlib>
#include <map>
#include <sstream>
#include <string>
using namespace UHDM;
int main(int argc, char** argv) {
  const char* f = getenv("FENCED");
  if (!f || argc < 2) { fprintf(stderr, "parents: FENCED unset or no file\n"); return 2; }
  std::istringstream is(f); std::string n; int cnt = 0;
  while (is >> n) { ++cnt; if (std::string(argv[1]).find(n) != std::string::npos) { fprintf(stderr, "fenced\n"); return 2; } }
  if (cnt != 4) { fprintf(stderr, "parents: FENCED not 4 names\n"); return 2; }
  std::string sub = argc > 2 ? argv[2] : "typespec";
  Serializer s; s.Restore(std::string(argv[1]));
  std::map<uint32_t, const BaseClass*> byId;
  for (auto& [o, id] : s.AllObjects()) byId[o->UhdmId()] = o;
  for (auto& [id, o] : byId) {
    std::string k(UhdmName(o->UhdmType()));
    if (k.find(sub) == std::string::npos) continue;
    const BaseClass* p = o->VpiParent();
    printf("#%u %s '%s' %u:%u-%u:%u parent=%s", id, k.c_str(), std::string(o->VpiName()).c_str(), o->VpiLineNo(), o->VpiColumnNo(), o->VpiEndLineNo(), o->VpiEndColumnNo(), p ? std::string(UhdmName(p->UhdmType())).c_str() : "null");
    if (p) printf(" #%u %u:%u", p->UhdmId(), p->VpiLineNo(), p->VpiColumnNo());
    printf("\n");
  }
}
