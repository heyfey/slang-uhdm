// r10sd8 — THE PARENTLESS-TYPESPEC POPULATION CENSUS.
//
// ct8cens's 25 OURS_ONLY rows all share one structural property that no earlier
// instrument keyed on: they are PARENTLESS.  Their key carries no ` <- ` hop at
// all, i.e. `VpiParent()` is null.  That is a property of the OBJECT, so it is
// censusable directly and the whole population — not just the 25 that happen to
// differ — can be scored on both sides before any code is written.
//
// Prints, for each side:
//   * every typespec with a null VpiParent, bucketed by KIND x (instance view)
//   * the same for PARENTED typespecs, as the control that must not move
//   * per-kind NAMED / ANONYMOUS split, because § clearAnonClassTsInstance
//     already owns the anonymous class_typespec cell and this pass must not
//     re-derive or disturb it
//
// GUARD: zero parentless typespecs on either side is a hard error.
//
// build: g++ -O2 -std=c++17 ct8par.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct8par
// usage: ct8par <db.uhdm> [--rows]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <set>
#include <string>

using namespace UHDM;

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: ct8par <db> [--rows]\n"; return 2; }
    bool wantRows = (argc > 2 && std::string(argv[2]) == "--rows");
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    if (h.empty()) { std::cerr << "RESTORE FAILED " << argv[1] << "\n"; return 3; }
    auto* d = (design*)((uhdm_handle*)h[0])->object;
    std::set<const BaseClass*> allp, topp;
    if (auto* v = d->AllPackages()) for (auto* p : *v) allp.insert(p);
    if (auto* v = d->TopPackages()) for (auto* p : *v) topp.insert(p);
    auto view = [&](const instance* i) {
        if (!i) return std::string("<null>");
        std::string nm(i->VpiName());
        if (topp.count(i)) return "TOP:" + nm;
        if (allp.count(i)) return "ALL:" + nm;
        return "OTHER:" + nm;
    };

    std::map<std::string, int> par, orph;
    size_t nOrph = 0, nPar = 0;
    for (const auto& [obj, id] : s.AllObjects()) {
        if (!obj) continue;
        auto* t = any_cast<const typespec*>((const any*)obj);
        if (!t) continue;
        std::string kind = UhdmName(t->UhdmType());
        std::string named = t->VpiName().empty() ? "ANON" : "NAMED";
        std::string k = kind + "  " + named + "  inst=" + view(t->Instance());
        if (t->VpiParent()) { par[k]++; nPar++; }
        else {
            orph[k]++; nOrph++;
            if (wantRows && t->Instance())
                std::cout << "ORPHAN_STAMPED " << view(t->Instance()) << "  " << kind
                          << "(" << t->VpiName() << ")@" << t->VpiLineNo() << ":"
                          << t->VpiColumnNo() << "-" << t->VpiEndLineNo() << ":"
                          << t->VpiEndColumnNo() << "  file=" << t->VpiFile() << "\n";
        }
    }
    std::cout << "=== PARENTLESS typespecs (" << nOrph << ")\n";
    for (auto& [k, v] : orph) std::cout << "  " << v << "\t" << k << "\n";
    std::cout << "=== PARENTED typespecs (" << nPar << ") — THE CONTROL\n";
    for (auto& [k, v] : par) std::cout << "  " << v << "\t" << k << "\n";
    std::cout << "[S] ORPHANS=" << nOrph << " PARENTED=" << nPar << "\n";
    if (nOrph == 0) { std::cerr << "REFUSING: zero parentless typespecs\n"; return 5; }
    return 0;
}
