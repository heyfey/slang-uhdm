// r10uvm125 — ref_typespec identity listing, for scoring the ONE-SIDED SET of a
// pass that REMOVES objects.  One line per ref_typespec:
//     parent kind@span | actual typespec kind | actual name | own span
// No object ids (not comparable across builds).  MEASUREMENT ONLY.
//   usage: rt125 <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <cstdio>
#include <string>
using namespace UHDM;
static std::string sp(const any* p) {
  if (!p) return "-";
  char b[64];
  snprintf(b, sizeof b, "%u:%u-%u:%u", (unsigned)p->VpiLineNo(),
           (unsigned)p->VpiColumnNo(), (unsigned)p->VpiEndLineNo(),
           (unsigned)p->VpiEndColumnNo());
  return b;
}
int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: rt125 <db>\n"); return 2; }
  Serializer s;
  if (s.Restore(std::string(argv[1])).empty()) { fprintf(stderr, "EMPTY\n"); return 3; }
  for (auto& kv : s.AllObjects()) {
    const any* a = (const any*)kv.first;
    if (!a || a->UhdmType() != uhdmref_typespec) continue;
    auto* rt = (const ref_typespec*)a;
    const any* p = rt->VpiParent();
    const typespec* t = rt->Actual_typespec();
    printf("%s@%s|%s|%s|%s\n",
           p ? UhdmName(p->UhdmType()).data() : "<null>", sp(p).c_str(),
           t ? UhdmName(t->UhdmType()).data() : "<null>",
           t ? std::string(t->VpiName()).c_str() : "-", sp(rt).c_str());
  }
  return 0;
}
