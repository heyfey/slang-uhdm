// r10uvm204 — THE A-PRIORI MOVER PREDICTOR.  MEASUREMENT ONLY; the official
// `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.
//
// Reads ONE database THE PRISTINE BINARY PRODUCED and answers, without ever
// looking at the patched one nor at any golden: does § cloneForInitVarBind204
// have a cell here?  The criterion is the one the emitter rewrites, expressed
// in the database the emitter produced:
//
//   STRICT — a BINDABLE reference (`ref_obj` / `ref_var` / `bit_select`) with a
//     NULL `vpiActual` and a non-empty name, standing inside a `for_stmt` whose
//     INIT-DECLARED variable carries that same name, where the whole thing sits
//     in a WILDCARD-IMPORT CLONE listing: the enclosing subroutine's name
//     carries `::` (an out-of-body class method), its own `vpiParent` is a
//     package P, and P does NOT itself define a `class_defn` of the class the
//     name qualifies.  That last clause is the entire home-vs-clone
//     discriminator — `uvm_pkg` lists `uvm_reg_field::do_predict` AND defines
//     `class_defn uvm_reg_field`; `adpcm_pkg` lists it and defines no such
//     class.
//
//     The climb is INNERMOST-OUT and stops at the first enclosing `for_stmt`
//     that declares the name, exactly as `bind9` does, so a shadowed outer loop
//     is never counted.
//
//   WIDE — the same, with the clone clause dropped: every null bindable
//     reference standing inside a for-loop that declares its name, in ANY
//     listing.  A mover outside the wide bound would refute the law outright.
//
//   The DECLARATION form is required on both counts: an init written
//   `for (i = 0; ...)` gives its Lhs variable NO typespec at all (Surelog
//   compiles it from the Hierarchical_identifier, we mint a bare `ref_var`),
//   and golden binds body references to the real declaration, not to that
//   artefact.  `tsBound` is that test.
//
// build: g++ -O2 -std=c++17 ct204pred.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct204pred
// usage: ct204pred <db.uhdm> <rowname>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <set>
#include <string>

using namespace UHDM;

static const any* actOf(const any* e) {
    switch (e->UhdmType()) {
        case uhdmref_obj: return ((const ref_obj*)e)->Actual_group();
        case uhdmref_var: return ((const ref_var*)e)->Actual_group();
        case uhdmbit_select: return ((const bit_select*)e)->Actual_group();
        default: return nullptr;
    }
}
static bool bindable(const any* e) {
    auto t = e->UhdmType();
    return t == uhdmref_obj || t == uhdmref_var || t == uhdmbit_select;
}
// the DECLARATION-form init variable of this for_stmt carrying <nm>
static const variables* forInitVar(const BaseClass* b, std::string_view nm) {
    if (b->UhdmType() != uhdmfor_stmt) return nullptr;
    const for_stmt* f = (const for_stmt*)b;
    auto one = [&](const any* st) -> const variables* {
        if (!st || st->UhdmType() != uhdmassignment) return nullptr;
        const expr* l = ((const assignment*)st)->Lhs();
        if (!l) return nullptr;
        const variables* v = any_cast<const variables*>(l);
        if (!v || v->VpiName() != nm) return nullptr;
        const ref_typespec* rt = v->Typespec();
        if (!rt || !rt->Actual_typespec()) return nullptr;  // plain-assignment form
        return v;
    };
    if (const any* s1 = f->VpiForInitStmt())
        if (const variables* v = one(s1)) return v;
    if (const VectorOfany* sv = f->VpiForInitStmts())
        for (const any* s2 : *sv)
            if (const variables* v = one(s2)) return v;
    return nullptr;
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct204pred <db.uhdm> <row>\n"); return 2; }
    Serializer S;
    if (S.Restore(std::string(argv[1])).empty()) {
        printf("RESTORE_FAIL %s\n", argv[2]);
        return 3;
    }
    const char* row = argv[2];
    // every (package, class name) pair the database DEFINES
    std::set<std::string> defines;
    for (auto& kv : S.AllObjects()) {
        const BaseClass* X = kv.first;
        if (!X || X->UhdmType() != uhdmclass_defn) continue;
        for (const BaseClass* p = X; p; p = p->VpiParent())
            if (p->UhdmType() == uhdmpackage) {
                defines.insert(std::string(p->VpiName()) + "|" +
                               std::string(X->VpiName()));
                break;
            }
    }
    size_t strict = 0, wide = 0;
    for (auto& kv : S.AllObjects()) {
        const any* X = (const any*)kv.first;
        if (!X || !bindable(X)) continue;
        if (actOf(X) || X->VpiName().empty()) continue;
        const std::string nm(X->VpiName());
        // innermost-out to the owning subroutine, exactly as bind9 climbs
        const variables* hit = nullptr;
        const BaseClass* sub = nullptr;
        for (const BaseClass* a = X; a; a = a->VpiParent()) {
            if (a->UhdmType() == uhdmfunction || a->UhdmType() == uhdmtask) {
                sub = a;
                break;
            }
            if (!hit) hit = forInitVar(a, nm);
        }
        if (!hit) continue;
        ++wide;
        if (!sub) continue;
        const std::string sn(sub->VpiName());
        const size_t sep = sn.rfind("::");
        if (sep == std::string::npos) continue;
        const BaseClass* P = sub->VpiParent();
        if (!P || P->UhdmType() != uhdmpackage) continue;
        // the class this out-of-body method qualifies (the LAST `::` splits the
        // method name off; what remains may itself be `outer::inner`)
        const std::string cls = sn.substr(0, sep);
        const std::string leaf =
            cls.rfind("::") == std::string::npos
                ? cls
                : cls.substr(cls.rfind("::") + 2);
        if (defines.count(std::string(P->VpiName()) + "|" + leaf)) continue;
        ++strict;
    }
    printf("PREDCELLS %-34s strict=%zu wide=%zu\n", row, strict, wide);
    return 0;
}
