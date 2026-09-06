// r10uvm181 — REFERENCE CONTEXT PROBE.  MEASUREMENT ONLY; the official
// `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// Prints, for every `ref_obj` / `ref_var` carrying a given NAME, its full
// ancestor-face chain, its `vpiActual` and the typespec of whatever it binds —
// on BOTH sides, sorted, so the two columns can be read against each other.
// `argv[3]` is the name; `argv[4]` (optional) restricts to one line number.
//
// build: g++ -O2 -std=c++17 ct181ref.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct181ref
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <string>
#include <vector>

using namespace UHDM;

static std::string ident(const BaseClass* o) {
    if (!o) return "<null>";
    char b[900];
    snprintf(b, sizeof b, "%s(%s)@%u:%u#%u", UhdmName(o->UhdmType()),
             std::string(o->VpiName()).c_str(), o->VpiLineNo(),
             (unsigned)o->VpiColumnNo(), o->UhdmId());
    return b;
}
static std::string chain(const BaseClass* o) {
    std::string s;
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
        s += " < ";
        s += UhdmName(p->UhdmType());
        const std::string n(p->VpiName());
        if (!n.empty()) { s += ":"; s += n; }
        s += "@" + std::to_string(p->VpiLineNo());
    }
    return s;
}
static const BaseClass* actualOf(const BaseClass* o) {
    if (auto* r = any_cast<const ref_obj*>(o)) return r->Actual_group();
    if (auto* r = any_cast<const ref_var*>(o)) return r->Actual_group();
    return nullptr;
}
static std::string tsOf(const BaseClass* o) {
    if (!o) return "-";
    const ref_typespec* rt = nullptr;
    if (auto* v = any_cast<const variables*>(o)) rt = v->Typespec();
    else if (auto* r = any_cast<const ref_obj*>(o)) rt = r->Typespec();
    if (!rt) return "TS=<null>";
    return "TS->" + ident(rt->Actual_typespec());
}

int main(int argc, char** argv) {
    if (argc < 4) { fprintf(stderr, "usage: ct181ref <golden> <ours> <name> [line]\n"); return 2; }
    const std::string want = argv[3];
    const unsigned wline = argc > 4 ? (unsigned)atoi(argv[4]) : 0;
    Serializer sg, so;
    if (sg.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL golden\n"); return 3; }
    if (so.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL ours\n"); return 3; }
    for (int side = 0; side < 2; ++side) {
        Serializer& S = side ? so : sg;
        printf("---- %s ----\n", side ? "OURS" : "GOLDEN");
        std::vector<std::string> rows;
        for (auto& kv : S.AllObjects()) {
            const BaseClass* o = kv.first;
            if (!o) continue;
            if (o->UhdmType() != uhdmref_obj && o->UhdmType() != uhdmref_var &&
                o->UhdmType() != uhdmbit_select)
                continue;
            if (std::string(o->VpiName()) != want) continue;
            if (wline && o->VpiLineNo() != wline) continue;
            const BaseClass* a = actualOf(o);
            char b[3000];
            snprintf(b, sizeof b, "  %5u:%-3u %-34s %-10s ACT=%-34s %-26s%s",
                     o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
                     ident(o).c_str(), tsOf(o).c_str(),
                     ident(a).c_str(), a ? tsOf(a).c_str() : "-",
                     chain(o).c_str());
            rows.push_back(b);
        }
        std::sort(rows.begin(), rows.end());
        for (auto& s : rows) printf("%s\n", s.c_str());
        if (rows.empty()) printf("  (none)\n");
    }
    return 0;
}
