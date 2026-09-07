// r10uvm185 — THE CENSUS PROBE for the decoded face: EVERY `function` object's
// RETURN VARIABLE, keyed on the axes the decode names.
//
// MEASUREMENT ONLY.  `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.  This tool RESTORES a
// database and prints rows; it never writes one, never mints an object and
// never calls `getDefaultSpecialization`.
//
// One row per `function`, TAB separated:
//
//   FN <vpiFullName> <line>:<col>-<endln>:<endcol> <hasStmt> \
//      <parentKind>:<parentName> <retKind> <retLine>:<retCol> <retTsKind> \
//      <retTsName>
//
// THE AXES, and why each one is here:
//   * `<vpiFullName>` + the FUNCTION's own span is the JOIN KEY.  It is a
//     census key only — `VpiFullName` is NOT a compared field (RESUME.md §9),
//     and the function span is not compared either; they are used because
//     BOTH SIDES AGREE on them for every object this face contains (verified:
//     the head's owner is `19055:3-19055:9` on both sides, and grid `g7`'s
//     prototype listings are `36:5-36:11` on both), which is exactly what a
//     join key must be.
//   * `<hasStmt>` separates the class-body PROTOTYPE listing of an `extern`
//     method (no Stmt) from the out-of-body DEFINITION listing (Stmt) — the
//     two objects Surelog builds for one `extern` method, and the two arms
//     this pass must keep apart.
//   * `<retKind>` is the COMPARED field (`BaseClass::Compare`'s VpiType line,
//     reached through `task_func::Compare`'s `Return` edge).
//   * `<retLine>:<retCol>` is the UNCOMPARED one, carried so the span half of
//     the decode is measured rather than assumed.
//   * `<retTsKind>`/`<retTsName>` is the Return var's `Typespec()->Actual`,
//     which is what `getSimpleVarFromTypespec` reads in Surelog.
//
// A DUPLICATE key is normal (a package's DEF and ELAB listings both carry the
// method), so the joiner must be a MULTISET join — `join185.py` sorts the row
// group per key and pairs by position.  A last-writer dict would drop rows
// (RESUME.md §9, census traps).
//
// build: g++ -O2 -std=c++17 ct185cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct185cen
// usage: ct185cen <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <string>

using namespace UHDM;

static std::string kindName(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("-");
}

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct185cen <db.uhdm>\n"); return 2; }
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = (const BaseClass*)kv.first;
        if (!o || o->UhdmType() != uhdmfunction) continue;
        const function* f = (const function*)o;
        const variables* rv = f->Return();
        const BaseClass* p = f->VpiParent();
        std::string tsk = "-", tsn = "-";
        if (rv)
            if (const ref_typespec* rt = rv->Typespec())
                if (const typespec* at = rt->Actual_typespec()) {
                    tsk = kindName(at);
                    tsn = std::string(at->VpiName());
                    if (tsn.empty()) tsn = "-";
                }
        std::string fn(f->VpiFullName());
        if (fn.empty()) fn = "-";
        std::string pn = p ? std::string(p->VpiName()) : std::string("-");
        if (pn.empty()) pn = "-";
        printf("FN\t%s\t%u:%u-%u:%u\t%d\t%s:%s\t%s\t%u:%u\t%s\t%s\n", fn.c_str(),
               f->VpiLineNo(), (unsigned)f->VpiColumnNo(), f->VpiEndLineNo(),
               (unsigned)f->VpiEndColumnNo(), f->Stmt() ? 1 : 0,
               kindName(p).c_str(), pn.c_str(), kindName(rv).c_str(),
               rv ? rv->VpiLineNo() : 0u,
               rv ? (unsigned)rv->VpiColumnNo() : 0u, tsk.c_str(), tsn.c_str());
    }
    return 0;
}
