// r10uvm19c — FOREACH LOOP-VARIABLE census.  For every foreach_stmt in every
// view, one line per vpiLoopVars entry: the owning view/class/subroutine, the
// loop variable's object KIND and its resolved typespec kind+name, plus the
// iterated reference's own typespec.  § foreachAssocIndexVar19 was decoded off
// it — and so was the fact that two goldens built from the SAME uvm-1.2
// sources disagree on the same loop variable, which is what a per-test census
// makes visible.
//   r10uvm19c <file.uhdm> [subroutineNameFilter]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string tsOf(const ref_typespec* r) {
    if (!r) return "-";
    auto* a = r->Actual_typespec();
    if (!a) return "ref<null>";
    return std::string(UhdmName(a->UhdmType())) + "'" + std::string(a->VpiName()) + "'";
}

static std::string g_filt;

static void walk(const std::string& pre, const any* e, int d) {
    if (!e || d > 14) return;
    if (e->UhdmType() == uhdmforeach_stmt) {
        auto* f = (const foreach_stmt*)e;
        std::string it = "-";
        if (auto* v = f->Variable()) {
            it = std::string(UhdmName(v->UhdmType())) + " '" +
                 std::string(v->VpiName()) + "'";
            if (auto* vv = any_cast<const variables*>((const any*)v))
                it += " ts=" + tsOf(vv->Typespec());
        }
        if (auto* lvs = f->VpiLoopVars())
            for (auto* lv : *lvs) {
                std::string k = std::string(UhdmName(lv->UhdmType()));
                std::string t = "-";
                if (auto* vv = any_cast<const variables*>(lv))
                    t = tsOf(vv->Typespec());
                std::cout << pre << " @" << f->VpiLineNo() << ":"
                          << f->VpiColumnNo() << " lv '" << lv->VpiName()
                          << "' " << k << " " << t << "   over " << it << "\n";
            }
    }
    auto sub = [&](const any* c) { walk(pre, c, d + 1); };
    auto subv = [&](const VectorOfany* v) {
        if (v) for (auto* c : *v) walk(pre, c, d + 1);
    };
    switch (e->UhdmType()) {
        case uhdmbegin: subv(((const begin*)e)->Stmts()); break;
        case uhdmnamed_begin: subv(((const named_begin*)e)->Stmts()); break;
        case uhdmforeach_stmt: sub(((const foreach_stmt*)e)->VpiStmt()); break;
        case uhdmfor_stmt: sub(((const for_stmt*)e)->VpiStmt()); break;
        case uhdmwhile_stmt: sub(((const while_stmt*)e)->VpiStmt()); break;
        case uhdmdo_while: sub(((const do_while*)e)->VpiStmt()); break;
        case uhdmrepeat: sub(((const repeat*)e)->VpiStmt()); break;
        case uhdmforever_stmt: sub(((const forever_stmt*)e)->VpiStmt()); break;
        case uhdmif_stmt: sub(((const if_stmt*)e)->VpiStmt()); break;
        case uhdmif_else:
            sub(((const if_else*)e)->VpiStmt());
            sub(((const if_else*)e)->VpiElseStmt());
            break;
        case uhdmcase_stmt:
            if (auto* cis = ((const case_stmt*)e)->Case_items())
                for (auto* ci : *cis) sub(ci->Stmt());
            break;
        default: break;
    }
}

static void emitTf(const std::string& view, const task_func* tf) {
    std::string nm(tf->VpiName());
    if (!g_filt.empty() && nm.find(g_filt) == std::string::npos) return;
    walk(view + "/" + nm, tf->Stmt(), 0);
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    g_filt = argc > 2 ? argv[2] : "";
    auto pkgs = [&](const VectorOfpackage* v, const char* tag) {
        if (!v) return;
        for (auto* p : *v) {
            std::string view = std::string(tag) + "[" + std::string(p->VpiName()) + "]";
            if (auto* tfs = p->Task_funcs())
                for (auto* tf : *tfs) emitTf(view, tf);
            if (auto* cds = p->Class_defns())
                for (auto* c : *cds)
                    if (auto* ms = c->Task_funcs())
                        for (auto* tf : *ms)
                            emitTf(view + "::" + std::string(c->VpiName()), tf);
        }
    };
    pkgs(d->AllPackages(), "DEFPKG");
    pkgs(d->TopPackages(), "ELABPKG");
    auto mods = [&](const VectorOfmodule_inst* v, const char* tag) {
        if (!v) return;
        for (auto* m : *v) {
            std::string view = std::string(tag) + "[" + std::string(m->VpiName()) + "]";
            if (auto* tfs = m->Task_funcs())
                for (auto* tf : *tfs) emitTf(view, tf);
        }
    };
    mods(d->AllModules(), "DEFMOD");
    mods(d->TopModules(), "ELABMOD");
    return 0;
}
