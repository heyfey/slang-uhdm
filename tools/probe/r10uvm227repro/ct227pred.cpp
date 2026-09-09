// r10uvm227 — THE A-PRIORI MOVER PREDICTOR.  MEASUREMENT ONLY; reads ONLY
// PRISTINE databases and never the patched ones, so the prediction cannot be
// fitted to the result.  `uhdm-cmp` remains the sole acceptance judge.
//
// § importedFreeCallTakesFirstListingImport227 re-points a `func_call`'s
// `vpiFunction` (and the holder Task_funcs entry that call registers) ONLY
// when all of these hold at once:
//   (P1) the callee `f` is a FREE subroutine of a package H;
//   (P2) some OTHER package P materialized a WILDCARD-IMPORT COPY of `f` —
//        visible in a pristine database as a second `function` with the SAME
//        VpiName and the SAME span, parented by a different `package`;
//   (P3) the call is written BARE (no `::`) inside a MODULE or INTERFACE body
//        — never inside a package's own body (§ collectPkgTfListing's law, and
//        the `callImportScope227` slot is not set during package emission);
//   (P4) that body wildcard-imports P BEFORE H.
// (P4) is a SOURCE fact and is not in the database, so this probe reports the
// NECESSARY conditions P1+P2+P3.  A design that fails them CANNOT move; a
// design that meets them is a CANDIDATE and every actual byte mover must be one
// of them.  Over-prediction is safe here and under-prediction is not, which is
// why the weaker, database-checkable condition is the one printed.
//
// Output (one line per database):
//   <tag> CANDIDATE clonedFreeFns=<n> barePkgCallsInHolders=<n> names=<...>
//   <tag> NO clonedFreeFns=<n> barePkgCallsInHolders=<n>
//
// build: g++ -O2 -std=c++17 ct227pred.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct227pred
// usage: ct227pred <tag> <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct227pred <tag> <db.uhdm>\n"); return 2; }
    const std::string tag(argv[1]);
    Serializer S;
    if (S.Restore(std::string(argv[2])).empty()) {
        printf("%s RESTORE_FAIL\n", tag.c_str());
        return 3;
    }
    // (P1)+(P2): a free subroutine name that TWO different packages list with
    // the same span — the home and at least one wildcard-import copy.
    std::map<std::string, std::set<const BaseClass*>> ownersByKey;
    std::map<std::string, std::string> nameOfKey;
    for (auto& kv : S.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        if (o->UhdmType() != uhdmfunction && o->UhdmType() != uhdmtask) continue;
        const BaseClass* par = o->VpiParent();
        if (!par || par->UhdmType() != uhdmpackage) continue;
        char k[700];
        snprintf(k, sizeof k, "%s|%s|%u:%u-%u:%u", std::string(o->VpiName()).c_str(),
                 std::string(o->VpiFile()).c_str(), o->VpiLineNo(),
                 (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
                 (unsigned)o->VpiEndColumnNo());
        ownersByKey[k].insert(par);
        nameOfKey[k] = std::string(o->VpiName());
    }
    std::set<std::string> clonedNames;
    for (auto& [k, owners] : ownersByKey)
        if (owners.size() > 1) clonedNames.insert(nameOfKey[k]);
    // (P3): a BARE call, inside a module_inst / interface_inst holder, whose
    // callee is a package-parented free subroutine with a cloned name.
    std::set<std::string> hits;
    size_t bareHolderCalls = 0;
    for (auto& kv : S.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        const tf_call* tc = any_cast<const tf_call*>(o);
        if (!tc) continue;
        const std::string nm(o->VpiName());
        if (nm.find("::") != std::string::npos) continue; // written qualifier
        const BaseClass* callee = nullptr;
        if (const func_call* fc = any_cast<const func_call*>(o)) callee = fc->Function();
        else if (const task_call* tk = any_cast<const task_call*>(o)) callee = tk->Task();
        if (!callee) continue;
        const BaseClass* cown = callee->VpiParent();
        if (!cown || cown->UhdmType() != uhdmpackage) continue;
        // holder: the nearest enclosing module_inst / interface_inst, and NOT
        // a package (a package body's call is the other law's).
        bool inHolder = false;
        int guard = 0;
        for (const BaseClass* p = o->VpiParent(); p && guard < 64;
             p = p->VpiParent(), ++guard) {
            if (p->UhdmType() == uhdmpackage) break;
            if (p->UhdmType() == uhdmmodule_inst || p->UhdmType() == uhdminterface_inst) {
                inHolder = true;
                break;
            }
        }
        if (!inHolder) continue;
        ++bareHolderCalls;
        if (clonedNames.count(nm)) hits.insert(nm);
    }
    std::string names;
    for (auto& n : hits) { if (!names.empty()) names += ","; names += n; }
    printf("%s %s clonedFreeFns=%zu barePkgCallsInHolders=%zu names=%s\n",
           tag.c_str(), hits.empty() ? "NO" : "CANDIDATE", clonedNames.size(),
           bareHolderCalls, names.empty() ? "-" : names.c_str());
    return 0;
}
