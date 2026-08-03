// r10scr10b: PARAMETER-object census (one row per parameter of every
// module_inst / interface_inst / package), projected onto the fields
// int_typespec/parameter Compare actually reads: the parameter's own value +
// the ACTUAL typespec kind behind its ref_typespec (and, for an int_typespec,
// whether it carries a Cast_to_expr / Ranges).  Complements r10scr9c, which
// censuses the param_assign RHS only.
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10scr10b.cpp -o /tmp/r10scr10_b \
//       -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lfmt
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string tsOf(const ref_typespec* rt) {
    if (!rt) return "<no-ref_typespec>";
    auto* a = rt->Actual_typespec();
    if (!a) return "ref_typespec(actual=<null>)";
    std::string r = "ref_typespec->";
    r += UhdmName(a->UhdmType());
    if (a->UhdmType() == uhdmint_typespec) {
        auto* it = (const int_typespec*)a;
        r += "{v=" + std::string(it->VpiValue()) +
             ",sg=" + std::to_string(it->VpiSigned()) +
             ",cast=" + (it->Cast_to_expr() ? "y" : "n") +
             ",rng=" +
             std::to_string(it->Ranges() ? it->Ranges()->size() : 0) + "}";
    }
    if (!a->VpiName().empty()) r += "(" + std::string(a->VpiName()) + ")";
    return r;
}

static void rowsOf(const instance* inst, std::vector<std::string>& rows) {
    if (!inst || !inst->Parameters()) return;
    for (auto* p : *inst->Parameters()) {
        if (p->UhdmType() != uhdmparameter) continue;
        auto* pm = (const parameter*)p;
        rows.push_back(std::string(inst->VpiFullName()) + " | " +
                       std::string(pm->VpiName()) +
                       " v=" + std::string(pm->VpiValue()) +
                       " sz=" + std::to_string(pm->VpiSize()) + " ts=" +
                       tsOf(pm->Typespec()));
    }
}

int main(int argc, char** argv) {
    if (argc < 2) return 1;
    Serializer s;
    s.Restore(std::filesystem::path(argv[1]));
    std::vector<std::string> rows;
    for (auto& [o, id] : s.AllObjects()) {
        if (!o) continue;
        if (o->UhdmType() == uhdmmodule_inst || o->UhdmType() == uhdmpackage ||
            o->UhdmType() == uhdminterface_inst)
            rowsOf((const instance*)o, rows);
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) std::cout << r << "\n";
    return 0;
}
