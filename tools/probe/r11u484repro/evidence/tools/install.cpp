// install <db>: one line per object carrying a vpiInstance that is a package: kind, name, span, the
// view (top or all) of its nearest enclosing package, and the view of its instance.  Measurement only.
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
    const instance* in = nullptr;
    if (auto* t = dynamic_cast<const typespec*>(o)) in = t->Instance();
    else if (auto* f = dynamic_cast<const task_func*>(o)) in = f->Instance();
    else if (auto* v = dynamic_cast<const variables*>(o)) in = v->Instance();
    else if (!(o->VpiParent() && o->VpiParent()->UhdmType() == uhdmpackage)) continue;
    if (!in || in->UhdmType() != uhdmpackage) in = nullptr;
    const any* dp = o->VpiParent();
    if (!in && !(dp && dp->UhdmType() == uhdmpackage)) continue;
    const any* p = o->VpiParent();
    while (p && p->UhdmType() != uhdmpackage) p = p->VpiParent();
    std::cout << UhdmName(o->UhdmType()) << " " << o->VpiName() << " " << o->VpiLineNo() << ":" << o->VpiColumnNo()
              << " | in=" << (p ? std::string(p->VpiName()) + (top.count(p) ? "(top)" : "(all)") : std::string("-"))
              << " | inst=" << (in ? std::string(in->VpiName()) + (top.count(in) ? "(top)" : "(all)") : std::string("-"))
              << " | dparent=" << (dp && dp->UhdmType() == uhdmpackage ? std::string(dp->VpiName()) + (top.count(dp) ? "(top)" : "(all)") : std::string("-")) << "\n";
  }
}
