// carhs.cpp <db.uhdm> : every cont_assign of every module (definition view, then the elaborated tree) with the
// identity (serializer id) of its Lhs and Rhs, to see which objects two cont_assigns share.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <iostream>
#include <map>
using namespace UHDM;
static std::map<const BaseClass*, int> ids;
static int idOf(const BaseClass* p) { if (!p) return 0; auto it = ids.find(p); if (it != ids.end()) return it->second; int n = ids.size() + 1; ids[p] = n; return n; }
static void cas(const std::string& tag, const BaseClass* holder, const VectorOfcont_assign* v) {
    if (!v) return;
    for (auto* c : *v)
        std::cout << tag << " ca#" << idOf(c) << " " << c->VpiLineNo() << ":" << c->VpiColumnNo() << " lhs#" << idOf(c->Lhs())
                  << "(" << (c->Lhs() ? UhdmName(c->Lhs()->UhdmType()) : "-") << ") rhs#" << idOf(c->Rhs()) << "("
                  << (c->Rhs() ? UhdmName(c->Rhs()->UhdmType()) : "-") << ")\n";
}
static void walk(const module_inst* m, const std::string& path) {
    cas("ELAB " + path, m, m->Cont_assigns());
    if (m->Modules()) for (auto* c : *m->Modules()) walk(c, path + "." + std::string(c->VpiName()));
    if (m->Gen_scope_arrays()) for (auto* ga : *m->Gen_scope_arrays()) if (ga->Gen_scopes()) for (auto* gs : *ga->Gen_scopes()) {
        cas("ELAB " + path + "." + std::string(ga->VpiName()), gs, gs->Cont_assigns());
        if (gs->Modules()) for (auto* c : *gs->Modules()) walk(c, path + "." + std::string(ga->VpiName()) + "." + std::string(c->VpiName()));
    }
}
int main(int argc, char** argv) {
    Serializer s; auto designs = s.Restore(std::string(argv[1]));
    for (auto h : designs) {
        design* d = UhdmDesignFromVpiHandle(h);
        if (d->AllModules()) for (auto* m : *d->AllModules()) cas("DEF " + std::string(m->VpiName()), m, m->Cont_assigns());
        if (d->TopModules()) for (auto* m : *d->TopModules()) walk(m, std::string(m->VpiName()));
    }
}
