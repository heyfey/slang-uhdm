// r10uvm123 — print the FULL parent chain (kind+id+name+span) of a given object
// id, plus, for a typespec, its fold state / Typedef_alias, and every
// ref_typespec that points at it with ITS chain.  MEASUREMENT ONLY.
//   usage: ctx123 <db.uhdm> <id> [<id> ...]
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstdlib>
#include <map>
#include <set>
#include <string>
#include <vector>
using namespace UHDM;
static std::string shp(const any* e) {
  if (!e) return "<null>";
  if (e->UhdmType() == uhdmconstant) {
    auto* c = (const constant*)e;
    return "C{" + std::string(c->VpiValue()) + ",ct=" +
           std::to_string(c->VpiConstType()) + "}";
  }
  if (e->UhdmType() == uhdmoperation)
    return "OP" + std::to_string(((const operation*)e)->VpiOpType());
  return std::string(UhdmName(e->UhdmType()));
}
static std::string node(const any* p) {
  std::string e(UhdmName(p->UhdmType()));
  e += "#" + std::to_string((unsigned)p->UhdmId());
  if (!p->VpiName().empty()) e += "(" + std::string(p->VpiName()) + ")";
  if (p->UhdmType() == uhdmoperation)
    e += "{op" + std::to_string(((const operation*)p)->VpiOpType()) + "}";
  if (p->VpiLineNo())
    e += "@" + std::to_string((unsigned)p->VpiLineNo()) + ":" +
         std::to_string(p->VpiColumnNo());
  return e;
}
static std::string chainOf(const any* o) {
  std::string r;
  const any* p = o ? o->VpiParent() : nullptr;
  for (int i = 0; i < 12 && p; i++) {
    r = r.empty() ? node(p) : (node(p) + "/" + r);
    p = p->VpiParent();
  }
  return r.empty() ? "-" : r;
}
static const VectorOfrange* rangesOf(const any* a) {
  switch (a->UhdmType()) {
    case uhdmbit_typespec: return ((const bit_typespec*)a)->Ranges();
    case uhdmlogic_typespec: return ((const logic_typespec*)a)->Ranges();
    case uhdmarray_typespec: return ((const array_typespec*)a)->Ranges();
    case uhdmpacked_array_typespec: return ((const packed_array_typespec*)a)->Ranges();
    case uhdmint_typespec: return ((const int_typespec*)a)->Ranges();
    default: return nullptr;
  }
}
int main(int argc, char** argv) {
  if (argc < 3) { fprintf(stderr, "usage: ctx123 <db> <id>...\n"); return 2; }
  std::set<uint32_t> want;
  for (int i = 2; i < argc; i++) want.insert((uint32_t)atoi(argv[i]));
  Serializer s;
  auto restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "EMPTY\n"); return 3; }
  auto all = s.AllObjects();
  std::map<const BaseClass*, std::vector<const ref_typespec*>> refs;
  for (auto& kv : all) {
    const any* a = (const any*)kv.first;
    if (!a || a->UhdmType() != uhdmref_typespec) continue;
    auto* rt = (const ref_typespec*)a;
    if (rt->Actual_typespec())
      refs[(const BaseClass*)rt->Actual_typespec()].push_back(rt);
  }
  for (auto& kv : all) {
    const any* a = (const any*)kv.first;
    if (!a || !want.count((uint32_t)a->UhdmId())) continue;
    printf("OBJ %s\n  CHAIN %s\n", node(a).c_str(), chainOf(a).c_str());
    if (auto* t = a->Cast<const typespec*>()) {
      auto* rs = rangesOf(a);
      if (rs && !rs->empty())
        printf("  RANGE0 id=%u L=%s R=%s\n", (unsigned)(*rs)[0]->UhdmId(),
               shp((*rs)[0]->Left_expr()).c_str(),
               shp((*rs)[0]->Right_expr()).c_str());
      auto* al = t->Typedef_alias();
      printf("  ALIAS %s\n", al ? (node(al) + " -> " +
             (al->Actual_typespec() ? node(al->Actual_typespec())
                                    : std::string("<null>"))).c_str()
                                : "<none>");
      printf("  INSTANCE %s\n", t->Instance() ? node(t->Instance()).c_str() : "<none>");
    }
    auto it = refs.find((const BaseClass*)a);
    if (it != refs.end())
      for (auto* rt : it->second)
        printf("  <- ref %s full=%s\n     ctx %s\n", node(rt).c_str(),
               std::string(rt->VpiFullName()).c_str(), chainOf(rt).c_str());
  }
  return 0;
}
