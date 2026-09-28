// r11u193: object identity of the objects NAMED <name> (any kind: id, type, full name, span, parent) and of
// every ref_obj whose actual has that name (the reference's id, its actual's id, its parent chain).
// usage: objrefs <db.uhdm> <name>
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_user.h>
#include <cstdio>
#include <string>
int main(int argc, char** argv) {
  if (argc < 3) return 2;
  UHDM::Serializer s;
  s.Restore(std::string(argv[1]));
  std::string want = argv[2];
  for (auto& kv : s.AllObjects()) {
    auto* o = (const UHDM::any*)kv.first;
    if (!o || o->VpiName() != want || o->UhdmType() == UHDM::uhdmref_obj) continue;
    const UHDM::any* p = o->VpiParent();
    printf("OBJ id=%u %s full=%s %u:%u-%u:%u parent=%s#%u\n", o->UhdmId(), UHDM::UhdmName(o->UhdmType()).data(),
           [&]{ vpiHandle h = s.MakeUhdmHandle(o->UhdmType(), o); const char* f = vpi_get_str(vpiFullName, h); return std::string(f ? f : ""); }().c_str(), o->VpiLineNo(), o->VpiColumnNo(), o->VpiEndLineNo(),
           o->VpiEndColumnNo(), p ? UHDM::UhdmName(p->UhdmType()).data() : "-", p ? p->UhdmId() : 0);
  }
  for (auto& kv : s.AllObjects()) {
    auto* o = (const UHDM::any*)kv.first;
    if (!o || o->UhdmType() != UHDM::uhdmref_obj) continue;
    auto* a = ((const UHDM::ref_obj*)o)->Actual_group();
    if (o->VpiName() != want) continue;
    printf("REF id=%u %u:%u -> %s#%u :", o->UhdmId(), o->VpiLineNo(), o->VpiColumnNo(),
           a ? UHDM::UhdmName(a->UhdmType()).data() : "null", a ? a->UhdmId() : 0);
    for (const UHDM::any* p = o->VpiParent(); p; p = p->VpiParent())
      printf(" < %s(%s#%u)", UHDM::UhdmName(p->UhdmType()).data(), std::string(p->VpiName()).c_str(), p->UhdmId());
    printf("\n");
  }
  return 0;
}
