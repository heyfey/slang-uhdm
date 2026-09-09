// r10uvm227 — THE CELL CENSUS for § importedFreeCallTakesFirstListingImport227.
// MEASUREMENT ONLY; `uhdm-cmp` remains the sole acceptance judge.
//
// One line per CELL, where a cell is a BARE call to a package free subroutine
// written inside a MODULE or INTERFACE holder — the exact population the law
// re-routes.  The KEY is ONLY what both producers spell the SAME way: the
// holder's VpiDefName, the call's name, and the call's START line:col.  The
// call's VpiFile is NOT in the key (ours is EMPTY on a macro-expanded call —
// RESUME §9) and neither is its END position (golden's `uvm_report_info` ends
// at 115:176 where ours ends at 115:196); either one in the key turns every
// cell into a pair of phantom halves, which is what the first cut of this
// probe did.  The PAYLOAD is the NAME OF THE PACKAGE that owns the callee plus
// the callee's own span, which is the only thing the law changes.
// The DEF/ELAB view is deliberately NOT in the key: the two producers
// label it differently (RESUME §9's census trap), and every holder carries the
// same cell in both views, so the multiset join covers them.
//
// The payload is COMPARE-VISIBLE by construction: the callee's owner package
// decides which COPY of the subroutine `vpiFunction` reaches, and the two
// copies differ in their bodies (MiniAmiq: the svaunit_pkg copy binds
// `cs`/`top`, the uvm_pkg copy leaves them bare).
//
// build: g++ -O2 -std=c++17 ct227cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct227cen
// usage: ct227cen <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <string>
#include <vector>

using namespace UHDM;

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct227cen <db.uhdm>\n"); return 2; }
    Serializer S;
    if (S.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
    std::vector<std::string> rows;
    for (auto& kv : S.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        const tf_call* tc = any_cast<const tf_call*>(o);
        if (!tc) continue;
        const std::string nm(o->VpiName());
        if (nm.find("::") != std::string::npos) continue;
        const BaseClass* callee = nullptr;
        if (const func_call* fc = any_cast<const func_call*>(o)) callee = fc->Function();
        else if (const task_call* tk = any_cast<const task_call*>(o)) callee = tk->Task();
        if (!callee) continue;
        const BaseClass* cown = callee->VpiParent();
        if (!cown || cown->UhdmType() != uhdmpackage) continue;
        const BaseClass* holder = nullptr;
        int guard = 0;
        for (const BaseClass* p = o->VpiParent(); p && guard < 64;
             p = p->VpiParent(), ++guard) {
            if (p->UhdmType() == uhdmpackage) break;
            if (p->UhdmType() == uhdmmodule_inst || p->UhdmType() == uhdminterface_inst) {
                holder = p;
                break;
            }
        }
        if (!holder) continue;
        const instance* hi = (const instance*)holder;
        char b[1500];
        snprintf(b, sizeof b, "CELL %s|%s|%u:%u => %s @%u:%u-%u:%u",
                 std::string(hi->VpiDefName()).c_str(), nm.c_str(),
                 o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
                 std::string(cown->VpiName()).c_str(), callee->VpiLineNo(),
                 (unsigned)callee->VpiColumnNo(), callee->VpiEndLineNo(),
                 (unsigned)callee->VpiEndColumnNo());
        rows.push_back(b);
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) printf("%s\n", r.c_str());
    printf("# CELLS %zu\n", rows.size());
    return 0;
}
