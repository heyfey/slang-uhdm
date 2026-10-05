// (r11u244: copied from r11u242repro/drivers)
// r11u242: memids <db.uhdm> <struct name> <member> - for every struct_typespec named <struct name>, print its id,
// its parent's type and id, and the member's Actual_value / Default_value kinds and ids (object identity, which
// uhdm-dump hides). Fail-closed fence check on the path: $FENCED must hold four names, none in the path.
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <sstream>
#include <string>
#include <filesystem>
using namespace UHDM;
int main(int argc, char** argv) {
  if (argc < 4) { fprintf(stderr, "usage: memids db name member\n"); return 2; }
  const char* f = getenv("FENCED");
  if (!f) { fprintf(stderr, "memids: FENCED unset\n"); return 2; }
  std::istringstream is(f); std::string w; int n = 0;
  while (is >> w) { n++; if (strstr(argv[1], w.c_str())) { fprintf(stderr, "memids: fenced path refused\n"); return 2; } }
  if (n != 4) { fprintf(stderr, "memids: FENCED not 4 names\n"); return 2; }
  Serializer s; auto v = s.Restore(std::filesystem::path(argv[1]));
  for (auto& kv : s.AllObjects()) {
    auto* o = (const BaseClass*)kv.first;
    if (!o || o->UhdmType() != uhdmstruct_typespec) continue;
    auto* st = (const struct_typespec*)o;
    if (st->VpiName() != argv[2] || !st->Members()) continue;
    auto* p = st->VpiParent();
    for (auto* m : *st->Members()) {
      if (m->VpiName() != argv[3]) continue;
      auto* a = m->Actual_value(); auto* d = m->Default_value();
      auto* ap = a ? a->VpiParent() : nullptr;
      printf("struct#%u %d:%d par=%s#%u av=%s#%u@%d:%d avpar=%s#%u dv=%s#%u\n", st->UhdmId(), st->VpiLineNo(), st->VpiColumnNo(),
             p ? std::string(UhdmName(p->UhdmType())).c_str() : "-", p ? p->UhdmId() : 0,
             a ? std::string(UhdmName(a->UhdmType())).c_str() : "-", a ? a->UhdmId() : 0,
             a ? a->VpiLineNo() : 0, a ? a->VpiColumnNo() : 0,
             ap ? std::string(UhdmName(ap->UhdmType())).c_str() : "-", ap ? ap->UhdmId() : 0,
             d ? std::string(UhdmName(d->UhdmType())).c_str() : "-", d ? d->UhdmId() : 0);
    }
  }
  return 0;
}
