// r10uvm171 — THE SINGLE-DATABASE PREDICTOR.  MEASUREMENT ONLY; the official
// ~/git-repos/UHDM/build/bin/uhdm-cmp is the sole judge.
//
// The law binds `Actual_group` on ONE population: an object of the SELECT
// family, or the LEADING `ref_obj` of a method-receiver `hier_path`, whose
// `VpiName` equals the name of the enclosing `function`/`task` — i.e. a
// SELECT OR METHOD RECEIVER ON THE SUBROUTINE'S OWN RETURN NAME.  Every byte
// mover the patch can produce owns one of these objects, so listing them on
// the PRISTINE database of every row NAMES the mover set a priori.
//
// One row per candidate:
//   <line>:<col> <kind> BOUND|BARE  fn=<function> home=<package/class chain>
// and a trailing CAND=<n> line so a scan can grep the count alone.  A database
// with no candidate prints CAND=0 and cannot move.
//
// build: g++ -O2 -std=c++17 ct171pred.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct171pred
// usage: ct171pred <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
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
static std::string homeChain(const BaseClass* o) {
    std::string s;
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
        const UHDM_OBJECT_TYPE t = p->UhdmType();
        if (t != uhdmpackage && t != uhdmclass_defn && t != uhdmmodule_inst)
            continue;
        s += "<";
        s += kn(p);
        s += ":";
        s += std::string(p->VpiName());
        s += " ";
    }
    return s;
}
static const BaseClass* encFn(const BaseClass* o) {
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent())
        if (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask) return p;
    return nullptr;
}

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct171pred <db.uhdm>\n"); return 2; }
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
    std::vector<std::string> rows;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || !isSelectish(o)) continue;
        const BaseClass* fn = encFn(o);
        if (!fn) continue;
        const std::string nm(o->VpiName());
        if (nm.empty() || nm != std::string(fn->VpiName())) continue;
        const any* a = actualOf(o);
        char b[1400];
        snprintf(b, sizeof b, "  %5u:%-3u %-20s %-5s fn=%-28s home=%s",
                 o->VpiLineNo(), (unsigned)o->VpiColumnNo(), kn(o).c_str(),
                 a ? "BOUND" : "BARE", std::string(fn->VpiName()).c_str(),
                 homeChain(o).c_str());
        rows.push_back(b);
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) printf("%s\n", r.c_str());
    printf("CAND=%zu\n", rows.size());
    return 0;
}
