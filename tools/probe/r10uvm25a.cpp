// r10uvm25a — package-view census: Class_defns count, and for each class
// whether ANY class_typespec in the package's own Typespecs listing or in any
// class's Typespecs listing targets it (the § importPublishesPackageClasses24
// "representative").  Reads the DEF (AllPackages) and ELAB (TopPackages) views
// separately so the def-view arm's gap is measurable.
//   r10uvm25a <file.uhdm> <pkgName> [--miss]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <set>
#include <string>
using namespace UHDM;

static void census(const char* tag, const package* p, bool miss) {
    size_t nc = p->Class_defns() ? p->Class_defns()->size() : 0;
    std::map<const class_defn*, const typespec*> rep;
    auto scan = [&](const VectorOftypespec* v) {
        if (!v) return;
        for (auto* t : *v) {
            if (!t || t->UhdmType() != uhdmclass_typespec) continue;
            if (auto* cd = ((const class_typespec*)t)->Class_defn())
                rep.emplace(cd, t);
        }
    };
    scan(p->Typespecs());
    size_t ownTs = 0;
    if (p->Class_defns())
        for (auto* c : *p->Class_defns())
            if (c) { scan(c->Typespecs()); if (c->Typespecs()) ownTs += c->Typespecs()->size(); }
    size_t hit = 0, nomiss = 0;
    if (p->Class_defns())
        for (auto* c : *p->Class_defns()) {
            if (!c || c->VpiName().empty()) continue;
            if (rep.count(c)) hit++;
            else {
                nomiss++;
                if (miss) std::cout << tag << " NOREP " << c->VpiName() << "\n";
            }
        }
    std::cout << tag << " classes=" << nc << " ownTsTotal=" << ownTs
              << " pkgTs=" << (p->Typespecs() ? p->Typespecs()->size() : 0)
              << " withRep=" << hit << " noRep=" << nomiss << "\n";
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    std::string want = argc > 2 ? argv[2] : "";
    bool miss = argc > 3 && std::string(argv[3]) == "--miss";
    auto go = [&](const VectorOfpackage* v, const char* tag) {
        if (!v) return;
        for (auto* p : *v)
            if (want.empty() || std::string(p->VpiName()) == want)
                census((std::string(tag) + "[" + std::string(p->VpiName()) + "]").c_str(), p, miss);
    };
    go(d->AllPackages(), "DEFPKG");
    go(d->TopPackages(), "ELABPKG");
    return 0;
}
