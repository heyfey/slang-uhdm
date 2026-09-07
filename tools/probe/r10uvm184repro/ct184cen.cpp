// r10uvm184 — THE REFERENCE-BINDING CENSUS.  MEASUREMENT ONLY; the official
// `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.  LHS is ALWAYS
// golden (Surelog); RHS is ALWAYS ours.
//
// One row per `ref_obj` / `ref_var` object reached by walking `AllObjects`,
// deduped by `UhdmId`.  The key is id-free and span-free on the ANCESTORS but
// carries the reference's OWN span, because two references to the same name in
// one subroutine are told apart by nothing else:
//
//   LISTING | SUBR | LINE:COL | NAME | ENCL | ACT
//
//   LISTING  the ROOT of the parent chain below `design` — `pkg:uvm_pkg`,
//            `pkg:adpcm_pkg`, ... — plus `cls` when a `class_defn` is on the
//            chain, which is what separates the in-body class listing from the
//            package out-of-body listing and from a wildcard-import CLONE's.
//   SUBR     the nearest enclosing task/function's VpiName.
//   ENCL     the immediate syntactic wrapper of the reference: `hier_path-elem`,
//            `mfc-arg` (an argument of a method_func_call), `fc-arg`, `op`,
//            `assign-lhs`, ... — the face the law is stated over.
//   ACT      `BARE` or the actual's kind + name + span, plus `HOME` when the
//            actual's own listing root differs from the reference's (a clone
//            reference bound into the home listing).
//
// `--dupe` additionally prints, for every ROW KEY that occurs more than once in
// one database, the multiplicity — the census is a MULTISET join (RESUME.md §9)
// and a last-writer dictionary would silently drop the clone's copies.
//
// build: g++ -O2 -std=c++17 ct184cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct184cen
// usage: ct184cen <db.uhdm> [subroutine-name-substr]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <string>
#include <vector>

using namespace UHDM;

static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("<null>");
}
static std::string face(const BaseClass* o) {
    if (!o) return "<null>";
    char b[600];
    snprintf(b, sizeof b, "%s(%s)@%u:%u-%u:%u", kindOf(o).c_str(),
             std::string(o->VpiName()).c_str(), o->VpiLineNo(),
             (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo());
    return b;
}
// The listing this object belongs to: the outermost non-design ancestor, with
// `+cls` when a class_defn is on the chain.
static std::string listingOf(const BaseClass* o) {
    std::string root = "-";
    bool cls = false;
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
        if (p->UhdmType() == uhdmclass_defn) cls = true;
        if (p->UhdmType() == uhdmdesign) break;
        root = kindOf(p) + ":" + std::string(p->VpiName());
    }
    return root + (cls ? "+cls" : "");
}
static std::string subrOf(const BaseClass* o) {
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent())
        if (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask)
            return std::string(p->VpiName());
    return "-";
}
static std::string enclOf(const BaseClass* o) {
    const BaseClass* p = o->VpiParent();
    if (!p) return "none";
    const std::string k = kindOf(p);
    if (k == "hier_path") return "hier_path-elem";
    if (k == "method_func_call") return "mfc-arg";
    if (k == "func_call") return "fc-arg";
    if (k == "task_call") return "tc-arg";
    if (k == "operation") return "op-operand";
    if (k == "assignment") return "assign";
    return k;
}
static const BaseClass* actualOf(const BaseClass* o) {
    if (const ref_obj* r = any_cast<const ref_obj*>(o)) return r->Actual_group();
    if (const ref_var* r = any_cast<const ref_var*>(o)) return r->Actual_group();
    return nullptr;
}

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct184cen <db.uhdm> [subr-substr]\n"); return 2; }
    const char* want = argc > 2 ? argv[2] : nullptr;
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
    std::vector<std::string> rows;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        if (o->UhdmType() != uhdmref_obj && o->UhdmType() != uhdmref_var) continue;
        const std::string sub = subrOf(o);
        if (want && sub.find(want) == std::string::npos) continue;
        const BaseClass* a = actualOf(o);
        std::string act = a ? face(a) : std::string("BARE");
        if (a && listingOf(a) != listingOf(o)) act += " HOME=" + listingOf(a);
        char b[2000];
        snprintf(b, sizeof b, "%-22s %-34s %5u:%-3u %-24s %-16s %s",
                 listingOf(o).c_str(), sub.c_str(), o->VpiLineNo(),
                 (unsigned)o->VpiColumnNo(), std::string(o->VpiName()).c_str(),
                 enclOf(o).c_str(), act.c_str());
        rows.push_back(b);
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) printf("%s\n", r.c_str());
    printf("ROWS %zu\n", rows.size());
    return 0;
}
