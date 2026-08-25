// r10uvm146 — CENSUS of the design-level imported-parameter family.
// MEASUREMENT ONLY.  The official ~/git-repos/UHDM/build/bin/uhdm-cmp is the
// sole acceptance judge.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// For ONE database it prints, per `ref_obj` whose VpiName is one of the
// DESIGN-LEVEL imported parameter names of THAT database (golden) or of a
// name list given with --names=<file> (ours, which has no listing yet):
//
//   REF|<name>|<line>:<col>|<actual-kind>|<reaches-design 0/1>|<owner-tf>
//
// plus the design listing itself (LIST| rows).  Two runs joined by
// name+line:col are the depth-keyed identity census this pass is scored on;
// the `reaches-design` column is the LAW's own gate, measured on the object
// graph the emitter actually produced, so the mover set can be PREDICTED BY
// NAME from pristine databases before any patched sweep runs.
//
// build: g++ -O2 -std=c++17 ct146cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct146cen
// usage: ct146cen <db.uhdm> [--names=<file>]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <set>
#include <string>
#include <fstream>

using namespace UHDM;

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct146cen db.uhdm [--names=f]\n"); return 2; }
    std::set<std::string> names;
    for (int a = 2; a < argc; a++)
        if (!strncmp(argv[a], "--names=", 8)) {
            std::ifstream f(argv[a] + 8);
            std::string l;
            while (std::getline(f, l)) if (!l.empty()) names.insert(l);
        }
    Serializer s;
    const std::vector<vpiHandle> h = s.Restore(std::string(argv[1]));
    if (h.empty()) { fprintf(stderr, "restore failed\n"); return 3; }
    const design* d = (const design*)((const uhdm_handle*)h[0])->object;

    if (d->Parameters())
        for (auto* p : *d->Parameters()) {
            printf("LIST|PARAM|%s|%s|%s\n", std::string(p->VpiName()).c_str(),
                   std::string(UhdmName(p->UhdmType())).c_str(),
                   p->UhdmType() == uhdmparameter
                       ? std::string(((const parameter*)p)->VpiImported()).c_str() : "");
            names.insert(std::string(p->VpiName()));
        }
    if (d->Param_assigns())
        for (auto* pa : *d->Param_assigns())
            printf("LIST|PASSIGN|%s|%s|%u:%u\n",
                   pa->Lhs() ? std::string(pa->Lhs()->VpiName()).c_str() : "<null>",
                   pa->Rhs() ? std::string(UhdmName(pa->Rhs()->UhdmType())).c_str() : "<null>",
                   pa->VpiLineNo(), (unsigned)pa->VpiColumnNo());

    for (const auto& [obj, id] : s.AllObjects()) {
        if (!obj || obj->UhdmType() != uhdmref_obj) continue;
        const std::string nm(obj->VpiName());
        if (!names.count(nm)) continue;
        const ref_obj* r = (const ref_obj*)obj;
        const any* act = r->Actual_group();
        // Does the emitted parent chain reach the design?  That is the LAW's
        // gate: Surelog's lateBinding walks `ref->VpiParent()` upward and only
        // a chain that REACHES the design consults design->Parameters().
        int reaches = 0;
        std::string tf = "-";
        std::string chain;
        const BaseClass* p = obj->VpiParent();
        for (int g = 0; p && g < 200; g++, p = p->VpiParent()) {
            if (tf == "-" && (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask))
                tf = std::string(p->VpiName());
            if (g < 6) { if (g) chain += ">"; chain += std::string(UhdmName(p->UhdmType())); }
            if (p->UhdmType() == uhdmdesign) { reaches = 1; break; }
        }
        printf("REF|%s|%u:%u|%s|%d|%s|%s\n", nm.c_str(), obj->VpiLineNo(),
               (unsigned)obj->VpiColumnNo(),
               act ? std::string(UhdmName(act->UhdmType())).c_str() : "<null>",
               reaches, tf.c_str(), chain.c_str());
    }
    return 0;
}
