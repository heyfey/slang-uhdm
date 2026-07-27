// Localiser: a package/module task_func's BODY variables and their typespec
// identity. uhdm-cmp reaches these through the body's ref_obj actuals, a path
// neither the typedef-forest probe (w4probe) nor the .ret/.io projection
// covers -- rp32 enc32's union_var return local.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdlib>
#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string loc(const any* o) {
    if (!o) return "-";
    return std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo());
}

static std::string owner(const any* o) {
    if (!o) return "-";
    const any* p = o->VpiParent();
    if (!p) return "NOPARENT";
    return std::string(UhdmName(p->UhdmType())) + "(" +
           std::string(p->VpiName()) + ")@" + loc(p);
}

// Print a typespec member path down to the first RANGE bound, which is the
// fold-state witness (constant vs operation).
static void walk(const std::string& ind, const typespec* t, int depth) {
    if (!t || depth <= 0) return;
    std::cout << ind << UhdmName(t->UhdmType()) << " '" << t->VpiName() << "' @"
              << loc(t) << " par=" << owner(t);
    if (auto* i = t->Instance())
        std::cout << " inst=" << i->VpiName()
                  << (i->UhdmType() == uhdmpackage && ((const package*)i)->VpiTop()
                          ? "#TOP"
                          : "#DEF");
    std::cout << "\n";
    if (t->UhdmType() == uhdmlogic_typespec) {
        if (auto* rs = ((const logic_typespec*)t)->Ranges())
            for (auto* r : *rs)
                std::cout << ind << "  range L="
                          << (r->Left_expr()
                                  ? UhdmName(r->Left_expr()->UhdmType())
                                  : "-")
                          << "\n";
        if (auto* a = ((const logic_typespec*)t)->Typedef_alias())
            walk(ind + "  alias ", a->Actual_typespec(), depth - 1);
        return;
    }
    const VectorOftypespec_member* ms = nullptr;
    if (t->UhdmType() == uhdmstruct_typespec)
        ms = ((const struct_typespec*)t)->Members();
    else if (t->UhdmType() == uhdmunion_typespec)
        ms = ((const union_typespec*)t)->Members();
    if (!ms) return;
    for (auto* m : *ms)
        if (m->Typespec())
            walk(ind + "  " + std::string(m->VpiName()) + ": ",
                 m->Typespec()->Actual_typespec(), depth - 1);
}

template <typename V>
static void doInst(const std::string& tag, V* insts, const std::string& fn) {
    if (!insts) return;
    int idx = 0;
    for (auto* p : *insts) {
        std::string t0 = tag + "[" + std::to_string(idx++) + ":" +
                         std::string(p->VpiName()) + "]";
        if (!p->Task_funcs()) continue;
        for (auto* tf : *p->Task_funcs()) {
            if (!fn.empty() && tf->VpiName() != fn) continue;
            std::cout << t0 << " tf " << tf->VpiName() << " @" << loc(tf)
                      << "\n";
            if (tf->UhdmType() == uhdmfunction)
                if (auto* rv = ((const function*)tf)->Return()) {
                    std::cout << "  RETURN " << UhdmName(rv->UhdmType()) << " '"
                              << rv->VpiName() << "' @" << loc(rv) << "\n";
                    if (rv->Typespec())
                        walk("    ", rv->Typespec()->Actual_typespec(), 4);
                }
            if (auto* vs = tf->Variables())
                for (auto* v : *vs) {
                    std::cout << "  VAR " << UhdmName(v->UhdmType()) << " '"
                              << v->VpiName() << "' @" << loc(v) << "\n";
                    if (v->Typespec())
                        walk("    ", v->Typespec()->Actual_typespec(), 4);
                }
        }
    }
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: w4fnvar <uhdm> [fnname]\n"; return 2; }
    std::string fn = argc > 2 ? argv[2] : "";
    Serializer s;
    auto hs = s.Restore(std::filesystem::path(argv[1]));
    auto* d = (design*)((uhdm_handle*)hs[0])->object;
    doInst("Pkg", d->AllPackages(), fn);
    doInst("TopPkg", d->TopPackages(), fn);
    doInst("AllMod", d->AllModules(), fn);
    doInst("TopMod", d->TopModules(), fn);
    return 0;
}
