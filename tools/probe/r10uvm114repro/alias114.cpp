// r10uvm114 — print the Typedef_alias chain of every package Typespecs entry
// matching a name filter, with each link's first-range bound shapes.
// MEASUREMENT ONLY.   usage: alias114 <db.uhdm> <name-substr>
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
           ",id=" + std::to_string(c->UhdmId()) + "}";
  }
  if (e->UhdmType() == uhdmoperation)
    return "OP" + std::to_string(((const operation*)e)->VpiOpType()) +
           "{id=" + std::to_string(e->UhdmId()) + "}";
  return std::string(UhdmName(e->UhdmType()));
}
static const VectorOfrange* rangesOf(const typespec* t) {
  if (auto* b = t->Cast<const bit_typespec*>()) return b->Ranges();
  if (auto* l = t->Cast<const logic_typespec*>()) return l->Ranges();
  return nullptr;
}
static void walk(const typespec* t, int depth, const char* how) {
  if (!t || depth > 6) return;
  auto* rs = rangesOf(t);
  printf("%*s%s %s id=%u name=%s @%u:%u", depth * 2, "", how,
         std::string(UhdmName(t->UhdmType())).c_str(), (unsigned)t->UhdmId(),
         std::string(t->VpiName()).c_str(), (unsigned)t->VpiLineNo(), t->VpiColumnNo());
  if (rs && !rs->empty())
    printf(" rid=%u L=%s R=%s", (unsigned)(*rs)[0]->UhdmId(),
           shp((*rs)[0]->Left_expr()).c_str(), shp((*rs)[0]->Right_expr()).c_str());
  const any* inst = nullptr;
  if (auto* b = t->Cast<const bit_typespec*>()) inst = b->Instance();
  else if (auto* l = t->Cast<const logic_typespec*>()) inst = l->Instance();
  if (inst) printf(" inst=%s(%s)", std::string(UhdmName(inst->UhdmType())).c_str(),
                   std::string(inst->VpiName()).c_str());
  printf("\n");
  const ref_typespec* al = nullptr;
  if (auto* b = t->Cast<const bit_typespec*>()) al = b->Typedef_alias();
  else if (auto* l = t->Cast<const logic_typespec*>()) al = l->Typedef_alias();
  if (al) {
    printf("%*s  alias ref id=%u full=%s\n", depth * 2, "", (unsigned)al->UhdmId(),
           std::string(al->VpiFullName()).c_str());
    walk(al->Actual_typespec(), depth + 1, "->");
  }
}
int main(int argc, char** argv) {
  if (argc < 3) { fprintf(stderr, "usage: alias114 <db> <substr>\n"); return 2; }
  std::string f(argv[2]);
  Serializer s;
  auto restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "EMPTY\n"); return 3; }
  for (vpiHandle h : restored) {
    const any* o = (const any*)((const uhdm_handle*)h)->object;
    auto* d = any_cast<const design*>(o);
    if (!d) continue;
    auto go = [&](const char* which, const std::vector<package*>* v) {
      if (!v) return;
      for (auto* p : *v)
        if (auto* ts = p->Typespecs())
          for (auto* t : *ts)
            if (std::string(t->VpiName()).find(f) != std::string::npos) {
              printf("== %s pkg=%s pid=%u\n", which, std::string(p->VpiName()).c_str(),
                     (unsigned)p->UhdmId());
              walk(t, 0, "TS");
            }
    };
    go("ALLPKG", d->AllPackages());
    go("TOPPKG", d->TopPackages());
  }
  return 0;
}
