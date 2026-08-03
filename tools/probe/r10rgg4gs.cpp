// r10rgg4gs: gen-tree stepper.  Walks a module's Gen_stmts pairwise (golden vs
// ours) and, for every differing gen_region/gen_if/gen_for/gen_scope pair,
// reports which VECTOR of the scope diverges and prints both element lists.
// Answers "what is in Instance_items / Modules / Interfaces and in what order".
//   r10rgg4gs <golden.uhdm> <ours.uhdm> <defname-substring> [--elab]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string nm(const BaseClass* o) {
    if (!o) return "<null>";
    return std::string(UhdmName(o->UhdmType())) + "(" + std::string(o->VpiName()) +
           ")@" + std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo());
}

static void walkAny(const any* a, const any* b, const std::string& tag);

template <typename T>
static void step(const std::string& tag, const std::vector<T*>* a,
                 const std::vector<T*>* b) {
    size_t sa = a ? a->size() : 0, sb = b ? b->size() : 0;
    bool bad = sa != sb;
    std::vector<size_t> diffs;
    if (!bad)
        for (size_t i = 0; i < sa; i++) {
            CompareContext c;
            const BaseClass* la = (*a)[i];
            const BaseClass* lb = (*b)[i];
            int r = (la && lb) ? la->Compare(lb, &c) : (la ? 1 : (lb ? -1 : 0));
            if (r != 0) diffs.push_back(i);
        }
    if (!bad && diffs.empty()) return;
    std::cout << tag << ": " << (bad ? "SIZE" : "ELEM") << " lhs=" << (int)sa
              << " rhs=" << (int)sb << "\n";
    for (size_t i = 0; i < (sa > sb ? sa : sb) && i < 60; i++) {
        bool d = bad || (std::find(diffs.begin(), diffs.end(), i) != diffs.end());
        std::cout << "    " << (d ? "* " : "  ") << "[" << i << "] "
                  << (a && i < sa ? nm((*a)[i]) : std::string("-")) << "  |  "
                  << (b && i < sb ? nm((*b)[i]) : std::string("-")) << "\n";
    }
    // Recurse into same-size differing element pairs so nested gen scopes get
    // their own vector report.
    if (!bad)
        for (size_t i : diffs) walkAny((const any*)(*a)[i], (const any*)(*b)[i],
                                       tag + "[" + std::to_string(i) + "]");
}

static void walkScope(const scope* a, const scope* b, const std::string& tag) {
#define S(X) step(tag + "." #X, a->X(), b->X())
    S(Parameters);
    S(Param_assigns);
    S(Typespecs);
    S(Variables);
    S(Logic_vars);
    S(Array_vars);
    S(Named_events);
    S(Property_decls);
    S(Sequence_decls);
    S(Let_decls);
    S(Concurrent_assertions);
    S(Instance_items);
    S(Scopes);
#undef S
    if (a->UhdmType() == uhdmgen_scope && b->UhdmType() == uhdmgen_scope) {
        auto* ga = (const gen_scope*)a;
        auto* gb = (const gen_scope*)b;
#define S(X) step(tag + "." #X, ga->X(), gb->X())
        S(Nets);
        S(Array_nets);
        S(Cont_assigns);
        S(Process);
        S(Modules);
        S(Module_arrays);
        S(Interfaces);
        S(Interface_arrays);
        S(Primitives);
        S(Primitive_arrays);
        S(Gen_scope_arrays);
        S(Task_funcs);
        S(Def_params);
        S(Clocking_blocks);
        S(Alias_stmts);
        S(Assertions);
        S(Elab_tasks);
#undef S
    }
}

static void walkAny(const any* a, const any* b, const std::string& tag) {
    if (!a && !b) return;
    if (!a || !b) {
        std::cout << tag << ": NULL " << nm(a) << " vs " << nm(b) << "\n";
        return;
    }
    if (a->UhdmType() != b->UhdmType()) {
        std::cout << tag << ": TYPE " << nm(a) << " vs " << nm(b) << "\n";
        return;
    }
    switch (a->UhdmType()) {
        case uhdmgen_region: {
            walkAny(((const gen_region*)a)->VpiStmt(),
                    ((const gen_region*)b)->VpiStmt(), tag + ".stmt");
            break;
        }
        case uhdmgen_if: {
            auto* x = (const gen_if*)a;
            auto* y = (const gen_if*)b;
            CompareContext c;
            if (x->VpiCondition() && y->VpiCondition() &&
                x->VpiCondition()->Compare(y->VpiCondition(), &c) != 0)
                std::cout << tag << ".cond: " << nm(x->VpiCondition()) << " vs "
                          << nm(y->VpiCondition()) << "\n";
            walkAny(x->VpiStmt(), y->VpiStmt(), tag + ".stmt");
            break;
        }
        case uhdmgen_if_else: {
            auto* x = (const gen_if_else*)a;
            auto* y = (const gen_if_else*)b;
            walkAny(x->VpiStmt(), y->VpiStmt(), tag + ".stmt");
            walkAny(x->VpiElseStmt(), y->VpiElseStmt(), tag + ".else");
            break;
        }
        case uhdmgen_for: {
            auto* x = (const gen_for*)a;
            auto* y = (const gen_for*)b;
            walkAny(x->VpiStmt(), y->VpiStmt(), tag + ".stmt");
            break;
        }
        case uhdmgen_scope: {
            walkScope((const scope*)a, (const scope*)b, tag);
            break;
        }
        case uhdmgen_scope_array: {
            auto* x = (const gen_scope_array*)a;
            auto* y = (const gen_scope_array*)b;
            step(tag + ".Gen_scopes", x->Gen_scopes(), y->Gen_scopes());
            break;
        }
        case uhdmbegin: {
            step(tag + ".Stmts", ((const begin*)a)->Stmts(),
                 ((const begin*)b)->Stmts());
            break;
        }
        case uhdmnamed_begin: {
            step(tag + ".Stmts", ((const named_begin*)a)->Stmts(),
                 ((const named_begin*)b)->Stmts());
            break;
        }
        case uhdmcont_assign: {
            auto* x = (const cont_assign*)a;
            auto* y = (const cont_assign*)b;
            walkAny(x->Lhs(), y->Lhs(), tag + ".Lhs");
            walkAny(x->Rhs(), y->Rhs(), tag + ".Rhs");
            break;
        }
        case uhdmoperation: {
            auto* x = (const operation*)a;
            auto* y = (const operation*)b;
            if (x->VpiOpType() != y->VpiOpType())
                std::cout << tag << ": OPTYPE " << x->VpiOpType() << " vs "
                          << y->VpiOpType() << "\n";
            step(tag + ".Operands", x->Operands(), y->Operands());
            break;
        }
        case uhdmbit_select:
        case uhdmpart_select:
        case uhdmindexed_part_select:
        case uhdmref_obj:
        case uhdmhier_path:
        default: {
            CompareContext c;
            int r = a->Compare(b, &c);
            std::cout << tag << ": LEAF r=" << r << " " << nm(a) << " vs "
                      << nm(b) << "\n";
            if (r != 0)
                std::cout << "        failLhs " << nm(c.m_failedLhs)
                          << "\n        failRhs " << nm(c.m_failedRhs) << "\n";
            break;
        }
    }
}

int main(int argc, char** argv) {
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    auto* da = (design*)((uhdm_handle*)ha[0])->object;
    auto* db = (design*)((uhdm_handle*)hb[0])->object;
    std::string want = argc > 3 ? argv[3] : "";
    bool elab = argc > 4 && std::string(argv[4]) == "--elab";
    std::function<void(const module_inst*, const module_inst*,
                       const std::string&)>
        doMod = [&](const module_inst* A, const module_inst* B,
                    const std::string& tag) {
            std::cout << "== " << tag << " " << A->VpiDefName() << " / "
                      << A->VpiFullName() << " top=" << A->VpiTop() << "\n";
            step(tag + ".Gen_stmts", A->Gen_stmts(), B->Gen_stmts());
            step(tag + ".Gen_scope_arrays", A->Gen_scope_arrays(),
                 B->Gen_scope_arrays());
            auto* ma = A->Modules();
            auto* mb = B->Modules();
            if (ma && mb && ma->size() == mb->size())
                for (size_t i = 0; i < ma->size(); i++) {
                    CompareContext c2;
                    if ((*ma)[i]->Compare((*mb)[i], &c2) != 0)
                        doMod((*ma)[i], (*mb)[i],
                              tag + "." + std::string((*ma)[i]->VpiName()));
                }
        };
    auto* A = elab ? da->TopModules() : da->AllModules();
    auto* B = elab ? db->TopModules() : db->AllModules();
    if (A && B && A->size() == B->size())
        for (size_t i = 0; i < A->size(); i++) {
            std::string dn((*A)[i]->VpiDefName()), fn((*A)[i]->VpiFullName());
            if (!want.empty() && dn.find(want) == std::string::npos &&
                fn.find(want) == std::string::npos)
                continue;
            doMod((*A)[i], (*B)[i], "M[" + std::to_string(i) + "]");
        }
    return 0;
}
