// r10rgmi: list a module instance's Interfaces / Interface_arrays / Ports by
// name (one design at a time, so golden and ours diff as text). Walks
// Modules AND gen_scope_arrays so gen-scope instances are reachable.
//   r10rgmi <design.uhdm> <fullNameSubstr>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string want;

static void show(const module_inst* m) {
    std::cout << "MOD " << m->VpiFullName() << " def=" << m->VpiDefName() << "\n";
    if (auto* v = m->Interfaces())
        for (auto* i : *v)
            std::cout << "  IF  " << i->VpiName() << " @" << i->VpiLineNo() << ":"
                      << i->VpiColumnNo() << " full=" << i->VpiFullName() << "\n";
    if (auto* v = m->Interface_arrays())
        for (auto* i : *v)
            std::cout << "  IFA " << i->VpiName() << " @" << i->VpiLineNo() << ":"
                      << i->VpiColumnNo() << "\n";
    if (auto* v = m->Ports())
        for (auto* p : *v)
            std::cout << "  P   " << p->VpiName() << "\n";
}

static void walkScope(const scope* sc);

static void walkMod(const module_inst* m) {
    if (std::string(m->VpiFullName()).find(want) != std::string::npos) show(m);
    if (m->Modules())
        for (auto* c : *m->Modules()) walkMod(c);
    if (m->Gen_scope_arrays())
        for (auto* ga : *m->Gen_scope_arrays())
            if (ga->Gen_scopes())
                for (auto* g : *ga->Gen_scopes()) walkScope(g);
}

static void walkScope(const scope* sc) {
    if (sc->UhdmType() != uhdmgen_scope) return;
    auto* g = (const gen_scope*)sc;
    if (g->Modules())
        for (auto* c : *g->Modules()) walkMod(c);
    if (g->Gen_scope_arrays())
        for (auto* ga : *g->Gen_scope_arrays())
            if (ga->Gen_scopes())
                for (auto* g2 : *ga->Gen_scopes()) walkScope(g2);
}

int main(int argc, char** argv) {
    Serializer sa;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto* da = (design*)((uhdm_handle*)ha[0])->object;
    want = argc > 2 ? argv[2] : "";
    if (da->TopModules())
        for (auto* t : *da->TopModules()) walkMod(t);
    return 0;
}
