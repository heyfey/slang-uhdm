// r11u231: every typespec whose Instance is a package, with the listing that holds it (def/top/none),
// its name, span and the Instance package's view (def = AllPackages member, top = TopPackages member).
// Usage: tsinst <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <cstdio>
#include <set>
#include <map>
using namespace UHDM;
int main(int argc, char** argv) {
  Serializer s;
  auto designs = s.Restore(std::string(argv[1]));
  std::set<const BaseClass*> defP, topP;
  std::map<const BaseClass*, std::string> listing;
  for (auto* dh : designs) { const design* d = UhdmDesignFromVpiHandle(dh);
    if (d->AllPackages()) for (auto* p : *d->AllPackages()) { defP.insert(p); if (p->Typespecs()) for (auto* t : *p->Typespecs()) listing[t] = "deflist"; }
    if (d->TopPackages()) for (auto* p : *d->TopPackages()) { topP.insert(p); if (p->Typespecs()) for (auto* t : *p->Typespecs()) listing[t] = "toplist"; }
  }
  for (auto& pr : s.AllObjects()) {
    auto* o = pr.first; if (!o) continue;
    auto* t = any_cast<const typespec*>(o); if (!t) continue;
    auto* in = t->Instance(); if (!in || in->UhdmType() != uhdmpackage) continue;
    const char* iv = defP.count(in) ? "def" : topP.count(in) ? "top" : "other";
    auto it = listing.find(t);
    const BaseClass* par = t->VpiParent();
    printf("%s %s %u:%u-%u:%u %s inst=%s:%s par=%s\n", it == listing.end() ? "unlisted" : it->second.c_str(),
           std::string(t->VpiName()).c_str(), t->VpiLineNo(), t->VpiColumnNo(), t->VpiEndLineNo(), t->VpiEndColumnNo(),
           UhdmName(t->UhdmType()).data(), iv, std::string(in->VpiName()).c_str(),
           par ? (std::string(UhdmName(par->UhdmType())) + ":" + (defP.count(par) ? "def" : topP.count(par) ? "top" : std::string(par->VpiName()))).c_str() : "-");
  }
}
