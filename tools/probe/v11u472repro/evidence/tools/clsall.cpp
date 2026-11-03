// clsall <db>: every class_defn's subroutine listing, reached from every container
// (package views, module views, interfaces, programs, design classes, nested modules
// and interfaces via instance trees), one line per entry: container path, class, index,
// subroutine name, its parent kind:name.  Diff golden against ours for order.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <set>
using namespace UHDM;
static std::set<const any*> seen;
static void cls(const std::string& where, const VectorOfclass_defn* v) {
  if (!v) return;
  for (auto* c : *v) {
    std::string cw = where + "::" + std::string(c->VpiName());
    if (c->Task_funcs()) {
      int i = 0;
      for (auto* t : *c->Task_funcs()) {
        auto* p = t->VpiParent();
        std::cout << cw << " [" << i++ << "] " << t->VpiName() << " < "
                  << (p ? std::string(UhdmName(p->UhdmType())) + ":" + std::string(p->VpiName()) : "null") << "\n";
      }
    } else std::cout << cw << " (no task_funcs)\n";
  }
}
static void inst(const std::string& where, const instance* x) {
  if (!x) return;
  std::string w = where + "/" + std::string(UhdmName(x->UhdmType())) + ":" + std::string(x->VpiName());
  cls(w, x->Class_defns());
  if (x->UhdmType() == uhdmmodule_inst) {
    auto* m = (const module_inst*)x;
    if (m->Modules()) for (auto* s : *m->Modules()) inst(w, s);
    if (m->Interfaces()) for (auto* s : *m->Interfaces()) inst(w, s);
  }
}
int main(int argc, char** argv) {
  Serializer s; auto h = s.Restore(std::filesystem::path(argv[1]));
  auto* d = (design*)((uhdm_handle*)h[0])->object;
  if (d->AllPackages()) for (auto* p : *d->AllPackages()) inst("allpkg", p);
  if (d->TopPackages()) for (auto* p : *d->TopPackages()) inst("toppkg", p);
  if (d->AllModules()) for (auto* p : *d->AllModules()) inst("allmod", p);
  if (d->AllInterfaces()) for (auto* p : *d->AllInterfaces()) inst("allifc", p);
  if (d->AllPrograms()) for (auto* p : *d->AllPrograms()) inst("allprg", p);
  if (d->TopModules()) for (auto* p : *d->TopModules()) inst("top", p);
  cls("design", d->AllClasses());
}
