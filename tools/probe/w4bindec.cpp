// Does a FOLDED param value carry vpiDecompile? Walks every param_assign in a
// golden (modules def+top+hierarchy, packages) and reports each constant Rhs
// as: <hasDecompile> <constType> <size> <name> <file:line>. The concat-fold
// encoding was calibrated on cont_assign rvalues (BIN, no decompile, no loc);
// this separates the param context, where Surelog does emit one.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static void pa(const VectorOfparam_assign* v, const char* tag, const char* db) {
    if (!v)
        return;
    for (auto* p : *v) {
        auto* r = p->Rhs();
        if (!r || r->UhdmType() != uhdmconstant)
            continue;
        auto* c = (const constant*)r;
        std::string nm = p->Lhs() ? std::string(p->Lhs()->VpiName()) : "";
        std::cout << (c->VpiDecompile().empty() ? "NODEC " : "DEC   ") << tag
                  << " ct=" << c->VpiConstType() << " sz=" << c->VpiSize()
                  << " val=" << c->VpiValue().substr(0, 40) << " " << nm << " "
                  << c->VpiFile() << ":" << c->VpiLineNo() << ":"
                  << c->VpiColumnNo() << " db=" << db << "\n";
    }
}

static void mod(const module_inst* m, const char* tag, const char* db, int d) {
    pa(m->Param_assigns(), tag, db);
    if (d > 8)
        return;
    if (auto* v = m->Modules())
        for (auto* c : *v)
            mod(c, tag, db, d + 1);
}

int main(int argc, char** argv) {
    for (int i = 1; i < argc; i++) {
        Serializer s;
        std::vector<vpiHandle> h;
        try {
            h = s.Restore(std::filesystem::path(argv[i]));
        } catch (...) {
            continue;
        }
        if (h.empty())
            continue;
        auto* d = (design*)((uhdm_handle*)h[0])->object;
        if (!d)
            continue;
        if (auto* v = d->AllModules())
            for (auto* m : *v)
                mod(m, "DEF", argv[i], 0);
        if (auto* v = d->TopModules())
            for (auto* m : *v)
                mod(m, "TOP", argv[i], 0);
        if (auto* v = d->AllPackages())
            for (auto* p : *v)
                pa(p->Param_assigns(), "PKGDEF", argv[i]);
        if (auto* v = d->TopPackages())
            for (auto* p : *v)
                pa(p->Param_assigns(), "PKGTOP", argv[i]);
        std::cout.flush();
    }
    return 0;
}
