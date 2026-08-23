// r10uvm114 — every typespec whose VpiName matches a filter, with its fold
// state and every ref_typespec that points at it (the REFERENCING CONTEXT).
// MEASUREMENT ONLY.   usage: tdclone114 <db.uhdm> <name-substr>
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <map>
#include <string>
#include <vector>
using namespace UHDM;
static std::string shp(const any* e) {
  if (!e) return "<null>";
  if (e->UhdmType() == uhdmconstant) {
    auto* c = (const constant*)e;
    return "C{" + std::string(c->VpiValue()) + ",ct=" + std::to_string(c->VpiConstType()) + "}";
  }
  if (e->UhdmType() == uhdmoperation)
    return "OP" + std::to_string(((const operation*)e)->VpiOpType());
  return std::string(UhdmName(e->UhdmType()));
}
static std::string chainOf(const any* o) {
  std::string r;
  const any* p = o ? o->VpiParent() : nullptr;
  for (int i = 0; i < 8 && p; i++) {
    std::string e(UhdmName(p->UhdmType()));
    if (!p->VpiName().empty()) e += "(" + std::string(p->VpiName()) + ")";
    r = r.empty() ? e : (e + "/" + r);
    p = p->VpiParent();
  }
  return r.empty() ? "-" : r;
}
int main(int argc, char** argv) {
  if (argc < 3) { fprintf(stderr, "usage: tdclone114 <db> <substr>\n"); return 2; }
  std::string f(argv[2]);
  Serializer s;
  auto restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "EMPTY\n"); return 3; }
  auto all = s.AllObjects();
  std::map<const BaseClass*, std::vector<const ref_typespec*>> refs;
  for (auto& kv : all) {
    const any* a = (const any*)kv.first;
    if (!a || a->UhdmType() != uhdmref_typespec) continue;
    auto* rt = (const ref_typespec*)a;
    if (rt->Actual_typespec()) refs[(const BaseClass*)rt->Actual_typespec()].push_back(rt);
  }
  for (auto& kv : all) {
    const any* a = (const any*)kv.first;
    if (!a) continue;
    auto t = a->UhdmType();
    if (t != uhdmbit_typespec && t != uhdmlogic_typespec) continue;
    if (std::string(a->VpiName()).find(f) == std::string::npos) continue;
    const VectorOfrange* rs = (t == uhdmbit_typespec)
        ? ((const bit_typespec*)a)->Ranges() : ((const logic_typespec*)a)->Ranges();
    std::string L = (rs && !rs->empty()) ? shp((*rs)[0]->Left_expr()) : std::string("-");
    uint32_t rid = (rs && !rs->empty()) ? (uint32_t)(*rs)[0]->UhdmId() : 0;
    printf("TSOBJ id=%u name=%s rid=%u L=%s parent=%s\n", (unsigned)a->UhdmId(),
           std::string(a->VpiName()).c_str(), rid, L.c_str(), chainOf(a).c_str());
    auto it = refs.find((const BaseClass*)a);
    if (it != refs.end())
      for (auto* rt : it->second)
        printf("   <- ref id=%u full=%s ctx=%s\n", (unsigned)rt->UhdmId(),
               std::string(rt->VpiFullName()).c_str(), chainOf(rt).c_str());
  }
  return 0;
}
