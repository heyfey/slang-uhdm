// r11u118 — why is uhdm-cmp blind?  MEASUREMENT ONLY.
// Runs the official design::Compare (as uhdm-cmp does), then reports, for each
// golden object of the named kind, whether the official walk VISITED it, and
// re-compares every golden/ours pair of that kind at the same span with a
// FRESH context (what the judge would say if it reached the pair unvisited).
// usage: r11u118why <golden.uhdm> <ours.uhdm> <uhdm kind name, e.g. part_select>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;
static std::string sp(const any* o) {
  return std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo()) + "-" +
         std::to_string(o->VpiEndLineNo()) + ":" + std::to_string(o->VpiEndColumnNo());
}
int main(int argc, char** argv) {
  Serializer a, b;
  auto ha = a.Restore(std::string(argv[1]));
  auto hb = b.Restore(std::string(argv[2]));
  const design* da = UhdmDesignFromVpiHandle(ha.at(0));
  const design* db = UhdmDesignFromVpiHandle(hb.at(0));
  CompareContext ctx;
  int r = da->Compare(db, &ctx);
  std::cout << "official r=" << r << " visited=" << ctx.m_visited.size() << "\n";
  std::string kind = argv[3];
  std::vector<const any*> ga, gb;
  for (auto& kv : a.AllObjects()) if (UhdmName(kv.first->UhdmType()) == kind) ga.push_back(kv.first);
  for (auto& kv : b.AllObjects()) if (UhdmName(kv.first->UhdmType()) == kind) gb.push_back(kv.first);
  for (auto* g : ga) {
    bool vis = ctx.m_visited.count(g);
    std::cout << "golden " << kind << "#" << g->UhdmId() << " " << sp(g) << " name='" << g->VpiName()
              << "' parent=" << (g->VpiParent() ? std::string(UhdmName(g->VpiParent()->UhdmType())) + "#" + std::to_string(g->VpiParent()->UhdmId()) : "NULL")
              << " visitedByOfficial=" << vis << "\n";
    for (auto* o : gb) {
      if (o->VpiLineNo() != g->VpiLineNo()) continue;
      CompareContext c2;
      int r2 = g->Compare(o, &c2);
      std::cout << "   vs ours#" << o->UhdmId() << " " << sp(o) << " name='" << o->VpiName() << "' fresh r=" << r2;
      if (r2 && c2.m_failedLhs) std::cout << " failedLhs=" << UhdmName(c2.m_failedLhs->UhdmType()) << " '" << c2.m_failedLhs->VpiName() << "'";
      std::cout << "\n";
    }
  }
  return 0;
}
