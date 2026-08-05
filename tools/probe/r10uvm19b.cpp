// r10uvm19b — STATEMENT-TREE typespec census.  r10uvm18a projects the
// DECLARATION side (io_decl / return / body-local typespecs); pass 18 closed
// that side, and the whole remaining `constant vs operation` family lives on
// the EXPRESSION side instead: the typespec an expression inside a statement
// carries.  This walks a task_func's Stmt tree and prints, for every `expr`
// that has a Typespec, the resolved typespec's identity, its packed-range LEFT
// bound kind (operation = symbolic, const:<v> = folded) and its VpiParent kind
// — "is this the package's own listing object, or a per-occurrence clone?" is
// the whole question.
//   r10uvm19b <file.uhdm> [tfNameFilter] [viewFilter]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>
#include <vector>
using namespace UHDM;

static std::map<const BaseClass*, int> g_id;
static int idOf(const BaseClass* o) {
    if (!o) return 0;
    auto it = g_id.find(o);
    if (it != g_id.end()) return it->second;
    int n = (int)g_id.size() + 1;
    g_id[o] = n;
    return n;
}

static std::string boundOf(const typespec* t) {
    if (!t) return "<null>";
    const VectorOfrange* rs = nullptr;
    if (auto* lt = any_cast<const logic_typespec*>(t)) rs = lt->Ranges();
    else if (auto* bt = any_cast<const bit_typespec*>(t)) rs = bt->Ranges();
    else if (auto* at = any_cast<const array_typespec*>(t)) rs = at->Ranges();
    if (!rs || rs->empty()) return "-";
    const expr* l = (*rs)[0]->Left_expr();
    if (!l) return "<noleft>";
    if (l->UhdmType() == uhdmconstant)
        return "const:" + std::string(((const constant*)l)->VpiDecompile());
    return std::string(UhdmName(l->UhdmType()));
}

// Where the typespec object HANGS — the discriminator between a package
// listing object (parent = package) and a per-declaration clone.
static std::string ownerOf(const BaseClass* o) {
    auto* p = o ? o->VpiParent() : nullptr;
    if (!p) return "<noparent>";
    return std::string(UhdmName(p->UhdmType())) + " '" +
           std::string(p->VpiName()) + "'";
}

static std::string tsLine(const typespec* t) {
    if (!t) return "<null>";
    return "#" + std::to_string(idOf(t)) + " " +
           std::string(UhdmName(t->UhdmType())) + " '" +
           std::string(t->VpiName()) + "'@" + std::to_string(t->VpiLineNo()) +
           ":" + std::to_string(t->VpiColumnNo()) + " [" + boundOf(t) +
           "] under " + ownerOf(t);
}

static const typespec* actOf(const ref_typespec* r) {
    return r ? r->Actual_typespec() : nullptr;
}

// A statement-tree node's typespec lives in two places: on the expr itself,
// and — for a ref_obj — on the VARIABLE its vpiActual names, which is the
// object Compare actually walks into.
static const ref_typespec* tsRefOf(const any* e) {
    if (!e) return nullptr;
    if (auto* v = any_cast<const variables*>(e)) return v->Typespec();
    if (auto* ex = any_cast<const expr*>(e)) return ex->Typespec();
    return nullptr;
}

static void report(const std::string& pre, const any* e) {
    const typespec* at = actOf(tsRefOf(e));
    if (!at) return;
    if (boundOf(at) == "-" || boundOf(at) == "<null>") return;
    std::cout << pre << " " << UhdmName(e->UhdmType()) << " '" << e->VpiName()
              << "'@" << e->VpiLineNo() << ":" << e->VpiColumnNo()
              << " ts=" << tsLine(at);
    if (auto* al = at->Typedef_alias()) std::cout << "  ->  " << tsLine(actOf(al));
    std::cout << "\n";
}

static void walk(const std::string& pre, const any* e, int d) {
    if (!e || d > 12) return;
    report(pre, e);
    if (e->UhdmType() == uhdmref_obj)
        if (auto* a = ((const ref_obj*)e)->Actual_group()) report(pre + "!act", a);
    // generic child walk over the shapes a statement tree is made of
    auto sub = [&](const any* c, const char* tag) {
        if (c) walk(pre + "/" + tag, c, d + 1);
    };
    auto subv = [&](const VectorOfany* v, const char* tag) {
        if (!v) return;
        for (size_t i = 0; i < v->size(); i++)
            walk(pre + "/" + tag + std::to_string(i), (*v)[i], d + 1);
    };
    switch (e->UhdmType()) {
        case uhdmbegin: subv(((const begin*)e)->Stmts(), "s"); break;
        case uhdmnamed_begin:
            subv(((const named_begin*)e)->Stmts(), "s");
            break;
        case uhdmassignment:
            sub(((const assignment*)e)->Lhs(), "lhs");
            sub(((const assignment*)e)->Rhs(), "rhs");
            break;
        case uhdmreturn_stmt:
            sub(((const return_stmt*)e)->VpiCondition(), "ret");
            break;
        case uhdmif_stmt:
            sub(((const if_stmt*)e)->VpiCondition(), "cond");
            sub(((const if_stmt*)e)->VpiStmt(), "then");
            break;
        case uhdmif_else:
            sub(((const if_else*)e)->VpiCondition(), "cond");
            sub(((const if_else*)e)->VpiStmt(), "then");
            sub(((const if_else*)e)->VpiElseStmt(), "else");
            break;
        case uhdmoperation: subv(((const operation*)e)->Operands(), "o"); break;
        case uhdmfunc_call: subv(((const func_call*)e)->Tf_call_args(), "a"); break;
        case uhdmmethod_func_call:
            subv(((const method_func_call*)e)->Tf_call_args(), "a");
            break;
        case uhdmtask_call: subv(((const task_call*)e)->Tf_call_args(), "a"); break;
        case uhdmmethod_task_call:
            subv(((const method_task_call*)e)->Tf_call_args(), "a");
            break;
        default: break;
    }
}

static std::string g_tf, g_view;
static void emitTf(const std::string& view, const task_func* tf) {
    std::string nm(tf->VpiName());
    if (!g_tf.empty() && nm.find(g_tf) == std::string::npos) return;
    if (!g_view.empty() && view.find(g_view) == std::string::npos) return;
    walk(view + "/" + nm, tf->Stmt(), 0);
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    g_tf = argc > 2 ? argv[2] : "";
    g_view = argc > 3 ? argv[3] : "";
    auto pkgs = [&](const VectorOfpackage* v, const char* tag) {
        if (!v) return;
        for (auto* p : *v) {
            std::string view =
                std::string(tag) + "[" + std::string(p->VpiName()) + "]";
            if (auto* tfs = p->Task_funcs())
                for (auto* tf : *tfs) emitTf(view, tf);
            if (auto* cds = p->Class_defns())
                for (auto* c : *cds)
                    if (auto* ms = c->Task_funcs())
                        for (auto* tf : *ms)
                            emitTf(view + "::" + std::string(c->VpiName()), tf);
        }
    };
    // AllPackages is the DEF listing, TopPackages the ELABORATED one (same
    // labels r10uvm7b/r10uvm18a use — swapping them inverts every law here).
    pkgs(d->AllPackages(), "DEFPKG");
    pkgs(d->TopPackages(), "ELABPKG");
    auto mods = [&](const VectorOfmodule_inst* v, const char* tag) {
        if (!v) return;
        for (auto* m : *v) {
            std::string view =
                std::string(tag) + "[" + std::string(m->VpiName()) + "]";
            if (auto* tfs = m->Task_funcs())
                for (auto* tf : *tfs) emitTf(view, tf);
        }
    };
    mods(d->AllModules(), "DEFMOD");
    mods(d->TopModules(), "ELABMOD");
    return 0;
}
