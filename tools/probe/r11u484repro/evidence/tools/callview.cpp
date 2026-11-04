// callview <db>: one line per func_call / task_call bound to a package subroutine: call name, span
// and the view (top or all) of the package holding the bound subroutine.  Measurement only.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <set>
using namespace UHDM;
int main(int, char** argv) {
  Serializer s; auto ds = s.Restore(std::filesystem::path(argv[1]));
  std::set<const any*> top;
  for (auto h : ds) {
    auto* d = (const design*)((uhdm_handle*)h)->object;
    if (d->TopPackages()) for (auto* p : *d->TopPackages()) top.insert(p);
  }
  for (auto& kv : s.AllObjects()) {
    auto* o = (const any*)kv.first;
    const any* f = nullptr;
    if (o->UhdmType() == uhdmfunc_call) f = ((const func_call*)o)->Function();
    else if (o->UhdmType() == uhdmtask_call) f = ((const task_call*)o)->Task();
    if (!f) continue;
    const any* p = f->VpiParent();
    while (p && p->UhdmType() != uhdmpackage) p = p->VpiParent();
    if (!p) continue;
    std::cout << UhdmName(o->UhdmType()) << " " << o->VpiName() << " " << o->VpiLineNo() << ":" << o->VpiColumnNo()
              << " -> " << f->VpiName() << " in " << p->VpiName() << (top.count(p) ? "(top)" : "(all)") << "\n";
  }
}
