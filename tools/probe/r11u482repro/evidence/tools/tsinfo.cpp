// tsinfo <db> <name>: every typespec named <name> (or every struct/union/enum typespec when <name>
// is '*'): its id, kind, parent, instance and span, every ref_typespec that binds it (with the
// ref's parent chain) and every instance/package whose vpiTypedef lists it.  Measurement only.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
#include <algorithm>
#include <vector>
using namespace UHDM;
static std::string d(const any* o) {
  if (!o) return "null";
  std::string n(o->VpiName());
  return std::string(UhdmName(o->UhdmType())) + "(" + n + ")#" + std::to_string(o->UhdmId());
}
static std::string chain(const any* o, int k) {
  std::string r;
  for (int i = 0; o && i < k; ++i, o = o->VpiParent()) r += (i ? " <- " : "") + d(o);
  return r;
}
int main(int argc, char** argv) {
  Serializer s; s.Restore(std::filesystem::path(argv[1]));
  std::string want = argv[2];
  std::map<const any*, std::vector<const any*>> refs, lists;
  std::vector<const typespec*> tss;
  for (auto& kv : s.AllObjects()) {
    auto* o = (const any*)kv.first;
    if (o->UhdmType() == uhdmref_typespec) {
      auto* r = (const ref_typespec*)o;
      if (r->Actual_typespec()) refs[r->Actual_typespec()].push_back(r);
    }
    if (auto* sc = dynamic_cast<const scope*>(o))
      if (sc->Typespecs()) for (auto* t : *sc->Typespecs()) lists[t].push_back(o);
    if (auto* t = dynamic_cast<const typespec*>(o)) {
      bool agg = t->UhdmType() == uhdmstruct_typespec || t->UhdmType() == uhdmunion_typespec ||
                 t->UhdmType() == uhdmenum_typespec;
      if (want == "*" ? agg : std::string(t->VpiName()) == want) tss.push_back(t);
    }
  }
  std::sort(tss.begin(), tss.end(), [](auto* a, auto* b) { return a->UhdmId() < b->UhdmId(); });
  for (auto* t : tss) {
    std::cout << d(t) << " " << t->VpiLineNo() << ":" << t->VpiColumnNo() << " parent=" << chain(t->VpiParent(), 4)
              << " inst=" << d(t->Instance()) << "\n";
    for (auto* l : lists[t]) std::cout << "    listedBy " << d(l) << "\n";
    for (auto* r : refs[t]) std::cout << "    ref " << chain(r, 5) << "\n";
  }
}
