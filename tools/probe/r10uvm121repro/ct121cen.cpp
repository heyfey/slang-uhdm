// r10uvm121 — ASSIGNMENT CENSUS (measurement only; the official uhdm-cmp is
// the judge).
//
// For every REACHABLE `assignment` in a database print one row:
//
//   VIEW <TAB> TOP <TAB> HOME <TAB> SPAN <TAB> RHS <TAB> LHS
//
//   VIEW  DEF  (the root container is in design::All{Packages,Modules,Classes})
//         ELAB (the root container is in design::Top{Packages,Modules})
//   TOP   the root container's VpiName
//   HOME  the compressed owner chain (class_defn / function / task names,
//         outermost first) — the judge-visible identity of the slot
//   SPAN  line:col-endline:endcol  (NO file: our objects carry an EMPTY
//         VpiFile — uvm113's census trap — and the two producers disagree
//         about macro-expansion file names)
//   RHS   "<null>" or <kind>|<name>
//   LHS   "<null>" or <kind>|<name>
//
// Reachability: the vpiParent chain must terminate at the design object
// (uvm97's lesson: Serializer::AllObjects also holds objects that are in NO
// dump tree and can never be reached by the judge).
//
// build: g++ -O2 -std=c++17 ct121cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct121cen
// usage: ct121cen <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static std::string spanOf(const BaseClass* o) {
    char b[128];
    snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
             o->VpiEndLineNo(), (unsigned)o->VpiEndColumnNo());
    return b;
}
static std::string slot(const BaseClass* c) {
    if (!c) return "<null>";
    return std::string(UhdmName(c->UhdmType())) + "|" + std::string(c->VpiName());
}

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct121cen <db.uhdm>\n"); return 2; }
    Serializer s;
    auto h = s.Restore(std::string(argv[1]));
    if (h.empty()) { fprintf(stderr, "FATAL: restore failed %s\n", argv[1]); return 3; }
    const design* d = (const design*)((const uhdm_handle*)h[0])->object;

    std::set<const BaseClass*> defRoots, elabRoots;
    if (d->AllPackages())  for (auto* p : *d->AllPackages())  defRoots.insert(p);
    if (d->AllModules())   for (auto* p : *d->AllModules())   defRoots.insert(p);
    if (d->AllClasses())   for (auto* p : *d->AllClasses())   defRoots.insert(p);
    if (d->AllInterfaces())for (auto* p : *d->AllInterfaces())defRoots.insert(p);
    if (d->AllPrograms())  for (auto* p : *d->AllPrograms())  defRoots.insert(p);
    if (d->TopPackages())  for (auto* p : *d->TopPackages())  elabRoots.insert(p);
    if (d->TopModules())   for (auto* p : *d->TopModules())   elabRoots.insert(p);

    for (const auto& [obj, id] : s.AllObjects()) {
        if (obj->UhdmType() != uhdmassignment) continue;
        const assignment* a = (const assignment*)obj;
        std::vector<std::string> home;
        const char* viewTag = "?";
        const BaseClass* view = nullptr;
        const BaseClass* root = nullptr;
        for (const BaseClass* p = obj->VpiParent(); p; p = p->VpiParent()) {
            UHDM_OBJECT_TYPE pt = p->UhdmType();
            if (pt == uhdmclass_defn || pt == uhdmfunction || pt == uhdmtask ||
                pt == uhdmpackage || pt == uhdmmodule_inst ||
                pt == uhdminterface_inst || pt == uhdmprogram)
                home.push_back(std::string(p->VpiName()));
            if (defRoots.count(p))       { view = p; viewTag = "DEF"; }
            else if (elabRoots.count(p)) { view = p; viewTag = "ELAB"; }
            root = p;
        }
        if (!root || root->UhdmType() != uhdmdesign) continue;   // unreachable
        std::string homeS;
        for (size_t i = home.size(); i-- > 0;) { homeS += home[i]; if (i) homeS += "<"; }
        printf("%s\t%s\t%s\t%s\t%s\t%s\n", viewTag,
               view ? std::string(view->VpiName()).c_str() : "<none>",
               homeS.c_str(), spanOf(a).c_str(),
               slot(a->Rhs()).c_str(), slot(a->Lhs()).c_str());
    }
    return 0;
}
