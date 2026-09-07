// r10uvm202 — THE A-PRIORI MOVER PREDICTOR.  MEASUREMENT ONLY; the official
// `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.
//
// Reads ONE database THE PRISTINE BINARY PRODUCED and answers, without ever
// looking at the patched one: does § pkgClassTdImportCopyLocalUnsupported202
// have a cell here?  The criterion is the one the emitter rewrites, expressed
// in the database the emitter produced:
//
//   STRICT — a VARIABLE listed by a subroutine (or by one of its begin / named
//     begin / fork blocks) whose subroutine NAME carries `::` (an out-of-body
//     class method) and whose subroutine's OWN vpiParent is a PACKAGE P — that
//     is the wildcard-import CLONE listing and nothing else — bound through its
//     `ref_typespec` to a `class_typespec` that is NOT already a placeholder
//     and whose `vpiClassDefn` lives under a DIFFERENT package Q != P.
//
//   WIDE — the same clone-body locals with ANY non-placeholder typespec.  The
//     strict criterion can only OVER-cover (it cannot see from the database
//     whether the declaration was written with a TYPEDEF or with the class name
//     itself, and the emitter fires only on the typedef), so it may NAME A ROW
//     THAT DOES NOT MOVE but can never MISS one that does.  Every observed
//     mover must lie inside the wide bound.
//
// build: g++ -O2 -std=c++17 ct202pred.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct202pred
// usage: ct202pred <db.uhdm> <rowname>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <string>

using namespace UHDM;

static const BaseClass* pkgAbove(const BaseClass* o) {
    for (const BaseClass* p = o; p; p = p->VpiParent())
        if (p->UhdmType() == uhdmpackage) return p;
    return nullptr;
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct202pred <db.uhdm> <row>\n"); return 2; }
    Serializer S;
    if (S.Restore(std::string(argv[1])).empty()) {
        printf("RESTORE_FAIL %s\n", argv[2]);
        return 3;
    }
    const char* row = argv[2];
    size_t strict = 0, wide = 0;
    for (auto& kv : S.AllObjects()) {
        const BaseClass* X = kv.first;
        if (!X) continue;
        const VectorOfvariables* vars = nullptr;
        switch (X->UhdmType()) {
            case uhdmtask: vars = ((const task*)X)->Variables(); break;
            case uhdmfunction: vars = ((const function*)X)->Variables(); break;
            case uhdmbegin: vars = ((const begin*)X)->Variables(); break;
            case uhdmnamed_begin: vars = ((const named_begin*)X)->Variables(); break;
            case uhdmfork_stmt: vars = ((const fork_stmt*)X)->Variables(); break;
            case uhdmnamed_fork: vars = ((const named_fork*)X)->Variables(); break;
            default: continue;
        }
        if (!vars) continue;
        // the enclosing subroutine, and the requirement that IT is listed
        // DIRECTLY under a package — the clone listing
        const BaseClass* sub = nullptr;
        for (const BaseClass* p = X; p; p = p->VpiParent())
            if (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask) {
                sub = p;
                break;
            }
        if (!sub) continue;
        if (std::string(sub->VpiName()).find("::") == std::string::npos) continue;
        const BaseClass* P = sub->VpiParent();
        if (!P || P->UhdmType() != uhdmpackage) continue;
        for (const variables* v : *vars) {
            if (!v) continue;
            const ref_typespec* rt = v->Typespec();
            const typespec* a = rt ? rt->Actual_typespec() : nullptr;
            if (!a) continue;
            if (a->UhdmType() == uhdmunsupported_typespec) continue;
            ++wide;
            if (a->UhdmType() != uhdmclass_typespec) continue;
            const class_defn* cd = ((const class_typespec*)a)->Class_defn();
            if (!cd) continue;
            const BaseClass* Q = pkgAbove(cd);
            if (!Q || Q == P) continue;
            if (Q->VpiName() == P->VpiName()) continue;
            ++strict;
        }
    }
    printf("PREDCELLS %-34s strict=%zu wide=%zu\n", row, strict, wide);
    return 0;
}
