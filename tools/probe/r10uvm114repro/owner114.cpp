// r10uvm114 — name every object that HOLDS a given range id in its Ranges()
// vector (sharing is invisible to VpiParent).  MEASUREMENT ONLY.
//   usage: owner114 <db.uhdm> <rangeid>
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
using namespace UHDM;
static void rep(const BaseClass* o, const char* how) {
  const any* a = (const any*)o;
  const any* p = a->VpiParent();
  printf("HOLDER %s kind=%s id=%u name=%s @%u:%u-%u:%u parent=%s(%s)\n", how,
         std::string(UhdmName(a->UhdmType())).c_str(), (unsigned)a->UhdmId(),
         std::string(a->VpiName()).c_str(), (unsigned)a->VpiLineNo(), a->VpiColumnNo(),
         (unsigned)a->VpiEndLineNo(), a->VpiEndColumnNo(),
         p ? std::string(UhdmName(p->UhdmType())).c_str() : "-",
         p ? std::string(p->VpiName()).c_str() : "-");
}
int main(int argc, char** argv) {
  if (argc < 3) { fprintf(stderr, "usage: owner114 <db> <rangeid>\n"); return 2; }
  uint32_t want = (uint32_t)atoi(argv[2]);
  Serializer s;
  auto restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "EMPTY\n"); return 3; }
  auto all = s.AllObjects();
  for (auto& kv : all) {
    const BaseClass* o = kv.first;
    if (!o) continue;
    const any* a = (const any*)o;
    const VectorOfrange* rs = nullptr;
    const char* how = "?";
    switch (a->UhdmType()) {
      case uhdmbit_typespec: rs = ((const bit_typespec*)a)->Ranges(); how = "bit_ts"; break;
      case uhdmlogic_typespec: rs = ((const logic_typespec*)a)->Ranges(); how = "logic_ts"; break;
      case uhdmarray_typespec: rs = ((const array_typespec*)a)->Ranges(); how = "array_ts"; break;
      case uhdmpacked_array_typespec: rs = ((const packed_array_typespec*)a)->Ranges(); how = "pa_ts"; break;
      case uhdmint_typespec: rs = ((const int_typespec*)a)->Ranges(); how = "int_ts"; break;
      case uhdmenum_typespec: how = "enum_ts"; break;
      case uhdmlogic_net: rs = ((const logic_net*)a)->Ranges(); how = "logic_net"; break;
      case uhdmlogic_var: rs = ((const logic_var*)a)->Ranges(); how = "logic_var"; break;
      case uhdmbit_var: rs = ((const bit_var*)a)->Ranges(); how = "bit_var"; break;
      case uhdmarray_var: rs = ((const array_var*)a)->Ranges(); how = "array_var"; break;
      case uhdmarray_net: rs = ((const array_net*)a)->Ranges(); how = "array_net"; break;
      case uhdmpacked_array_var: rs = ((const packed_array_var*)a)->Ranges(); how = "pa_var"; break;
      case uhdmpacked_array_net: rs = ((const packed_array_net*)a)->Ranges(); how = "pa_net"; break;
      default: break;
    }
    if (!rs) continue;
    for (auto* r : *rs)
      if ((uint32_t)r->UhdmId() == want) { rep(o, how); break; }
  }
  return 0;
}
