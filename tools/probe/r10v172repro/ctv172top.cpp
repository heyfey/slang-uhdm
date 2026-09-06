// r10v172 — DESIGN-LEVEL VECTOR SIZES.  MEASUREMENT ONLY; the official
// uhdm-cmp is the sole judge.  Prints the size of every vector
// `design::Compare` reads, in the order it reads them, so a head that lands on
// the `design` object can be attributed to the one vector whose SIZE differs
// (the SafeCompare VECTOR overload sets BOTH containers on a size mismatch and
// names the OWNER — RESUME.md §9).
// build: g++ -O2 -std=c++17 ctv172top.cpp -I ~/.local/include -L ~/.local/lib64 \
//            -L ~/.local/lib -luhdm -lcapnp -lkj -o ctv172top
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <string>

using namespace UHDM;

template <typename V>
static void row(const char* n, const V* v) {
    printf("  %-22s %s\n", n, v ? std::to_string(v->size()).c_str() : "<null>");
}

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ctv172top <db.uhdm>\n"); return 2; }
    Serializer s;
    const auto& restored = s.Restore(std::string(argv[1]));
    if (restored.empty()) { printf("RESTORE_FAIL\n"); return 3; }
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdmdesign) continue;
        const design* d = any_cast<const design*>(o);
        printf("DESIGN %s elaborated=%d\n", std::string(d->VpiName()).c_str(),
               (int)d->VpiElaborated());
        row("Include_file_infos", d->Include_file_infos());
        row("AllPackages", d->AllPackages());
        row("TopPackages", d->TopPackages());
        row("AllClasses", d->AllClasses());
        row("AllInterfaces", d->AllInterfaces());
        row("AllUdps", d->AllUdps());
        row("AllPrograms", d->AllPrograms());
        row("AllModules", d->AllModules());
        row("Typespecs", d->Typespecs());
        row("Let_decls", d->Let_decls());
        row("Task_funcs", d->Task_funcs());
        row("Parameters", d->Parameters());
        row("Param_assigns", d->Param_assigns());
        row("TopModules", d->TopModules());
        if (d->Task_funcs())
            for (auto* t : *d->Task_funcs())
                printf("    TF %s %s\n",
                       std::string(UhdmName(t->UhdmType())).c_str(),
                       std::string(t->VpiName()).c_str());
        if (d->AllPackages())
            for (auto* p : *d->AllPackages())
                printf("    PKG %s tf=%s\n", std::string(p->VpiName()).c_str(),
                       p->Task_funcs() ? std::to_string(p->Task_funcs()->size()).c_str()
                                       : "<null>");
    }
    return 0;
}
