// r10uvm114 — list every package object's Typespecs entry matching a name
// filter, with the fold state of its first range's Left_expr.  MEASUREMENT ONLY.
//   usage: pkgls114 <db.uhdm> <name-substr>
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
using namespace UHDM;
static std::string shp(const any* e) {
  if (!e) return "<null>";
  if (e->UhdmType() == uhdmconstant) {
    auto* c = (const constant*)e;
    return "C{" + std::string(c->VpiValue()) + ",ct=" + std::to_string(c->VpiConstType()) +
           ",@" + std::to_string(c->VpiLineNo()) + ":" + std::to_string(c->VpiColumnNo()) +
           "-" + std::to_string(c->VpiEndLineNo()) + ":" + std::to_string(c->VpiEndColumnNo()) + "}";
  }
  if (e->UhdmType() == uhdmoperation)
    return "OP" + std::to_string(((const operation*)e)->VpiOpType());
  return std::string(UhdmName(e->UhdmType()));
}
static void dumpTs(const char* tag, const typespec* t) {
  const VectorOfrange* rs = nullptr;
  if (auto* b = t->Cast<const bit_typespec*>()) rs = b->Ranges();
  else if (auto* l = t->Cast<const logic_typespec*>()) rs = l->Ranges();
  if (!rs || rs->empty()) { printf("%s ts=%s id=%u name=%s NORANGE\n", tag,
      std::string(UhdmName(t->UhdmType())).c_str(), (unsigned)t->UhdmId(),
      std::string(t->VpiName()).c_str()); return; }
  printf("%s ts=%s id=%u name=%s span=%u:%u-%u:%u L=%s R=%s\n", tag,
         std::string(UhdmName(t->UhdmType())).c_str(), (unsigned)t->UhdmId(),
         std::string(t->VpiName()).c_str(), (unsigned)t->VpiLineNo(), t->VpiColumnNo(),
         (unsigned)t->VpiEndLineNo(), t->VpiEndColumnNo(),
         shp((*rs)[0]->Left_expr()).c_str(), shp((*rs)[0]->Right_expr()).c_str());
}
int main(int argc, char** argv) {
  if (argc < 3) { fprintf(stderr, "usage: pkgls114 <db> <substr>\n"); return 2; }
  std::string f(argv[2]);
  Serializer s;
  auto restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "EMPTY\n"); return 3; }
  for (vpiHandle h : restored) {
    const any* o = (const any*)((const uhdm_handle*)h)->object;
    auto* d = any_cast<const design*>(o);
    if (!d) continue;
    auto emitList = [&](const char* which, const std::vector<package*>* v) {
      if (!v) return;
      for (auto* p : *v) {
        char tag[300];
        snprintf(tag, sizeof tag, "%s pkg=%s pid=%u", which,
                 std::string(p->VpiName()).c_str(), (unsigned)p->UhdmId());
        if (auto* ts = p->Typespecs())
          for (auto* t : *ts)
            if (std::string(t->VpiName()).find(f) != std::string::npos) dumpTs(tag, t);
      }
    };
    emitList("ALLPKG", d->AllPackages());
    emitList("TOPPKG", d->TopPackages());
  }
  return 0;
}
