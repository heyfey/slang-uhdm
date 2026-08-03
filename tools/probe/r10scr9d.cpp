// r10scr9d: for a named parameter, print every copy's owning instance, its
// typespec kind and the SHAPE of each range bound (folded constant vs kept
// op tree).  The elab param_assign Rhs is re-rendered at the parameter's
// RANGE WIDTH, so the bound shape is what decides that width.
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10scr9d.cpp -o /tmp/r10scr9_d \
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
             ",sz=" + std::to_string(c->VpiSize()) + ",v=" +
             std::string(c->VpiValue()) + "}";
    }
    if (e->UhdmType() == uhdmoperation)
        r += "{op=" + std::to_string(((const operation*)e)->VpiOpType()) + "}";
    return r;
}

int main(int argc, char** argv) {
    if (argc < 3) return 1;
    std::string want = argv[2];
    Serializer s;
    s.Restore(std::filesystem::path(argv[1]));
    std::vector<std::string> rows;
    for (auto& [o, id] : s.AllObjects()) {
        if (!o || o->UhdmType() != uhdmparameter) continue;
        auto* p = (const parameter*)o;
        if (p->VpiName() != want) continue;
        std::string r = std::string(p->VpiFullName()) + " ts=";
        const typespec* ts =
            p->Typespec() ? p->Typespec()->Actual_typespec() : nullptr;
        r += ts ? UhdmName(ts->UhdmType()) : "<null>";
        if (ts && ts->UhdmType() == uhdmint_typespec) {
            auto* it = (const int_typespec*)ts;
            r += " sz-ranges=";
            if (auto* rg = it->Ranges())
                for (auto* q : *rg)
                    r += "[" + shape(q->Left_expr()) + ":" +
                         shape(q->Right_expr()) + "]";
            else
                r += "<none>";
        }
        if (ts && ts->UhdmType() == uhdmlogic_typespec) {
            auto* lt = (const logic_typespec*)ts;
            r += " ranges=";
            if (auto* rg = lt->Ranges())
                for (auto* q : *rg)
                    r += "[" + shape(q->Left_expr()) + ":" +
                         shape(q->Right_expr()) + "]";
            else
                r += "<none>";
        }
        rows.push_back(r);
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) std::cout << r << "\n";
    return 0;
}
