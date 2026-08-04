// r10scr12c: PARAMETER-object census (one row per parameter of every
// module_inst / interface_inst / package), projected onto the fields
// typespec::Compare actually reads: the parameter's own VpiValue/VpiSize plus
// its typespec's type, VpiName, VpiValue and Vpi EXPR shape.  int_typespec
// compares its Cast_to_expr / VpiExpr, which is where the "valueless typed
// parameter keeps a symbolic ts" family lives.
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10scr12c.cpp -o /tmp/r10scr12_c \
//       -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lfmt
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string span(const BaseClass* o) {
    if (!o) return "";
    return "@" + std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo()) + "-" +
           std::to_string(o->VpiEndLineNo()) + ":" +
           std::to_string(o->VpiEndColumnNo());
}

static std::string brief(const any* e) {
    if (!e) return "<null>";
    std::string r(UhdmName(e->UhdmType()));
    if (!e->VpiName().empty()) r += "(" + std::string(e->VpiName()) + ")";
    if (e->UhdmType() == uhdmconstant)
        r += "{" + std::string(((const constant*)e)->VpiValue()) + "}";
    return r + span(e);
}

static std::string tsOf(const ref_typespec* rt) {
    if (!rt) return "<no-ref_ts>";
    const typespec* t = rt->Actual_typespec();
    if (!t) return "<no-ts>";
    std::string r(UhdmName(t->UhdmType()));
    if (!t->VpiName().empty()) r += "(" + std::string(t->VpiName()) + ")";
    r += span(t);
    if (t->UhdmType() == uhdmint_typespec) {
        auto* it = (const int_typespec*)t;
        if (!it->VpiValue().empty())
            r += "{v=" + std::string(it->VpiValue()) + "}";
        if (it->Cast_to_expr()) r += " cast->" + brief(it->Cast_to_expr());
    }
    return r;
}

static void rowsOf(const instance* inst, std::vector<std::string>& rows) {
    if (!inst || !inst->Parameters()) return;
    std::string base = std::string(inst->VpiFullName()) + " | ";
    for (auto* p : *inst->Parameters()) {
        if (!p) continue;
        std::string r = base + std::string(p->VpiName()) + " :";
        if (p->UhdmType() == uhdmparameter) {
            auto* pp = (const parameter*)p;
            r += " v=" + std::string(pp->VpiValue()) +
                 " sz=" + std::to_string(pp->VpiSize()) +
                 " ts=" + tsOf(pp->Typespec());
        }
        else {
            r += " " + std::string(UhdmName(p->UhdmType()));
        }
        rows.push_back(r);
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
