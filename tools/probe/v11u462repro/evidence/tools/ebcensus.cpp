// ebcensus <db.uhdm>: one line per enum_typespec with an unnamed base:
//   enum name | enum vpiInstance view:name | base vpiInstance view:name   (sorted; for multiset diffs)
#include <uhdm/uhdm.h>
#include <filesystem>
#include <iostream>
#include <set>
#include <vector>
#include <algorithm>
using namespace UHDM;
int main(int argc, char** argv) {
  Serializer s; auto h = s.Restore(std::filesystem::path(argv[1]));
  if (h.empty()) return 1;
  auto* d = (design*)((uhdm_handle*)h[0])->object;
  std::set<const any*> defs, tops;
  if (d->AllPackages()) for (auto* p : *d->AllPackages()) defs.insert(p);
  if (d->TopPackages()) for (auto* p : *d->TopPackages()) tops.insert(p);
  auto ik = [&](const any* i) {
    if (!i) return std::string("null");
    std::string k = defs.count(i) ? "DEF" : tops.count(i) ? "TOP" : std::string(UhdmName(i->UhdmType()));
    return k + ":" + std::string(i->VpiName());
  };
  std::vector<std::string> out;
  for (auto& kv : s.AllObjects()) {
    auto* b = (const BaseClass*)kv.first;
    if (b->UhdmType() != uhdmenum_typespec) continue;
    auto* e = (const enum_typespec*)b;
    auto* br = e->Base_typespec();
    if (!br || !br->Actual_typespec()) continue;
    auto* bt = br->Actual_typespec();
    if (!bt->VpiName().empty()) continue;
    out.push_back(std::string(e->VpiName()) + " | " + ik(e->Instance()) + " | " + ik(bt->Instance()));
  }
  std::sort(out.begin(), out.end());
  for (auto& l : out) std::cout << l << "\n";
}
