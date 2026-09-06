// r10uvm171 — THE PER-COPY LISTING INSTRUMENT.  MEASUREMENT ONLY; the official
// ~/git-repos/UHDM/build/bin/uhdm-cmp is the sole judge.  LHS is ALWAYS golden
// (Surelog), RHS is ALWAYS ours.
//
// The census (ct171cen.cpp) says HOW MANY copies of a span bind on each side.
// This one says WHICH: for every select-family object and every leading
// `ref_obj` of a `hier_path` whose name equals the enclosing subroutine's name
// (the RETURN NAME), it prints the object's whole ancestor chain — the only
// thing that separates the DEF view, the home package's elaborated view and a
// wildcard-import CLONE, which is exactly the axis the law turns on.  The
// listings of the two sides are printed SEPARATELY and never merged into one
// multiset (r10v169's listcheck law).
//
// build: g++ -O2 -std=c++17 ct171list.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct171list
// usage: ct171list <golden.uhdm> <ours.uhdm> [<name substring>]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>

using namespace UHDM;

static std::string kn(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("<null>");
}
static const any* actualOf(const BaseClass* o) {
    if (const ref_obj* r = any_cast<const ref_obj*>(o)) return r->Actual_group();
    if (const ref_var* r = any_cast<const ref_var*>(o)) return r->Actual_group();
    return nullptr;
}
static bool isSelectish(const BaseClass* o) {
    const UHDM_OBJECT_TYPE t = o->UhdmType();
    if (t == uhdmbit_select || t == uhdmpart_select || t == uhdmvar_select ||
        t == uhdmindexed_part_select)
        return true;
    return t == uhdmref_obj && o->VpiParent() &&
           o->VpiParent()->UhdmType() == uhdmhier_path;
}
// Only the NAMED scopes: package / class_defn / module_inst / function / task.
// A statement chain adds nothing an ancestor-view test needs.
static std::string homeChain(const BaseClass* o) {
    std::string s;
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
        const UHDM_OBJECT_TYPE t = p->UhdmType();
        if (t != uhdmpackage && t != uhdmclass_defn && t != uhdmmodule_inst &&
            t != uhdmfunction && t != uhdmtask)
            continue;
        s += " <";
        s += kn(p);
        s += ":";
        s += std::string(p->VpiName());
    }
    return s;
}
static const BaseClass* encFn(const BaseClass* o) {
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent())
        if (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask) return p;
    return nullptr;
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct171list <golden> <ours> [name]\n"); return 2; }
    const char* want = argc > 3 ? argv[3] : nullptr;
    for (int side = 0; side < 2; ++side) {
        Serializer s;
        if (s.Restore(std::string(argv[1 + side])).empty()) {
            printf("RESTORE_FAIL %s\n", side ? "ours" : "golden");
            return 3;
        }
        printf("---- %s ----\n", side ? "OURS" : "GOLDEN");
        std::vector<std::string> rows;
        for (auto& kv : s.AllObjects()) {
            const BaseClass* o = kv.first;
            if (!o || !isSelectish(o)) continue;
            const BaseClass* fn = encFn(o);
            if (!fn) continue;
            const std::string nm(o->VpiName());
            if (nm != std::string(fn->VpiName())) continue;   // RETURN NAME only
            if (want && nm.find(want) == std::string::npos) continue;
            const any* a = actualOf(o);
            char b[1400];
            snprintf(b, sizeof b, "  %5u:%-3u %-20s %-6s act=%-14s%s",
                     o->VpiLineNo(), (unsigned)o->VpiColumnNo(), kn(o).c_str(),
                     a ? "BOUND" : "BARE", a ? kn(a).c_str() : "-",
                     homeChain(o).c_str());
            rows.push_back(b);
        }
        std::sort(rows.begin(), rows.end());
        for (auto& r : rows) printf("%s\n", r.c_str());
        printf("  (%zu rows)\n", rows.size());
    }
    return 0;
}
