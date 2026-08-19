// r10earl70 — LOCATE an object by SPAN anywhere the UhdmListener can reach, and
// print its owner CHAIN (VpiParent walk).  Written because tscen70's container
// walk could not find the testflags head that uhdm-cmp names: a census keyed on
// the containers you think matter is blind to the container you forgot.
// MEASUREMENT ONLY.  usage: findobj70 <db.uhdm> <line> <col>
#include <uhdm/uhdm.h>
#include <uhdm/UhdmListener.h>
#include <cstdio>
#include <string>
using namespace UHDM;
static uint32_t L, C;
struct F : public UhdmListener {
  void enterAny(const any* const o) final {
    if (o->VpiLineNo() != L || o->VpiColumnNo() != C) return;
    std::string chain;
    const any* p = o;
    for (int i = 0; i < 40 && p; i++) {
      chain += std::string(UhdmName(p->UhdmType()));
      if (!p->VpiName().empty()) chain += "(" + std::string(p->VpiName()) + ")";
      p = p->VpiParent();
      if (p) chain += " <- ";
    }
    // Is this object still the one the PORT's High_conn points at?  A
    // pre-elaboration copy keeps its VpiParent chain but the port's High_conn
    // has been replaced — that is invisible to a container census.
    const any* q = o; const any* prev = nullptr;
    std::string live = "?";
    while (q && q->UhdmType() != uhdmport) { prev = q; q = q->VpiParent(); }
    if (q) live = (((const port*)q)->High_conn() == prev) ? "LIVE" : "ORPHAN";
    printf("HIT[%s] %s name=%s %u:%u-%u:%u | %s\n", live.c_str(),
           UhdmName(o->UhdmType()).data(), std::string(o->VpiName()).c_str(),
           o->VpiLineNo(), o->VpiColumnNo(), o->VpiEndLineNo(),
           o->VpiEndColumnNo(), chain.c_str());
  }
};
int main(int argc, char** argv) {
  if (argc < 4) { fprintf(stderr, "usage: findobj70 <db> <line> <col>\n"); return 2; }
  L = atoi(argv[2]); C = atoi(argv[3]);
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  F f;
  for (vpiHandle h : restored) {
    const any* o = (const any*)((const uhdm_handle*)h)->object;
    if (auto* d = any_cast<const design*>(o)) f.listenDesign(d);
  }
  return 0;
}
