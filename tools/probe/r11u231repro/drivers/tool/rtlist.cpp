// r11u231: every ref_typespec with its parent kind/name, its STORED full name and its actual's kind/span.
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <cstdio>
using namespace UHDM;
int main(int argc, char** argv) {
  Serializer s;
  s.Restore(std::string(argv[1]));
  for (auto& pr : s.AllObjects()) {
    auto* o = pr.first; if (!o || o->UhdmType() != uhdmref_typespec) continue;
    auto* r = (const ref_typespec*)o; auto* p = o->VpiParent(); auto* a = r->Actual_typespec();
    printf("par=%s:%s stored=[%s] act=%s %u:%u\n", p ? UhdmName(p->UhdmType()).data() : "-", p ? std::string(p->VpiName()).c_str() : "-",
           std::string(r->VpiFullName()).c_str(), a ? UhdmName(a->UhdmType()).data() : "-", a ? a->VpiLineNo() : 0, a ? a->VpiColumnNo() : 0);
  }
}
