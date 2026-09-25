// arrexpr_db <db.uhdm>: every array_expr of the database with its parent chain and the UhdmIds of its
// element expressions (one constant object per element, or one object repeated).
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <cstdio>
#include <map>
#include <string>
using namespace UHDM;
int main(int argc, char** argv) {
  if (argc < 2) return 2;
  Serializer s;
  s.Restore(std::string(argv[1]));
  std::map<uint32_t, const array_expr*> byId;
  for (auto& [o, id] : s.AllObjects()) {
    const any* a = (const any*)o;
    if (a->UhdmType() == uhdmarray_expr) byId[a->UhdmId()] = (const array_expr*)a;
  }
  for (auto& [id, ae] : byId) {
    printf("array_expr#%u", id);
    int k = 0;
    for (const any* p = ae->VpiParent(); p && k < 3; p = p->VpiParent(), k++)
      printf(" <%s#%u %s", UhdmName(p->UhdmType()).c_str(), p->UhdmId(), std::string(p->VpiName()).c_str());
    printf(" | elems:");
    if (ae->Exprs())
      for (auto* e : *ae->Exprs()) printf(" %s#%u", UhdmName(e->UhdmType()).c_str(), e->UhdmId());
    printf("\n");
  }
  return 0;
}
