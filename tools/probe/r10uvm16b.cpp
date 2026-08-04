// r10uvm16b: per-package Task_funcs Io_decls/Variables typespec IDENTITY.
// Answers "is the importing package's copy of an imported subroutine the SAME
// object as the declaring package's, and does it bind the SAME typespec?" —
// the question the typedef NAMING half turns on.
//   r10uvm16b <file.uhdm> [tfNameFilter]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static void dumpTs(const char* lbl, const ref_typespec* rt) {
    if (!rt) {
        std::cout << " " << lbl << "=<noref>";
        return;
    }
    auto* at = rt->Actual_typespec();
    if (!at) {
        std::cout << " " << lbl << "=ref#" << rt->UhdmId() << "->null";
        return;
    }
    std::cout << " " << lbl << "=#" << at->UhdmId() << "'" << at->VpiName()
              << "'@" << at->VpiLineNo() << ":" << at->VpiColumnNo();
    // ...and the alias chain: bit_typespec::Compare walks Typedef_alias, so a
    // pair that agrees on the bound object can still fail one level deeper.
    const typespec* cur = at;
    for (int i = 0; i < 4; i++) {
        auto* al = cur->Typedef_alias();
        auto* tg = al ? al->Actual_typespec() : nullptr;
        if (!tg) break;
        std::cout << "->#" << tg->UhdmId() << "'" << tg->VpiName() << "'@"
                  << tg->VpiLineNo() << ":" << tg->VpiColumnNo();
        cur = tg;
    }
}

static void doTf(const std::string& scope, const task_func* tf) {
    std::cout << scope << " tf#" << tf->UhdmId() << " " << tf->VpiName();
    if (tf->Io_decls())
        for (size_t i = 0; i < tf->Io_decls()->size(); i++)
            dumpTs(("io" + std::to_string(i)).c_str(),
                   (*tf->Io_decls())[i]->Typespec());
    if (tf->Variables())
        for (size_t i = 0; i < tf->Variables()->size(); i++)
            dumpTs(("v" + std::to_string(i)).c_str(),
                   (*tf->Variables())[i]->Typespec());
    std::cout << "\n";
    // ...and the STATEMENT side: an assignment's Lhs/Rhs carry their OWN
    // ref_typespec, which need not be the declaration's.
    const any* b = tf->Stmt();
    if (b && b->UhdmType() == uhdmbegin) {
        auto* sv = ((const begin*)b)->Stmts();
        if (sv)
            for (size_t i = 0; i < sv->size() && i < 6; i++) {
                auto* st = (*sv)[i];
                if (st->UhdmType() != uhdmassignment) continue;
                auto* as = (const assignment*)st;
                std::cout << "    stmt" << i;
                // The ref's ACTUAL is what expr::Compare descends into, and a
                // clone body may point it at the HOME declaration.
                auto side = [&](const char* lbl, const any* e) {
                    if (auto* x = dynamic_cast<const expr*>(e))
                        dumpTs(lbl, x->Typespec());
                    const any* act = nullptr;
                    if (e && e->UhdmType() == uhdmref_obj)
                        act = ((const ref_obj*)e)->Actual_group();
                    if (!act) return;
                    std::cout << " " << lbl << ".act=#" << act->UhdmId() << " "
                              << UhdmName(act->UhdmType()) << "'"
                              << act->VpiName() << "'";
                    if (auto* v = dynamic_cast<const variables*>(act))
                        dumpTs("ts", v->Typespec());
                    if (auto* io = dynamic_cast<const io_decl*>(act))
                        dumpTs("ts", io->Typespec());
                };
                side("lhs", as->Lhs());
                side("rhs", as->Rhs());
                std::cout << "\n";
            }
    }
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    std::string filt = argc > 2 ? argv[2] : "";
    auto run = [&](const char* lbl, auto* v) {
        if (!v) return;
        for (auto* p : *v) {
            std::string sc = std::string(lbl) + "[" + std::string(p->VpiName()) + "]";
            if (p->Task_funcs())
                for (auto* tf : *p->Task_funcs())
                    if (filt.empty() ||
                        std::string(tf->VpiName()).find(filt) != std::string::npos)
                        doTf(sc, tf);
            if constexpr (requires { p->Class_defns(); }) {
                if (p->Class_defns())
                    for (auto* c : *p->Class_defns())
                        if (c->Task_funcs())
                            for (auto* tf : *c->Task_funcs())
                                if (filt.empty() ||
                                    std::string(tf->VpiName()).find(filt) !=
                                        std::string::npos)
                                    doTf(sc + "::" + std::string(c->VpiName()), tf);
            }
        }
    };
    run("DEFPKG", d->AllPackages());
    run("ELABPKG", d->TopPackages());
    run("DEFMOD", d->AllModules());
    run("ELABMOD", d->TopModules());
    return 0;
}
