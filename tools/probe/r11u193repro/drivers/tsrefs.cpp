// r11u193: object identity of the typespecs named <name> in a database: every
// object of that name (id, type, file:span) and every ref_typespec whose actual
// it is, with the reference's parent chain (types and names up to the design).
// usage: tsrefs <db.uhdm> <typespec name>
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <cstdio>
#include <map>
#include <string>
int main(int argc, char** argv) {
  if (argc < 3) return 2;
  UHDM::Serializer s;
  s.Restore(std::string(argv[1]));
  std::string want = argv[2];
  std::map<const UHDM::any*, int> ids;
  for (auto& kv : s.AllObjects()) {
    auto* o = (const UHDM::any*)kv.first;
    if (!o) continue;
    if (o->VpiName() == want && dynamic_cast<const UHDM::typespec*>(o)) {
      auto f = std::string(o->VpiFile());
      auto sl = f.rfind('/');
      printf("TS id=%u %s %s %u:%u-%u:%u\n", o->UhdmId(), UHDM::UhdmName(o->UhdmType()).data(),
             f.substr(sl == std::string::npos ? 0 : sl + 1).c_str(), o->VpiLineNo(), o->VpiColumnNo(),
             o->VpiEndLineNo(), o->VpiEndColumnNo());
    }
  }
  for (auto& kv : s.AllObjects()) {
    auto* o = (const UHDM::any*)kv.first;
    if (!o || o->UhdmType() != UHDM::uhdmref_typespec) continue;
    auto* rt = (const UHDM::ref_typespec*)o;
    auto* a = rt->Actual_typespec();
    if (!a || a->VpiName() != want) continue;
    printf("REF id=%u -> %u :", o->UhdmId(), a->UhdmId());
    for (const UHDM::any* p = o->VpiParent(); p; p = p->VpiParent())
      printf(" < %s(%s#%u)", UHDM::UhdmName(p->UhdmType()).data(), std::string(p->VpiName()).c_str(), p->UhdmId());
    printf("\n");
  }
  return 0;
}
