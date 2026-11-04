// tsinst <db>: one line per typespec that carries a vpiInstance: kind, name, span, the kinds and
// names of three parents, and the instance's name with its view (top or all).  Sort and diff two
// databases to find a vpiInstance face.  Measurement only.
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
    if (d->TopModules()) for (auto* p : *d->TopModules()) top.insert(p);
  }
  for (auto& kv : s.AllObjects()) {
    auto* t = dynamic_cast<const typespec*>((const any*)kv.first);
    if (!t || !t->Instance()) continue;
    std::cout << UhdmName(t->UhdmType()) << " " << t->VpiName() << " " << t->VpiLineNo() << ":" << t->VpiColumnNo() << " |";
    const any* p = t->VpiParent();
    for (int i = 0; p && i < 4; ++i, p = p->VpiParent()) std::cout << " " << UhdmName(p->UhdmType()) << "(" << p->VpiName() << ")";
    std::cout << " | inst=" << t->Instance()->VpiName() << (top.count(t->Instance()) ? "(top)" : "(all)") << "\n";
  }
}
