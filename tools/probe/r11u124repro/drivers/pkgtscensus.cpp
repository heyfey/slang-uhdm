// pkgtscensus: every typespec in each package's Typespecs() listing, for
// the AllPackages (def) and TopPackages (top) views: view, package, kind,
// name, vpiParent kind (NULL when unset). Measurement only (r11u124).
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <iostream>
#include <memory>
#include <string>
#include <vector>
int main(int argc, char** argv) {
  if (argc < 2) return 3;
  auto ser = std::make_unique<UHDM::Serializer>();
  std::vector<vpiHandle> hs = ser->Restore(std::string(argv[1]));
  for (auto h : hs) {
    const auto* d = (const UHDM::design*)((const uhdm_handle*)h)->object;
    int vi = 0;
    for (auto* pv : {d->AllPackages(), d->TopPackages()}) {
      const char* view = vi++ ? "top" : "def";
      if (!pv) continue;
      for (auto* p : *pv) {
        if (!p->Typespecs()) continue;
        for (auto* t : *p->Typespecs()) {
          std::string par = t->VpiParent() ? UHDM::UhdmName(t->VpiParent()->UhdmType()) : "NULL";
          if (t->VpiParent() == p) par = "PKG";
          std::cout << view << "\t" << p->VpiName() << "\t" << UHDM::UhdmName(t->UhdmType()) << "\t" << t->VpiName() << "\t" << par << "\n";
        }
      }
    }
  }
  return 0;
}
