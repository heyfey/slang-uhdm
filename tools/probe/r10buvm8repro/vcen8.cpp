// vbuvm8 verifier census: like r10buvm8cen but ALSO reports the IDENTITY CLASS
// of each stamped actual typespec's Instance() -- the field typespec::Compare
// recurses and the ONE thing that separates the DEF package twin from the
// ELABORATED one.  grid8.sh cannot see this (both twins print the same
// file:line), and binding the def twin is exactly the defect r10buvm8's second
// hunk exists to prevent.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <iostream>
#include <map>
#include <set>
#include <string>
using namespace UHDM;
static std::string loc(const any* o) {
    if (!o) return "-";
    return std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo()) +
           "-" + std::to_string(o->VpiEndLineNo()) + ":" + std::to_string(o->VpiEndColumnNo());
}
int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: vcen <file.uhdm> [tag]\n"; return 2; }
    std::string tag = argc > 2 ? argv[2] : argv[1];
    Serializer s;
    auto restored = s.Restore(std::string(argv[1]));
    if (restored.empty()) { std::cout << "RESTORE_FAIL " << tag << "\nVTOT " << tag << " args=0 TS=0\n"; return 3; }
    std::set<const any*> topPkgs, allPkgs;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o || o->UhdmType() != uhdmdesign) continue;
        auto* d = (const design*)o;
        if (auto* v = d->TopPackages()) for (auto* p : *v) topPkgs.insert(p);
        if (auto* v = d->AllPackages()) for (auto* p : *v) allPkgs.insert(p);
    }
    long nargs = 0, nts = 0, ndef = 0;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o) continue;
        auto* call = dynamic_cast<const tf_call*>(o);
        if (!call) continue;
        auto* v = call->Tf_call_args();
        size_t n = v ? v->size() : 0;
        // which package listing is this CALL in
        std::string view = "NOPKG";
        {
            const any* r = call; int g = 0;
            while (r && g++ < 80) {
                if (r->UhdmType() == uhdmpackage)
                    view = topPkgs.count(r) ? "ELABPKG" : (allPkgs.count(r) ? "DEFPKG" : "PKG?");
                r = r->VpiParent();
            }
        }
        for (size_t i = 0; i < n; i++) {
            const any* a = (*v)[i];
            nargs++;
            const ref_typespec* rt = nullptr;
            if (auto* e = dynamic_cast<const expr*>(a)) rt = e->Typespec();
            const typespec* act = rt ? rt->Actual_typespec() : nullptr;
            if (!rt) continue;
            nts++;
            std::string icls = "NOINST";
            std::string iname = "-";
            if (act) {
                const instance* in = act->Instance();
                if (in) {
                    iname = std::string(in->VpiName());
                    if (topPkgs.count(in)) icls = "INST_ELABPKG";
                    else if (allPkgs.count(in)) { icls = "INST_DEFPKG"; ndef++; }
                    else icls = std::string(UhdmName(in->UhdmType()));
                }
            }
            std::cout << "VARG " << tag << " " << loc(a) << " callee=" << call->VpiName()
                      << " pos=" << i << " view=" << view
                      << " act=" << (act ? std::string(UhdmName(act->UhdmType())) : "-")
                      << " actloc=" << loc(act)
                      << " actid=" << (act ? (long)act->UhdmId() : -1L)
                      << " inst=" << icls << " instname=" << iname << "\n";
        }
    }
    std::cout << "VTOT " << tag << " args=" << nargs << " TS=" << nts
              << " actual-in-DEFPKG=" << ndef << "\n";
    return 0;
}
