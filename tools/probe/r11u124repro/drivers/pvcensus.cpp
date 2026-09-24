// pvcensus: for every param_assign whose Lhs is a parameter, print
// <view> <param fullname> <param VpiValue> <Rhs type> <Rhs VpiValue> <Rhs consttype>
// view = the enclosing top object kind (package/module_inst/...) from the parent chain.
// Measurement only (r11u124).
#include <uhdm/Serializer.h>
#include <uhdm/VpiListener.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_visitor.h>
#include <iostream>
#include <memory>
#include <set>
#include <string>
#include <vector>
namespace {
class L : public UHDM::VpiListener {
 public:
  std::set<const UHDM::any*> seen;
  std::set<const UHDM::any*> defs;
  void enterDesign(const UHDM::design* d, vpiHandle) override {
    if (d->AllModules()) for (auto* m : *d->AllModules()) defs.insert(m);
    if (d->AllInterfaces()) for (auto* m : *d->AllInterfaces()) defs.insert(m);
  }
  std::set<const UHDM::any*> seenP;
  void listParams(const UHDM::BaseClass* sc, const UHDM::VectorOfany* ps) {
    if (!ps || !seenP.insert(sc).second) return;
    std::string view = UHDM::UhdmName(sc->UhdmType());
    if (defs.count((const UHDM::any*)sc)) view = "def_" + view;
    std::string vdef(sc->VpiDefName().empty() ? sc->VpiName() : sc->VpiDefName());
    for (auto* a : *ps) {
      if (a->UhdmType() != UHDM::uhdmparameter) continue;
      auto* p = (const UHDM::parameter*)a;
      std::cout << "PL:" << view << "\t" << p->VpiFullName() << "\t" << (p->VpiValue().empty() ? "-" : std::string(p->VpiValue()))
                << "\t-\t-\t-\t" << (p->VpiParent() == sc ? "own" : "foreign") << "\t" << vdef << "\tdirect\t" << p->VpiName() << "\n";
    }
  }
  void enterModule_inst(const UHDM::module_inst* o, vpiHandle) override { listParams(o, o->Parameters()); }
  void enterInterface_inst(const UHDM::interface_inst* o, vpiHandle) override { listParams(o, o->Parameters()); }
  void enterPackage(const UHDM::package* o, vpiHandle) override { listParams(o, o->Parameters()); }
  void enterClass_defn(const UHDM::class_defn* o, vpiHandle) override { listParams(o, o->Parameters()); }
  void enterParam_assign(const UHDM::param_assign* pa, vpiHandle) override {
    if (!seen.insert(pa).second) return;
    const UHDM::any* l = pa->Lhs();
    if (!l || l->UhdmType() != UHDM::uhdmparameter) return;
    auto* p = (const UHDM::parameter*)l;
    const UHDM::any* r = pa->Rhs();
    std::string view = "?";
    std::string vdef = "?";
    bool direct = false;
    for (const UHDM::BaseClass* q = pa->VpiParent(); q; q = q->VpiParent()) {
      view = UHDM::UhdmName(q->UhdmType());
      if (q->UhdmType() == UHDM::uhdmpackage || q->UhdmType() == UHDM::uhdmmodule_inst ||
          q->UhdmType() == UHDM::uhdminterface_inst || q->UhdmType() == UHDM::uhdmgen_scope ||
          q->UhdmType() == UHDM::uhdmclass_defn || q->UhdmType() == UHDM::uhdmfunction) {
        if (defs.count((const UHDM::any*)q)) view = "def_" + view;
        vdef = std::string(q->VpiDefName().empty() ? q->VpiName() : q->VpiDefName());
        direct = (q == pa->VpiParent());
        break;
      }
    }
    std::string rt = r ? UHDM::UhdmName(r->UhdmType()) : "null";
    std::string rv, rc;
    if (r && r->UhdmType() == UHDM::uhdmconstant) {
      auto* c = (const UHDM::constant*)r;
      rv = std::string(c->VpiValue());
      rc = std::to_string(c->VpiConstType());
    }
    std::cout << view << "\t" << p->VpiFullName() << "\t" << (p->VpiValue().empty() ? "-" : std::string(p->VpiValue()))
              << "\t" << rt << "\t" << (rv.empty() ? "-" : rv) << "\t" << rc << "\t"
              << (p->VpiParent() == pa ? "lhsParentPA" : "lhsParentOther") << "\t" << vdef << "\t" << (direct ? "direct" : "nested") << "\t" << p->VpiName() << "\n";
  }
};
}  // namespace
int main(int argc, char** argv) {
  if (argc < 2) return 3;
  auto ser = std::make_unique<UHDM::Serializer>();
  std::vector<vpiHandle> h = ser->Restore(std::string(argv[1]));
  L l;
  l.listenDesigns(h);
  return 0;
}
