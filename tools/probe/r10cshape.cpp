// r9mstep: like r9step, but steps a MODULE's own vectors (def view and elab
// view) so a module-level r=1 says WHICH container diverges.
//   r9mstep <golden.uhdm> <ours.uhdm> [defname-substring]
// Walks AllModules pairwise; for each pair whose Compare != 0, reports every
// vector that differs (size or element), then recurses into sub-modules.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string nm(const BaseClass* o) {
    if (!o) return "<null>";
    std::string s = std::string(UhdmName(o->UhdmType())) + "(" +
                    std::string(o->VpiName()) + ")@" +
                    std::to_string(o->VpiLineNo()) + ":" +
                    std::to_string(o->VpiColumnNo());
    if (o->UhdmType() == uhdmconstant) {
        const constant* c = (const constant*)o;
        s += " {ct=" + std::to_string(c->VpiConstType()) +
             " sz=" + std::to_string(c->VpiSize()) + " dec='" +
             std::string(c->VpiDecompile()) + "' val='" +
             std::string(c->VpiValue()) + "' ts=" +
             (c->Typespec() ? std::string(UhdmName(
                                  c->Typespec()->Actual_typespec()
                                      ? c->Typespec()->Actual_typespec()->UhdmType()
                                      : uhdmref_typespec))
                            : std::string("<null>")) +
             "}";
    }
    if (o->UhdmType() == uhdmref_typespec) {
        const ref_typespec* r = (const ref_typespec*)o;
        s += " {act=" +
             (r->Actual_typespec()
                  ? std::string(UhdmName(r->Actual_typespec()->UhdmType())) + "(" +
                        std::string(r->Actual_typespec()->VpiName()) + ")"
                  : std::string("<null>")) +
             "}";
    }
    return s;
}

static int gFail = 0;

template <typename T>
static void step(const std::string& tag, const std::vector<T*>* a,
                 const std::vector<T*>* b, CompareContext& c) {
    size_t sa = a ? a->size() : 0, sb = b ? b->size() : 0;
    if (sa != sb) {
        std::cout << tag << ": SIZE lhs=" << (int)sa << " rhs=" << (int)sb << "\n";
        for (size_t i = 0; i < (sa > sb ? sa : sb) && i < 80; i++)
            std::cout << "    [" << i << "] "
                      << (a && i < sa ? nm((*a)[i]) : std::string("-")) << "  |  "
                      << (b && i < sb ? nm((*b)[i]) : std::string("-")) << "\n";
        gFail++;
        return;
    }
    for (size_t i = 0; i < sa; i++) {
        c.m_failedLhs = nullptr;
        c.m_failedRhs = nullptr;
        const BaseClass* la = (*a)[i];
        const BaseClass* lb = (*b)[i];
        int r = (la && lb) ? la->Compare(lb, &c) : (la ? 1 : (lb ? -1 : 0));
        if (r != 0) {
            std::cout << tag << "[" << i << "] r=" << r << " " << nm(la)
                      << " vs " << nm(lb) << "\n";
            std::cout << "    failLhs " << nm(c.m_failedLhs) << "\n";
            std::cout << "    failRhs " << nm(c.m_failedRhs) << "\n";
            for (const BaseClass* p = c.m_failedLhs; p; p = p->VpiParent())
                std::cout << "      upL: " << nm(p) << "\n";
            for (const BaseClass* p = c.m_failedRhs; p; p = p->VpiParent())
                std::cout << "      upR: " << nm(p) << "\n";
            gFail++;
            return;
        }
    }
}

static void walkMod(const module_inst* a, const module_inst* b,
                    const std::string& tag) {
    std::cout << "== " << tag << " " << a->VpiDefName() << " / "
              << a->VpiFullName() << " (top=" << a->VpiTop() << ")\n";
    CompareContext c;
#define S(X) step(tag + "." #X, a->X(), b->X(), c)
    S(Ports);
    S(Nets);
    S(Array_nets);
    S(Variables);
    S(Array_vars);
    S(Logic_vars);
    S(Named_events);
    S(Parameters);
    S(Param_assigns);
    S(Typespecs);
    S(Cont_assigns);
    S(Process);
    S(Gen_stmts);
    S(Gen_scope_arrays);
    S(Modules);
    S(Module_arrays);
    S(Ref_modules);
    S(Interfaces);
    S(Interface_arrays);
    S(Primitives);
    S(Primitive_arrays);
    S(Task_funcs);
    S(Class_defns);
    S(Property_decls);
    S(Sequence_decls);
    S(Let_decls);
    S(Assertions);
    S(Io_decls);
    S(Def_params);
    S(Clocking_blocks);
    S(Scopes);
    S(Instance_items);
    S(Concurrent_assertions);
    S(Spec_params);
    S(Virtual_interface_vars);
#undef S
    // Recurse into sub-modules only when sizes agree.
    auto* ma = a->Modules();
    auto* mb = b->Modules();
    if (ma && mb && ma->size() == mb->size())
        for (size_t i = 0; i < ma->size(); i++) {
            CompareContext c2;
            if ((*ma)[i]->Compare((*mb)[i], &c2) != 0)
                walkMod((*ma)[i], (*mb)[i], tag + "." + std::string((*ma)[i]->VpiName()));
        }
}

int main(int argc, char** argv) {
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    auto* da = (design*)((uhdm_handle*)ha[0])->object;
    auto* db = (design*)((uhdm_handle*)hb[0])->object;
    std::string want = argc > 3 ? argv[3] : "";
    auto* A = da->AllModules();
    auto* B = db->AllModules();
    if (A && B && A->size() == B->size()) {
        for (size_t i = 0; i < A->size(); i++) {
            std::string dn((*A)[i]->VpiDefName());
            std::string fn((*A)[i]->VpiFullName());
            if (!want.empty() && dn.find(want) == std::string::npos &&
                fn.find(want) == std::string::npos)
                continue;
            CompareContext c2;
            if ((*A)[i]->Compare((*B)[i], &c2) != 0)
                walkMod((*A)[i], (*B)[i], "AllModules[" + std::to_string(i) + "]");
        }
    } else {
        std::cout << "AllModules SIZE " << (A ? A->size() : 0) << " vs "
                  << (B ? B->size() : 0) << "\n";
    }
    auto* TA = da->TopModules();
    auto* TB = db->TopModules();
    if (TA && TB && TA->size() == TB->size())
        for (size_t i = 0; i < TA->size(); i++) {
            std::string dn((*TA)[i]->VpiDefName());
            std::string fn((*TA)[i]->VpiFullName());
            if (!want.empty() && dn.find(want) == std::string::npos &&
                fn.find(want) == std::string::npos)
                continue;
            CompareContext c2;
            if ((*TA)[i]->Compare((*TB)[i], &c2) != 0)
                walkMod((*TA)[i], (*TB)[i], "TopModules[" + std::to_string(i) + "]");
        }
    return 0;
}
