// r10uvm121 — A-PRIORI MOVER PREDICTOR (measurement only).
//
// Evaluates, on a PRISTINE database, the UHDM signature of every object
// § thisSuperNewAssignEmpty121 will EMPTY, and names the cell.
//
//   EXACT  an `assignment` whose Rhs is a `method_func_call` named "new" and
//          whose Lhs is a `hier_path` whose VpiName starts "this." / "super."
//          — the shape the PRISTINE emitter gives every measured cell of the
//          law (arm a02-a05/a08-a11/a16, arm b02/b07, and all 26 corpus cells).
//   WIDE   an `assignment` whose Rhs is a `method_func_call` named "new" and
//          whose Lhs is NOT a hier_path — the UPPER BOUND on the one shape the
//          UHDM side cannot name: arm a15 (`super.gutter = new;`) comes out of
//          the pristine emitter with a bare `ref_obj` Lhs indistinguishable
//          from an ordinary `x = new()`.  WIDE is therefore a SUPERSET, not a
//          prediction; it is printed so a mover outside EXACT can be checked
//          against it instead of being explained after the fact.
//
// Reachability: the vpiParent chain must terminate at the design object.
//
// build: g++ -O2 -std=c++17 pred121.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o pred121
// usage: pred121 <db.uhdm>        prints "EXACT=<n> WIDE=<n>" then one CELL
//                                 line per EXACT hit
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: pred121 <db.uhdm>\n"); return 2; }
    Serializer s;
    auto h = s.Restore(std::string(argv[1]));
    if (h.empty()) { printf("RESTORE-FAIL\n"); return 3; }
    const design* d = (const design*)((const uhdm_handle*)h[0])->object;
    std::set<const BaseClass*> roots;
    if (d->AllPackages())  for (auto* p : *d->AllPackages())  roots.insert(p);
    if (d->AllModules())   for (auto* p : *d->AllModules())   roots.insert(p);
    if (d->AllClasses())   for (auto* p : *d->AllClasses())   roots.insert(p);
    if (d->AllInterfaces())for (auto* p : *d->AllInterfaces())roots.insert(p);
    if (d->AllPrograms())  for (auto* p : *d->AllPrograms())  roots.insert(p);
    if (d->TopPackages())  for (auto* p : *d->TopPackages())  roots.insert(p);
    if (d->TopModules())   for (auto* p : *d->TopModules())   roots.insert(p);

    long exact = 0, wide = 0;
    std::vector<std::string> cells;
    for (const auto& [obj, id] : s.AllObjects()) {
        if (obj->UhdmType() != uhdmassignment) continue;
        const assignment* a = (const assignment*)obj;
        const any* r = a->Rhs();
        if (!r || r->UhdmType() != uhdmmethod_func_call) continue;
        if (r->VpiName() != "new") continue;
        const BaseClass* root = nullptr;
        std::vector<std::string> home;
        for (const BaseClass* p = obj->VpiParent(); p; p = p->VpiParent()) {
            UHDM_OBJECT_TYPE pt = p->UhdmType();
            if (pt == uhdmclass_defn || pt == uhdmfunction || pt == uhdmtask ||
                pt == uhdmpackage || pt == uhdmmodule_inst ||
                pt == uhdminterface_inst || pt == uhdmprogram)
                home.push_back(std::string(p->VpiName()));
            root = p;
        }
        if (!root || root->UhdmType() != uhdmdesign) continue;
        const any* l = a->Lhs();
        if (l && l->UhdmType() == uhdmhier_path) {
            const std::string n(l->VpiName());
            if (n.rfind("this.", 0) == 0 || n.rfind("super.", 0) == 0) {
                exact++;
                std::string homeS;
                for (size_t i = home.size(); i-- > 0;) { homeS += home[i]; if (i) homeS += "<"; }
                char b[512];
                snprintf(b, sizeof b, "CELL\t%s\t%u:%u-%u:%u\t%s", homeS.c_str(),
                         a->VpiLineNo(), (unsigned)a->VpiColumnNo(),
                         a->VpiEndLineNo(), (unsigned)a->VpiEndColumnNo(),
                         std::string(l->VpiName()).c_str());
                cells.push_back(b);
                continue;
            }
        }
        if (!l || l->UhdmType() != uhdmhier_path) wide++;
    }
    printf("EXACT=%ld WIDE=%ld\n", exact, wide);
    for (const auto& c : cells) printf("%s\n", c.c_str());
    return 0;
}
