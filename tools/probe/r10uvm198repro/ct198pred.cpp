// r10uvm198 — THE A-PRIORI PREDICTOR.  MEASUREMENT ONLY; the official
// `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.  LHS is ALWAYS
// golden, RHS is ALWAYS ours.
//
// Reads a PRISTINE database of OURS and prints every cell
// § classScopedTdImportCopyLocalUnsupported198 will rewrite, BEFORE the patched
// sweep exists.  The criterion is exactly what the emitter rewrites, expressed
// in the database the emitter produced:
//
//   a `variables` slot of a listing scope (a task/function's own
//   `vpiVariables`, or a begin / named_begin / fork arm inside one) whose
//   nearest enclosing task_func is an OUT-OF-BODY class method (its VpiName
//   carries `::`), listed under a `package P`, whose bound `Actual_typespec` is
//   NOT already an `unsupported_typespec` and IS PARENTED AT A `class_defn`
//   whose own package Q is NOT P.
//
// The last clause is the CLONE test and the class-scope test at once: our
// resolved typespec for a class-scope typedef is the object listed on the
// owning `class_defn` (r10uvm198 owner-finder, SeqDriver: one
// `struct_typespec(m_verbosity_setting)` under `class_defn uvm_component`
// shared by all eleven referrers), and a body listed under a package other than
// the class's home package IS the wildcard-import copy.
//
// build: g++ -O2 -std=c++17 ct198pred.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct198pred
// usage: ct198pred <ours.uhdm> <tag>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <string>
#include <vector>

using namespace UHDM;

static const BaseClass* upTo(const BaseClass* o, UHDM_OBJECT_TYPE t1,
                             UHDM_OBJECT_TYPE t2) {
    int g = 0;
    for (const BaseClass* p = o ? o->VpiParent() : nullptr; p && g < 48;
         p = p->VpiParent(), ++g)
        if (p->UhdmType() == t1 || p->UhdmType() == t2) return p;
    return nullptr;
}
static std::string span(const BaseClass* o) {
    char b[80];
    snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(),
             (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo());
    return b;
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct198pred <ours.uhdm> <tag>\n"); return 2; }
    Serializer S;
    if (S.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
    const char* tag = argv[2];
    std::vector<std::string> rows, wrows;
    size_t cells = 0, wide = 0;
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
        // the nearest enclosing subroutine, and the package it is listed under
        const BaseClass* T = (X->UhdmType() == uhdmtask ||
                              X->UhdmType() == uhdmfunction)
                                 ? X
                                 : upTo(X, uhdmtask, uhdmfunction);
        if (!T) continue;
        if (std::string(T->VpiName()).find("::") == std::string::npos) continue;
        const BaseClass* P = upTo(T, uhdmpackage, uhdmpackage);
        if (!P) continue;
        for (size_t i = 0; i < vars->size(); ++i) {
            const variables* v = (*vars)[i];
            if (!v || !v->Typespec()) continue;
            const typespec* A = v->Typespec()->Actual_typespec();
            if (!A || A->UhdmType() == uhdmunsupported_typespec) continue;
            // THE WIDE BOUND, printed for every clone-body local whose binding
            // is not already a placeholder.  The STRICT set below can only
            // UNDER-predict (a class-scope typedef we resolve to an object our
            // own emitter parented somewhere else — grid198 arm B's class
            // UNION and class STRING locals are exactly that shape), so the
            // patched sweep's movers are checked against this superset too:
            // every mover must be inside PREDW, and every PRED cell must move.
            ++wide;
            wrows.push_back(std::string("PREDW|") + tag + "|" +
                            std::string(P->VpiName()) + "|" +
                            std::string(T->VpiName()) + "|" +
                            std::string(UhdmName(X->UhdmType())) + "@" +
                            span(X) + "|" + std::to_string(i) + "|" +
                            std::string(v->VpiName()) + "|" +
                            std::string(UhdmName(A->UhdmType())) + ":" +
                            std::string(A->VpiName()));
            const BaseClass* pa = A->VpiParent();
            if (!pa || pa->UhdmType() != uhdmclass_defn) continue;
            const BaseClass* Q = upTo(pa, uhdmpackage, uhdmpackage);
            if (!Q || Q->VpiName() == P->VpiName()) continue;
            ++cells;
            rows.push_back(std::string("PRED|") + tag + "|" +
                           std::string(P->VpiName()) + "|" +
                           std::string(T->VpiName()) + "|" +
                           std::string(UhdmName(X->UhdmType())) + "@" +
                           span(X) + "|" + std::to_string(i) + "|" +
                           std::string(v->VpiName()) + "|" +
                           std::string(UhdmName(A->UhdmType())) + ":" +
                           std::string(A->VpiName()) + "@" + span(A));
        }
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) printf("%s\n", r.c_str());
    std::sort(wrows.begin(), wrows.end());
    for (auto& r : wrows) printf("%s\n", r.c_str());
    printf("PREDCELLS %s strict=%zu wide=%zu\n", tag, cells, wide);
    return 0;
}
