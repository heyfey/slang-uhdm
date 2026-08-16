// r10sd7 — THE SINGULAR-`vpiInstance` CENSUS, keyed by OBJECT KIND and by the
// instance's VIEW (`ALL:` = def-view package, `TOP:` = elaborated).
//
// Surelog emits every package TWICE, so "uvm_pkg" is two different objects and a
// census that prints only the NAME cannot tell which one a slot holds — a
// distinction sd2/sd3/sd4 each had to re-derive.  The view is resolved here by
// membership in `design.uhdmallPackages` / `uhdmtopPackages`.
//
// This is the instrument that answers "which FAMILY is surplus on our side",
// which is the question a `<null>` / `package` head asks once the per-object
// reads have been exhausted.
//
// GUARD: zero instanced objects is a hard error.
//
// build: g++ -O2 -std=c++17 ct7inst.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct7inst
// usage: ct7inst <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <set>
#include <string>

using namespace UHDM;

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: ct7inst <db>\n"; return 2; }
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    if (h.empty()) { std::cerr << "RESTORE FAILED\n"; return 3; }
    auto* d = (design*)((uhdm_handle*)h[0])->object;
    std::set<const BaseClass*> allv, topv;
    if (auto* v = d->AllPackages()) for (auto* p : *v) allv.insert(p);
    if (auto* v = d->TopPackages()) for (auto* p : *v) topv.insert(p);
    auto view = [&](const instance* i) -> std::string {
        if (!i) return "<null>";
        std::string nm(i->VpiName());
        if (topv.count(i)) return "TOP:" + nm;
        if (allv.count(i)) return "ALL:" + nm;
        return "OTHER:" + std::string(UhdmName(i->UhdmType())) + "(" + nm + ")";
    };
    std::map<std::string, int> byKind;
    size_t n = 0;
    for (const auto& [obj, id] : s.AllObjects()) {
        if (!obj) continue;
        const instance* in = nullptr;
        if (auto* t = any_cast<const typespec*>((const any*)obj)) in = t->Instance();
        else if (auto* v = any_cast<const variables*>((const any*)obj)) in = v->Instance();
        if (!in) continue;
        n++;
        byKind[std::string(UhdmName(obj->UhdmType())) + "  " + view(in)]++;
    }
    for (auto& [k, v] : byKind) std::cout << v << "\t" << k << "\n";
    std::cout << "[S] instanced objects=" << n << "\n";
    if (n == 0) { std::cerr << "REFUSING TO REPORT: empty population\n"; return 5; }
    return 0;
}
