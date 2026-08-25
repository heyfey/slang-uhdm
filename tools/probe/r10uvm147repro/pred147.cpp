// r10uvm147 — the A-PRIORI MOVER PREDICTOR.  MEASUREMENT-ONLY.
//
// Run over a PRISTINE database, BEFORE the patched sweep.  Prints one line per
// candidate object and a final COUNT.  A database with COUNT > 0 is predicted
// to move; a database with COUNT == 0 must not move.
//
// The signature is OURS-SIDE and deliberately an OVER-APPROXIMATION of
// § selChainElemShapeIsSyntactic147: a `hier_path` PATH ELEMENT that is a
// `part_select` or an `indexed_part_select` whose own `VpiName` CONTAINS a '['
// — i.e. the FLAT shape the emitter mints when a member's whole select chain
// (one or more index steps plus a trailing range) collapses into one object
// named `member[idx]`.  Every cell the law converts has this shape; the cells
// it deliberately leaves alone (an ArbitrarySymbol / HierarchicalValue base —
// README R1) have it too, which is what makes the set an over-approximation
// rather than a restatement of the patch.
//
// usage: pred147 <db.uhdm>
// build: g++ -O2 -std=c++17 pred147.cpp -I ~/.local/include \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o pred147
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
#include <vector>
#include <algorithm>
using namespace UHDM;

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: pred147 <db.uhdm>\n"); return 2; }
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "RESTORE_FAILED %s\n", argv[1]); return 3; }
  auto all = s.AllObjects();
  std::vector<std::string> hits;
  for (auto& pr : all) {
    const BaseClass* o = pr.first;
    if (!o || o->UhdmType() != uhdmhier_path) continue;
    auto* hp = (const hier_path*)o;
    auto* el = hp->Path_elems();
    if (!el) continue;
    for (auto* e : *el) {
      if (!e) continue;
      UHDM_OBJECT_TYPE t = e->UhdmType();
      if (t != uhdmpart_select && t != uhdmindexed_part_select) continue;
      std::string n(e->VpiName());
      if (n.find('[') == std::string::npos) continue;
      char b[4096];
      snprintf(b, sizeof b, "%u:%u\t%s\t%s", e->VpiLineNo(), e->VpiColumnNo(),
               n.c_str(), std::string(hp->VpiName()).c_str());
      hits.push_back(b);
    }
  }
  std::sort(hits.begin(), hits.end());
  for (auto& h : hits) printf("%s\n", h.c_str());
  printf("COUNT %zu\n", hits.size());
  return 0;
}
