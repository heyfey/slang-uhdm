// r10scr9c: MODULE/PACKAGE param_assign RHS census, one row per assign,
// projected onto the CMP-relevant constant fields (VpiConstType/VpiSize/
// VpiDecompile/VpiValue) or the operand shape for non-constants.  Keyed by the
// owning instance's fullname + the Lhs name, so `diff golden ours` names the
// parameter whose folded RHS disagrees.  Reached through the instance tree
// (Param_assigns of every module_inst / package), NOT through AllObjects --
// the whole-design constant census is arena noise (recorded anti-pattern).
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10scr9c.cpp -o /tmp/r10scr9_c \
//       -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lfmt
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string shape(const any* e) {
    if (!e) return "<null>";
    std::string r(UhdmName(e->UhdmType()));
    if (!e->VpiName().empty()) r += "(" + std::string(e->VpiName()) + ")";
    if (e->UhdmType() == uhdmconstant) {
        auto* c = (const constant*)e;
        r += "{ct=" + std::to_string(c->VpiConstType()) +
             ",sz=" + std::to_string(c->VpiSize()) +
             ",v=" + std::string(c->VpiValue()) +
             ",dc=" + std::string(c->VpiDecompile()) + "}";
    }
    if (e->UhdmType() == uhdmoperation) {
        auto* o = (const operation*)e;
        r += "{op=" + std::to_string(o->VpiOpType()) + ",n=" +
             std::to_string(o->Operands() ? o->Operands()->size() : 0) + "}";
    }
    return r;
}

static void rowsOf(const instance* inst, std::vector<std::string>& rows) {
    if (!inst || !inst->Param_assigns()) return;
    for (auto* pa : *inst->Param_assigns()) {
        std::string ln =
            pa->Lhs() ? std::string(pa->Lhs()->VpiName()) : std::string("?");
        rows.push_back(std::string(inst->VpiFullName()) + " | " + ln + " = " +
                       shape(pa->Rhs()));
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
