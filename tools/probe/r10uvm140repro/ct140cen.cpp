// r10uvm140 — THE LAW'S CORPUS CENSUS, golden vs ours, over ONE pair of
// databases.  LHS IS ALWAYS GOLDEN.  MEASUREMENT ONLY — the judge is the
// official uhdm-cmp.
//
// Population: every `function` whose RETURN variable's ref_typespec binds an
// enum_typespec or a struct_typespec (the two kinds
// § retNamedTdWinsOverCanon140 gates on).  A cell is keyed by the function's
// VpiFullName and its value is the SORTED MULTISET of bound typespec NAMES
// across that name's copies, so a DEF/ELAB duplicate cannot be dropped by a
// last-writer map (a slot-keyed census would be blind below the slot).
//
// vpiParent is deliberately NOT in the key: no generated Compare reads it, so
// where an object hangs is invisible to the judge; the NAME and the
// Typedef_alias are what typespec::Compare walks.
//
// Rows:  DIFF <label> <function> GOLD=<names> OURS=<names>
//        ONLY-GOLD / ONLY-OURS  <label> <function> <names>
// Tail:  CEN <label> cells=<n> same=<n> diff=<n> onlygold=<n> onlyours=<n>
//
//   usage: ct140cen <golden.uhdm> <ours.uhdm> [<label>]
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <uhdm/vpi_uhdm.h>
#include <algorithm>
#include <cstdio>
#include <map>
#include <set>
#include <string>
#include <vector>
using namespace UHDM;

typedef std::map<std::string, std::vector<std::string>> Cen;

static bool build(const char* path, Cen& out) {
  Serializer s;
  auto restored = s.Restore(std::string(path));
  if (restored.empty()) return false;
  for (auto& kv : s.AllObjects()) {
    const any* a = (const any*)kv.first;
    if (!a || a->UhdmType() != uhdmfunction) continue;
    const function* f = (const function*)a;
    const variables* rv = f->Return();
    if (!rv) continue;
    const ref_typespec* rt = rv->Typespec();
    if (!rt) continue;
    const typespec* act = rt->Actual_typespec();
    if (!act) continue;
    UHDM_OBJECT_TYPE k = act->UhdmType();
    if (k != uhdmenum_typespec && k != uhdmstruct_typespec) continue;
    std::string key(f->VpiFullName());
    if (key.empty()) key = std::string(f->VpiName());
    out[key].push_back(std::string(UhdmName(k)) + ":" +
                       std::string(act->VpiName()));
  }
  for (auto& e : out) std::sort(e.second.begin(), e.second.end());
  return true;
}

static std::string join(const std::vector<std::string>& v) {
  std::string r;
  for (size_t i = 0; i < v.size(); ++i) { if (i) r += ","; r += v[i]; }
  return r;
}

int main(int argc, char** argv) {
  if (argc < 3) { fprintf(stderr, "usage: ct140cen <golden> <ours> [label]\n"); return 2; }
  std::string label = argc > 3 ? argv[3] : argv[2];
  Cen G, O;
  if (!build(argv[1], G)) { printf("EMPTY-GOLD\t%s\n", label.c_str()); return 3; }
  if (!build(argv[2], O)) { printf("EMPTY-OURS\t%s\n", label.c_str()); return 3; }
  std::set<std::string> keys;
  for (auto& e : G) keys.insert(e.first);
  for (auto& e : O) keys.insert(e.first);
  int same = 0, diff = 0, og = 0, oo = 0;
  for (const std::string& k : keys) {
    auto gi = G.find(k), oi = O.find(k);
    if (gi == G.end()) {
      oo++;
      printf("ONLY-OURS\t%s\t%s\t%s\n", label.c_str(), k.c_str(), join(oi->second).c_str());
    } else if (oi == O.end()) {
      og++;
      printf("ONLY-GOLD\t%s\t%s\t%s\n", label.c_str(), k.c_str(), join(gi->second).c_str());
    } else if (gi->second == oi->second) {
      same++;
    } else {
      diff++;
      printf("DIFF\t%s\t%s\tGOLD=%s\tOURS=%s\n", label.c_str(), k.c_str(),
             join(gi->second).c_str(), join(oi->second).c_str());
    }
  }
  printf("CEN\t%s\tcells=%d\tsame=%d\tdiff=%d\tonlygold=%d\tonlyours=%d\n",
         label.c_str(), (int)keys.size(), same, diff, og, oo);
  return 0;
}
