// aliasview <db>: one line per typespec carrying a vpiTypedefAlias: kind, name, span, its own
// instance's view and the alias target's name and instance view (top or all).  Measurement only.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <set>
using namespace UHDM;
static std::set<const any*> top;
static std::string view(const any* i) { return i ? std::string(i->VpiName()) + (top.count(i) ? "(top)" : "(all)") : "-"; }
int main(int, char** argv) {
  Serializer s; auto ds = s.Restore(std::filesystem::path(argv[1]));
  for (auto h : ds) {
    auto* d = (const design*)((uhdm_handle*)h)->object;
    if (d->TopPackages()) for (auto* p : *d->TopPackages()) top.insert(p);
    if (d->TopModules()) for (auto* p : *d->TopModules()) top.insert(p);
  }
  for (auto& kv : s.AllObjects()) {
    auto* t = dynamic_cast<const typespec*>((const any*)kv.first);
    if (!t) continue;
    const ref_typespec* al = nullptr;
    switch (t->UhdmType()) {
      case uhdmstruct_typespec: al = ((const struct_typespec*)t)->Typedef_alias(); break;
      case uhdmunion_typespec: al = ((const union_typespec*)t)->Typedef_alias(); break;
      case uhdmenum_typespec: al = ((const enum_typespec*)t)->Typedef_alias(); break;
      case uhdmlogic_typespec: al = ((const logic_typespec*)t)->Typedef_alias(); break;
      case uhdmbit_typespec: al = ((const bit_typespec*)t)->Typedef_alias(); break;
      case uhdmint_typespec: al = ((const int_typespec*)t)->Typedef_alias(); break;
      default: break;
    }
    if (!al || !al->Actual_typespec()) continue;
    auto* x = al->Actual_typespec();
    const any* p = t->VpiParent();
    std::cout << UhdmName(t->UhdmType()) << " " << t->VpiName() << " " << t->VpiLineNo() << ":" << t->VpiColumnNo()
              << " par=" << (p ? UhdmName(p->UhdmType()) : "-") << " inst=" << view(t->Instance()) << " -> " << x->VpiName()
              << " inst=" << view(x->Instance()) << " par=" << (x->VpiParent() ? UhdmName(x->VpiParent()->UhdmType()) : "-") << "\n";
  }
}
