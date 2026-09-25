// tsmem_db <db.uhdm> [member-name]: every typespec_member of the database (all objects), with its
// UhdmId, its parent struct_typespec's id and name, and its Default_value / Actual_value objects
// (id, kind, span, value) -- which object each stamp is, and whether two members share one.
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <cstdio>
#include <map>
#include <string>
using namespace UHDM;
static std::string desc(const any* e) {
  if (!e) return "-";
  char b[256];
  std::string v;
  if (e->UhdmType() == uhdmconstant) v = std::string(((const constant*)e)->VpiValue());
  snprintf(b, sizeof b, "%s#%u@%d:%d-%d:%d%s%s", UhdmName(e->UhdmType()).c_str(), e->UhdmId(),
           e->VpiLineNo(), e->VpiColumnNo(), e->VpiEndLineNo(), e->VpiEndColumnNo(), v.empty() ? "" : " ",
           v.c_str());
  std::string r = b;
  // the parent chain, four levels up
  int k = 0;
  for (const any* p = e->VpiParent(); p && k < 4; p = p->VpiParent(), k++) {
    snprintf(b, sizeof b, " <%s#%u@%d:%d", UhdmName(p->UhdmType()).c_str(), p->UhdmId(), p->VpiLineNo(),
             p->VpiColumnNo());
    r += b;
  }
  return r;
}
int main(int argc, char** argv) {
  if (argc < 2) return 2;
  std::string want = argc > 2 ? argv[2] : "";
  Serializer s;
  s.Restore(std::string(argv[1]));
  std::map<uint32_t, const typespec_member*> byId;
  for (auto& [o, id] : s.AllObjects()) {
    const any* a = (const any*)o;
    if (a->UhdmType() != uhdmtypespec_member) continue;
    byId[a->UhdmId()] = (const typespec_member*)a;
  }
  for (auto& [id, m] : byId) {
    if (!want.empty() && m->VpiName() != want) continue;
    const any* p = m->VpiParent();
    printf("member#%u %s in %s#%u %s | default=%s | actual=%s\n", id, std::string(m->VpiName()).c_str(),
           p ? UhdmName(p->UhdmType()).c_str() : "-", p ? p->UhdmId() : 0,
           p ? std::string(p->VpiName()).c_str() : "", desc(m->Default_value()).c_str(),
           desc(m->Actual_value()).c_str());
  }
  return 0;
}
