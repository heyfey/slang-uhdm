// r10uvm215 — THE MODPORT CENSUS.  MEASUREMENT ONLY; the official
// `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge; this tool links the
// SAME generated `Compare` only to read the SAME accessors, and it reports.
// LHS is ALWAYS golden (Surelog), RHS is ALWAYS ours.
//
// The head of this pass is `interface_inst::Modports()` NULL on golden and a
// one-element vector on ours (BaseClass.h's VECTOR SafeCompare, `:220-222`), so
// the scorer has to distinguish THREE states per interface, not two:
//   MPNULL   the vector POINTER is null       (what golden has, and what the
//                                              judge's `LHS: <null>` means)
//   MPEMPTY  a non-null vector of size 0      (never seen from either producer,
//                                              but it would compare EQUAL to
//                                              MPNULL and must not be confused
//                                              with it)
//   MP       one line per modport, with its io_decl names and directions
//
// The KEY is the interface's identity (defname + own name + the parent's KIND),
// never a slot index: a census keyed on position is blind to an interface that
// moved (RESUME §9, earl56's 107-cell regression).  The parent KIND is the view
// (`design` = the def listing, `module_inst` = an elaborated instance,
// `interface_inst` = an interface inside an interface) and both producers label
// those three the same way, which the golden-vs-golden calibration proves.
//
// build: g++ -O2 -std=c++17 ct215mpcen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct215mpcen
// usage: ct215mpcen <db.uhdm>            (flat sorted key lines on stdout)
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <string>
#include <vector>

using namespace UHDM;

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct215mpcen <db>\n"); return 2; }
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
    std::vector<std::string> lines;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdminterface_inst) continue;
        const interface_inst* ii = (const interface_inst*)o;
        const BaseClass* p = ii->VpiParent();
        // The view is the PARENT KIND, not the parent's name: an elaborated
        // instance's parent name differs by test, the kind does not.
        std::string view = p ? std::string(UhdmName(p->UhdmType())) : "<none>";
        char key[600];
        snprintf(key, sizeof key, "%s|%s|%s", std::string(ii->VpiDefName()).c_str(),
                 std::string(ii->VpiName()).c_str(), view.c_str());
        if (!ii->Modports()) {
            lines.push_back(std::string("MPNULL|") + key);
        } else if (ii->Modports()->empty()) {
            lines.push_back(std::string("MPEMPTY|") + key);
        } else {
            for (auto* mp : *ii->Modports()) {
                std::string ios;
                if (!mp->Io_decls()) {
                    ios = "<null>";
                } else {
                    for (auto* io : *mp->Io_decls()) {
                        char d[128];
                        snprintf(d, sizeof d, " %s:dir%d%s",
                                 std::string(io->VpiName()).c_str(),
                                 io->VpiDirection(),
                                 io->Expr() ? ("{" + std::string(UhdmName(
                                                        io->Expr()->UhdmType())) +
                                               "}")
                                                  .c_str()
                                            : "");
                        ios += d;
                    }
                }
                char l[900];
                snprintf(l, sizeof l, "MP|%s|%s|%s", key,
                         std::string(mp->VpiName()).c_str(), ios.c_str());
                lines.push_back(l);
            }
        }
    }
    std::sort(lines.begin(), lines.end());
    for (auto& l : lines) printf("%s\n", l.c_str());
    return 0;
}
