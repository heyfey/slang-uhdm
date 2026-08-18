#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/Serializer.h>
#include <cstdio>
#include <string>
using namespace UHDM;
int main(int argc, char** argv) {
  uint32_t want = (uint32_t)atoi(argv[2]);
  int32_t wcol = argc > 3 ? atoi(argv[3]) : -1;
  Serializer s;
  if (s.Restore(std::string(argv[1])).empty()) return 3;
  for (const auto& [obj, id] : s.AllObjects()) {
    const constant* c = any_cast<const constant*>(obj);
    if (!c || c->VpiLineNo() != want) continue;
    if (wcol >= 0 && (int32_t)c->VpiColumnNo() != wcol) continue;
    const ref_typespec* rt = c->Typespec();
    char buf[512];
    if (!rt) snprintf(buf, sizeof buf, "TS=NO");
    else if (const typespec* a = rt->Actual_typespec())
      snprintf(buf, sizeof buf, "TSkind=%d TSspan=%s:%u:%u-%u:%u TSname=%s",
               (int)a->UhdmType(), std::string(a->VpiFile()).c_str(),
               a->VpiLineNo(), a->VpiColumnNo(), a->VpiEndLineNo(),
               a->VpiEndColumnNo(), std::string(a->VpiName()).c_str());
    else snprintf(buf, sizeof buf, "TS=yes actual=NULL");
    printf("%s|%s|%s\n", std::string(c->VpiValue()).c_str(),
           std::string(c->VpiDecompile()).c_str(), buf);
  }
  return 0;
}
