// r10uvm114 — every package/module Typespecs entry that is an enum_typespec,
// with its Base_typespec actual's id and fold state.  MEASUREMENT ONLY.
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
using namespace UHDM;
static const VectorOfrange* rangesOf(const any* a) {
  if (!a) return nullptr;
  if (a->UhdmType() == uhdmbit_typespec) return ((const bit_typespec*)a)->Ranges();
  if (a->UhdmType() == uhdmlogic_typespec) return ((const logic_typespec*)a)->Ranges();
  return nullptr;
}
static const char* fold(const any* a) {
  auto* rv = rangesOf(a);
  if (!rv || rv->empty()) return "NORANGE";
  for (auto* r : *rv)
    for (auto* b : {r->Left_expr(), r->Right_expr()})
      if (b && b->UhdmType() == uhdmoperation) return "OP";
  return "FOLD";
}
static void one(const char* tag, const typespec* t) {
  if (t->UhdmType() != uhdmenum_typespec) return;
  auto* bt = ((const enum_typespec*)t)->Base_typespec();
  const any* b = bt ? (const any*)bt->Actual_typespec() : nullptr;
  printf("%s enum=%s eid=%u base=%s bid=%u %s\n", tag,
         std::string(t->VpiName()).c_str(), (unsigned)t->UhdmId(),
         b ? std::string(b->VpiName()).c_str() : "-",
         b ? (unsigned)b->UhdmId() : 0u, b ? fold(b) : "-");
}
int main(int argc, char** argv) {
  Serializer s;
  auto restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "EMPTY\n"); return 3; }
  for (vpiHandle h : restored) {
    const any* o = (const any*)((const uhdm_handle*)h)->object;
    auto* d = any_cast<const design*>(o);
    if (!d) continue;
    auto go = [&](const char* w, const std::vector<package*>* v) {
      if (!v) return;
      for (auto* p : *v) { char tag[200];
        snprintf(tag, sizeof tag, "%s(%s)", w, std::string(p->VpiName()).c_str());
        if (auto* ts = p->Typespecs()) for (auto* t : *ts) one(tag, t); }
    };
    go("ALLPKG", d->AllPackages());
    go("TOPPKG", d->TopPackages());
    if (auto* ms = d->AllModules())
      for (auto* m : *ms) { char tag[200];
        snprintf(tag, sizeof tag, "ALLMOD(%s)", std::string(m->VpiName()).c_str());
        if (auto* ts = m->Typespecs()) for (auto* t : *ts) one(tag, t); }
    if (auto* ms = d->TopModules())
      for (auto* m : *ms) { char tag[200];
        snprintf(tag, sizeof tag, "TOPMOD(%s)", std::string(m->VpiName()).c_str());
        if (auto* ts = m->Typespecs()) for (auto* t : *ts) one(tag, t); }
  }
  return 0;
}
