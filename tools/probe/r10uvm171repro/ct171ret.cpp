// r10uvm171 — THE RETURN-EDGE / BODY-LOCAL-PARENT CENSUS.  MEASUREMENT ONLY.
// LHS is ALWAYS golden (Surelog), RHS is ALWAYS ours.
//
// WHY IT EXISTS: the pass was DISPATCHED on the reading that golden "lists
// uvm_instance_scope's Return string_var and its leading body local on the
// FUNCTION" while we "leave the Return edge unset and parent the local at the
// begin".  That reading is REFUTED, and this is the instrument that refutes
// it, corpus-wide rather than on one object: for every `function`/`task` in a
// database it reports whether `Return` is set, how many `Variables()` the
// subroutine lists, and the PARENT KIND of every variable listed there.  Run
// on golden and on ours and diff the two listings — they agree.
//
// Keyed on (subroutine name, Return-set, Variables count, parent-kind
// multiset).  The DEF/ELAB view is NOT in the key (RESUME §9); the two views
// separate themselves by their per-key COUNT.
//
// build: g++ -O2 -std=c++17 ct171ret.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct171ret
// usage: ct171ret <golden.uhdm> <ours.uhdm> [--rows]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstring>
#include <map>
#include <string>
#include <vector>

using namespace UHDM;

static std::string kn(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("<null>");
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct171ret <golden> <ours> [--rows]\n"); return 2; }
    const bool rows = (argc > 3 && !strcmp(argv[3], "--rows"));
    std::map<std::string, int> cg, co;
    for (int side = 0; side < 2; ++side) {
        Serializer s;
        if (s.Restore(std::string(argv[1 + side])).empty()) {
            printf("RESTORE_FAIL %s\n", side ? "ours" : "golden");
            return 3;
        }
        std::map<std::string, int>& C = side ? co : cg;
        for (auto& kv : s.AllObjects()) {
            const BaseClass* o = kv.first;
            if (!o) continue;
            const UHDM_OBJECT_TYPE t = o->UhdmType();
            if (t != uhdmfunction && t != uhdmtask) continue;
            const task_func* tf = (const task_func*)o;
            std::string pk;
            size_t nv = 0;
            if (const scope* sc = any_cast<const scope*>(o))
                if (auto* vars = sc->Variables()) {
                    nv = vars->size();
                    std::map<std::string, int> pc;
                    for (auto* v : *vars) pc[kn(v->VpiParent())]++;
                    for (auto& p : pc) pk += p.first + "x" + std::to_string(p.second) + ",";
                }
            char b[900];
            snprintf(b, sizeof b, "%-30s ret=%d nvars=%zu parents=%s",
                     std::string(o->VpiName()).c_str(), tf->Return() ? 1 : 0, nv,
                     pk.empty() ? "-" : pk.c_str());
            C[b]++;
        }
    }
    long both = 0, onlyG = 0, onlyO = 0;
    std::map<std::string, int> all;
    for (auto& kv : cg) all[kv.first] += 0;
    for (auto& kv : co) all[kv.first] += 0;
    for (auto& kv : all) {
        int a = cg.count(kv.first) ? cg[kv.first] : 0;
        int b = co.count(kv.first) ? co[kv.first] : 0;
        if (a == b) { both += a; continue; }
        if (a > b) onlyG += a - b;
        if (b > a) onlyO += b - a;
        if (rows) printf("  g=%-4d o=%-4d  %s\n", a, b, kv.first.c_str());
    }
    printf("RETCENSUS agree=%ld golden-only=%ld ours-only=%ld keys=%zu\n", both,
           onlyG, onlyO, all.size());
    return 0;
}
