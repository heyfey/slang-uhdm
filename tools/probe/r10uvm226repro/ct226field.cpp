// r10uvm226 — WHICH FIELD OF THE HEAD OBJECT DISAGREES.  MEASUREMENT-ONLY;
// COPIED VERBATIM from r10uvm225repro/ct225field.cpp (only these two header
// lines and the two banner strings differ), so the head-field reading is the
// same instrument the previous pass used.
// the official `uhdm-cmp` remains the sole acceptance judge.
//
// `uhdm-cmp` prints only the failing OBJECT, and for a vector mismatch whose
// RHS container is null it prints `LHS: <the owner>` / `RHS: <null>` — the
// SAME two lines whichever of the owner's vectors is the one that failed
// (RESUME §9's VECTOR-overload signature).  MiniAmiq's head is exactly that
// shape, so the cmp log is byte-identical before and after a change that fixes
// ONE of those vectors and leaves the NEXT one empty.  This probe names the
// field, so "the head moved" is measured instead of asserted.
//
// It restores both databases, finds the named `interface_inst` in each and
// walks `instance::Compare`'s and `interface_inst::Compare`'s OWN field
// sequences (UHDM/build/generated/src/{instance,interface_inst}.cpp) IN SOURCE
// ORDER through ONE `CompareContext`, exactly as the shipped walk does, and
// stops at the first field that disagrees.  Nothing in UHDM is patched: the
// two `SafeCompare` bodies below are transcribed VERBATIM from
// `~/.local/include/uhdm/BaseClass.h:187-224` because they are `protected`
// there, and every object comparison goes through the shipped
// `BaseClass::Compare`.
//
//   build: g++ -O2 -std=c++17 ct226field.cpp -I ~/.local/include \
//              -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj \
//              -o ct226field
//   usage: ./ct226field <golden.uhdm> <ours.uhdm> <VpiFullName>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <filesystem>
#include <string>
#include <vector>

using namespace UHDM;

// BaseClass.h:187-199, verbatim.
static int32_t SafeCmp(const BaseClass* lhs, const BaseClass* rhs,
                       CompareContext* context) {
    if ((lhs != nullptr) && (rhs != nullptr)) {
        return lhs->Compare(rhs, context);
    }
    else if ((lhs != nullptr) && (rhs == nullptr)) {
        context->m_failedLhs = lhs;
        return 1;
    }
    else if ((lhs == nullptr) && (rhs != nullptr)) {
        context->m_failedRhs = rhs;
        return -1;
    }
    return 0;
}

// BaseClass.h:202-224, verbatim.
template <typename T>
static int32_t SafeCmp(const BaseClass* lhs_obj, const std::vector<T*>* lhs,
                       const BaseClass* rhs_obj, const std::vector<T*>* rhs,
                       CompareContext* context) {
    if ((lhs != nullptr) && (rhs != nullptr)) {
        int32_t r = 0;
        if ((r = static_cast<int32_t>(lhs->size() - rhs->size())) != 0) {
            context->m_failedLhs = lhs_obj;
            context->m_failedRhs = rhs_obj;
            return 1;
        }
        for (size_t i = 0, n = lhs->size(); i < n; ++i) {
            if ((r = SafeCmp(lhs->at(i), rhs->at(i), context)) != 0)
                return r;
        }
    }
    else if ((lhs != nullptr) && !lhs->empty() && (rhs == nullptr)) {
        context->m_failedLhs = lhs_obj;
        return 1;
    }
    else if ((lhs == nullptr) && (rhs != nullptr) && !rhs->empty()) {
        context->m_failedRhs = rhs_obj;
        return -1;
    }
    return 0;
}

static const interface_inst* findIface(Serializer& s, const std::string& name) {
    for (auto& [obj, id] : s.AllObjects()) {
        (void)id;
        if (!obj || obj->UhdmType() != uhdminterface_inst)
            continue;
        auto* ii = (const interface_inst*)obj;
        if (ii->VpiFullName() == name)
            return ii;
    }
    return nullptr;
}

static std::string sz(const void* v, size_t n) {
    return v ? std::to_string(n) : std::string("null");
}

int main(int argc, char** argv) {
    if (argc < 4) {
        fprintf(stderr, "usage: ct226field <golden> <ours> <VpiFullName>\n");
        return 2;
    }
    Serializer sg, so;
    auto hg = sg.Restore(std::filesystem::path(argv[1]));
    auto ho = so.Restore(std::filesystem::path(argv[2]));
    if (hg.empty() || ho.empty()) {
        fprintf(stderr, "RESTORE FAILED\n");
        return 3;
    }
    const interface_inst* g = findIface(sg, argv[3]);
    const interface_inst* o = findIface(so, argv[3]);
    printf("# ct226field MEASUREMENT-ONLY — uhdm-cmp remains the sole judge\n");
    printf("# GOLDEN %s\n# OURS   %s\n# OBJECT %s\n", argv[1], argv[2], argv[3]);
    if (!g || !o) {
        printf("NOT FOUND golden=%d ours=%d\n", g != nullptr, o != nullptr);
        return 4;
    }
    CompareContext c;
    const char* first = nullptr;
    int firstR = 0;

#define FVEC(NAME, GETTER)                                                  \
    do {                                                                    \
        auto* lv = g->GETTER();                                             \
        auto* rv = o->GETTER();                                             \
        int r = first ? 0 : SafeCmp(g, lv, o, rv, &c);                      \
        printf("%-22s golden=%-5s ours=%-5s %s\n", NAME,                    \
               sz(lv, lv ? lv->size() : 0).c_str(),                         \
               sz(rv, rv ? rv->size() : 0).c_str(),                         \
               first ? "(not reached)" : (r ? "<-- DISAGREES" : "agrees")); \
        if (r && !first) { first = NAME; firstR = r; }                       \
    } while (0)
#define FONE(NAME, GETTER)                                                  \
    do {                                                                    \
        int r = first ? 0 : SafeCmp(g->GETTER(), o->GETTER(), &c);          \
        printf("%-22s golden=%-5s ours=%-5s %s\n", NAME,                    \
               g->GETTER() ? "obj" : "null", o->GETTER() ? "obj" : "null",  \
               first ? "(not reached)" : (r ? "<-- DISAGREES" : "agrees")); \
        if (r && !first) { first = NAME; firstR = r; }                       \
    } while (0)

    // instance::Compare, in source order (generated/src/instance.cpp).
    FVEC("Nets", Nets);
    FVEC("Array_nets", Array_nets);
    FVEC("Variables", Variables);
    FVEC("Array_vars", Array_vars);
    FVEC("Named_events", Named_events);
    FVEC("Parameters", Parameters);
    FVEC("Param_assigns", Param_assigns);
    FVEC("Typespecs", Typespecs);
    // interface_inst::Compare's own list (generated/src/interface_inst.cpp).
    FVEC("Interface_tf_decls", Interface_tf_decls);
    FVEC("Modports", Modports);
    FONE("Global_clocking", Global_clocking);
    FONE("Default_clocking", Default_clocking);
    FONE("Expr_dist", Expr_dist);
    FONE("Instance_array", Instance_array);
    FVEC("Mod_paths", Mod_paths);
    FVEC("Cont_assigns", Cont_assigns);
    FVEC("Clocking_blocks", Clocking_blocks);
    FVEC("Interfaces", Interfaces);
    FVEC("Interface_arrays", Interface_arrays);
    FVEC("Process", Process);
    FVEC("Ports", Ports);
    FVEC("Gen_scope_arrays", Gen_scope_arrays);
    FVEC("Elab_tasks", Elab_tasks);
    FVEC("Gen_stmts", Gen_stmts);
    printf("FIRST-DISAGREEING-FIELD %s r=%d\n", first ? first : "<none>",
           firstR);
    return 0;
}
