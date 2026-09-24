// refbind: for every ref_obj reached in the ELABORATED tree (topModules),
// prints the ref's walk context and which object its Actual_group is:
// DEF = an object listed under a definition (allModules / allInterfaces
// subtree), ELAB = anything else. Measurement only (r11u131; copied by r11u139, which also prints the Actual's own full name).
// Usage: refbind <db.uhdm>
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
std::set<const UHDM::any*> defObjs;
class Collect : public UHDM::VpiListener {
 public:
  void enterAny(const UHDM::any* o, vpiHandle) override { defObjs.insert(o); }
};
std::string sp(const UHDM::any* o) {
  return std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo()) + "-" +
         std::to_string(o->VpiEndLineNo()) + ":" + std::to_string(o->VpiEndColumnNo());
}
class L : public UHDM::VpiListener {
 public:
  bool inTop = false;
  void enterAny(const UHDM::any* o, vpiHandle h) override {
    const auto ty = o->UhdmType();
    if (ty != UHDM::uhdmref_obj && ty != UHDM::uhdmbit_select && ty != UHDM::uhdmpart_select &&
        ty != UHDM::uhdmindexed_part_select && ty != UHDM::uhdmvar_select)
      return;
    // only under topModules: the first callstack entry after design is a
    // module_inst with a name (elaborated)
    bool elab = false;
    for (auto* a : callstack)
      if ((a->UhdmType() == UHDM::uhdmmodule_inst || a->UhdmType() == UHDM::uhdminterface_inst) &&
          !a->VpiName().empty()) { elab = true; break; }
    if (!elab) return;
    auto* r = (const UHDM::ref_obj*)o;
    const UHDM::any* act = r->Actual_group();
    std::string ctx;
    for (int i = (int)callstack.size() - 2, n = 0; i >= 0 && n < 5; --i, ++n) {
      ctx += std::string(n ? "<" : "") + UHDM::UhdmName(callstack[i]->UhdmType());
      if (!callstack[i]->VpiName().empty()) ctx += "(" + std::string(callstack[i]->VpiName()) + ")";
    }
    std::string a = "-";
    if (act) {
      a = std::string(UHDM::UhdmName(act->UhdmType())) + (defObjs.count(act) ? " DEF" : " ELAB");
      if (act->VpiParent()) a += " par=" + std::string(UHDM::UhdmName(act->VpiParent()->UhdmType())) + "(" + std::string(act->VpiParent()->VpiName()) + ")";
      a += " @" + std::to_string(act->VpiLineNo()) + ":" + std::to_string(act->VpiColumnNo());
      if (act->UhdmType() == UHDM::uhdmlogic_net || act->UhdmType() == UHDM::uhdmarray_net)
        a += ((const UHDM::nets*)act)->Typespec() ? " ts" : " nots";
    }
    const char* fn = vpi_get_str(vpiFullName, h);
    std::cout << (ty == UHDM::uhdmref_obj ? std::string() : std::string(UHDM::UhdmName(ty)) + ":") << r->VpiName() << "\t" << sp(o) << "\t" << (fn ? fn : "") << "\t" << a << "\t" << ctx << "\n";
  }
};
}  // namespace
int main(int argc, char** argv) {
  if (argc < 2) return 3;
  auto ser = std::make_unique<UHDM::Serializer>();
  std::vector<vpiHandle> h = ser->Restore(std::string(argv[1]));
  for (auto dh : h) {
    auto* d = (const UHDM::design*)((const uhdm_handle*)dh)->object;
    Collect c;
    if (d->AllModules()) for (auto* m : *d->AllModules()) { vpiHandle mh = NewVpiHandle(m); c.listenAny(mh); vpi_free_object(mh); }
    if (d->AllInterfaces()) for (auto* m : *d->AllInterfaces()) { vpiHandle mh = NewVpiHandle(m); c.listenAny(mh); vpi_free_object(mh); }
  }
  L l;
  l.listenDesigns(h);
  return 0;
}
