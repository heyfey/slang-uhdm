// r10earl64 — LOCATE A HEAD OBJECT BY SPAN in a .uhdm too large to uhdm-dump.
// MEASUREMENT ONLY.  Prints every constant at <line>:<col> with its file, its
// Compare-visible fields and its parent chain (kind + vpiName/vpiFullName), so
// an owner-less cmp head can be named without a whole-database dump.
//   usage: cfind64 <db.uhdm> <line> [col]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/Serializer.h>
#include <cstdio>
#include <string>
using namespace UHDM;

int main(int argc, char** argv) {
  if (argc < 3) { fprintf(stderr, "usage: cfind64 <db.uhdm> <line> [col]\n"); return 2; }
  uint32_t want = (uint32_t)atoi(argv[2]);
  int32_t wcol = argc > 3 ? atoi(argv[3]) : -1;
  Serializer s;
  if (s.Restore(std::string(argv[1])).empty()) { fprintf(stderr, "EMPTY\n"); return 3; }
  for (const auto& [obj, id] : s.AllObjects()) {
    if (!obj) continue;
    const constant* c = any_cast<const constant*>(obj);
    if (!c) continue;
    if (c->VpiLineNo() != want) continue;
    if (wcol >= 0 && (int32_t)c->VpiColumnNo() != wcol) continue;
    printf("CONST id=%u %s:%u:%u-%u:%u ct=%d sz=%d val=%s dec=%s\n", id,
           std::string(c->VpiFile()).c_str(), c->VpiLineNo(), c->VpiColumnNo(),
           c->VpiEndLineNo(), c->VpiEndColumnNo(), c->VpiConstType(),
           c->VpiSize(), std::string(c->VpiValue()).c_str(),
           std::string(c->VpiDecompile()).c_str());
    const any* p = c->VpiParent();
    for (int d = 0; p && d < 8; d++) {
      printf("   ^%d %s name='%s' file='%s' %u:%u\n", d,
             std::string(UhdmName(p->UhdmType())).c_str(),
             std::string(p->VpiName()).c_str(),
             std::string(p->VpiFile()).c_str(), p->VpiLineNo(),
             p->VpiColumnNo());
      p = p->VpiParent();
    }
  }
  return 0;
}
