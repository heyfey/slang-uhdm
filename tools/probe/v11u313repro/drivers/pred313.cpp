// v11u313 pred313 <db.uhdm>...: the structural trigger of pass 313's laws read from a PRISTINE database (written
// before the law sweep): GEN = an interface_inst whose vpiParent is a gen_scope (GENIFCONN, GENIFBIRTH,
// GENIFHCUNBIND reach it); SEL = an interface_inst port whose High_conn is a bit_select, indexed_part_select,
// operation or a hier_path of two or more elements (HCSELINST); DUP = a column-0 interface_inst duplicate whose
// name equals a gen_scope interface's (GENIFBIRTH re-parents it). One line per database with counts. Fail-closed on $FENCED.
#include <uhdm/uhdm.h>
#include <uhdm/VpiListener.h>
#include <iostream>
#include <regex>
#include <set>
#include <map>
#include <cstdlib>
#include <vector>
using namespace UHDM;
struct L : VpiListener {
  std::set<const any*> seen; int gen = 0, sel = 0, genSel = 0;
  void enterAny(const any* o, vpiHandle) override {
    if (!seen.insert(o).second) return;
    if (o->UhdmType() != uhdminterface_inst) return;
    auto* ii = (const interface_inst*)o;
    bool g = ii->VpiParent() && ii->VpiParent()->UhdmType() == uhdmgen_scope;
    if (g) gen++;
    if (auto* ps = ii->Ports())
      for (auto* p : *ps) {
        auto* h = p->High_conn(); if (!h) continue;
        auto t = h->UhdmType();
        bool s = t == uhdmbit_select || t == uhdmindexed_part_select || t == uhdmoperation ||
                 (t == uhdmhier_path && ((const hier_path*)h)->Path_elems() && ((const hier_path*)h)->Path_elems()->size() > 1);
        if (s) { sel++; if (g) genSel++; }
      }
  }
};
int main(int argc, char** argv) {
  const char* fz = getenv("FENCED");
  if (!fz) { std::cerr << "pred313: FENCED unset\n"; return 2; }
  std::vector<std::string> fn; { std::string w; for (const char* c = fz;; ++c) { if (!*c || *c == ' ') { if (!w.empty()) fn.push_back(w); w.clear(); if (!*c) break; } else w += *c; } }
  if (fn.size() != 4) { std::cerr << "pred313: FENCED not 4 names\n"; return 2; }
  for (int i = 1; i < argc; i++) {
    std::string a(argv[i]); bool bad = false;
    for (auto& f : fn) if (std::regex_search(a, std::regex("(^|[^A-Za-z0-9_])" + f + "([^A-Za-z0-9_]|$)"))) bad = true;
    if (bad) { std::cerr << "pred313: fenced path refused\n"; return 2; }
    Serializer s; std::vector<vpiHandle> d = s.Restore(a);
    L l; l.listenDesigns(d);
    if (l.gen || l.sel) std::cout << a << " GEN=" << l.gen << " SEL=" << l.sel << " GENSEL=" << l.genSel << "\n";
    std::cout.flush();
  }
  return 0;
}
