// r11u48 / tscen48 — THE EXPRESSION-OBJECT TYPESPEC CENSUS.
//
// Walks Serializer::AllObjects() of each database given on the command line
// and, for every object that IS-A `expr` (the only class whose `Compare`
// reads `Typespec()` — ~/git-repos/UHDM/build/generated/src/expr.cpp:100),
// prints ONE keyed line:
//
//   TS <exprKind> <parentKind> ts=<typespecKind|NONE> [act=<actualKind>]
//
// plus a per-database roll-up.  The key deliberately omits names, files,
// lines and spans (Compare never reads them) so two runs of the SAME
// producer over the SAME source join exactly, and a golden-vs-golden
// calibration reads 0 differences.
//
// SHAPE LISTER: `--shape` additionally prints, for every TYPED expr, the
// decompile and the owner chain, so a census cell can be opened without
// re-running uhdm-dump.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>
#include <vector>
using namespace UHDM;

static bool g_shape = false;

static std::string kindName(const any* a) {
    if (!a) return "<null>";
    return std::string(UhdmName(a->UhdmType()));
}

int main(int argc, char** argv) {
    std::vector<std::string> files;
    for (int i = 1; i < argc; i++) {
        std::string a(argv[i]);
        if (a == "--shape") g_shape = true;
        else files.push_back(a);
    }
    for (const auto& f : files) {
        Serializer s;
        std::vector<vpiHandle> h;
        try {
            h = s.Restore(std::filesystem::path(f));
        } catch (...) { std::cout << "## RESTORE-THREW\n"; continue; }
        if (h.empty()) { std::cout << "## " << f << " RESTORE-FAILED\n"; continue; }
        std::cout << "## " << f << "\n";
        std::map<std::string, int> cells;
        for (const auto& kv : s.AllObjects()) {
            const BaseClass* b = kv.first;
            if (!b) continue;
            const any* a = (const any*)b;
            const expr* e = any_cast<const expr*>(a);
            if (!e) continue;
            const ref_typespec* rt = e->Typespec();
            std::string key = kindName(a) + " under=" + kindName(a->VpiParent());
            if (!rt) key += " ts=NONE";
            else {
                const typespec* act = rt->Actual_typespec();
                key += std::string(" ts=ref_typespec act=") + (act ? kindName(act) : "<null>");
            }
            cells[key]++;
            if (g_shape && rt) {
                std::cout << "SH " << kindName(a)
                          << " dec='" << e->VpiDecompile() << "'"
                          << " size=" << e->VpiSize()
                          << " rtname='" << rt->VpiName() << "'"
                          << " act=" << (rt->Actual_typespec() ? kindName(rt->Actual_typespec()) : std::string("<null>"))
                          << " under=" << kindName(a->VpiParent())
                          << " @" << a->VpiLineNo() << ":" << a->VpiColumnNo()
                          << "\n";
            }
        }
        for (const auto& c : cells)
            std::cout << "TS " << c.second << "\t" << c.first << "\n";
    }
    return 0;
}
