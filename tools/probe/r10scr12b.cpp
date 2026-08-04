// r10scr12b: NET / VARIABLE typespec-RANGE census, one row per declaration,
// reached through the instance tree so DEF and ELAB views are separate rows.
// Prints the whole left/right bound tree with the CMP-relevant fields, which
// is what the § elabUnitMisevalNoFold family turns on (a bound that reads a
// $unit parameter Surelog could not value stays an OPERATION where every other
// elab bound folds to a constant).  `diff golden ours` names the declaration.
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10scr12b.cpp -o /tmp/r10scr12_b \
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

static void tree(const any* e, std::string& r, int depth) {
    if (depth > 10) { r += "..."; return; }
    if (!e) { r += "<null>"; return; }
    r += std::string(UhdmName(e->UhdmType()));
    if (!e->VpiName().empty()) r += "(" + std::string(e->VpiName()) + ")";
    r += span(e);
    if (e->UhdmType() == uhdmconstant) {
        auto* c = (const constant*)e;
        r += "{ct=" + std::to_string(c->VpiConstType()) +
             ",sz=" + std::to_string(c->VpiSize()) +
             ",v=" + std::string(c->VpiValue()) + "}";
    }
    else if (e->UhdmType() == uhdmoperation) {
        auto* o = (const operation*)e;
        r += "{op=" + std::to_string(o->VpiOpType()) + "}[";
        if (o->Operands())
            for (size_t i = 0; i < o->Operands()->size(); ++i) {
                if (i) r += ", ";
                tree((*o->Operands())[i], r, depth + 1);
            }
        r += "]";
    }
    else if (e->UhdmType() == uhdmsys_func_call) {
        auto* c = (const sys_func_call*)e;
        r += "(";
        if (c->Tf_call_args())
            for (size_t i = 0; i < c->Tf_call_args()->size(); ++i) {
                if (i) r += ", ";
                tree((*c->Tf_call_args())[i], r, depth + 1);
            }
        r += ")";
    }
}

static std::string rangesOf(const typespec* ts) {
    if (!ts) return "<no-ts>";
    const VectorOfrange* rv = nullptr;
    switch (ts->UhdmType()) {
        case uhdmlogic_typespec: rv = ((const logic_typespec*)ts)->Ranges(); break;
        case uhdmbit_typespec: rv = ((const bit_typespec*)ts)->Ranges(); break;
        case uhdmint_typespec: return "int_typespec" + span(ts);
        case uhdmarray_typespec: rv = ((const array_typespec*)ts)->Ranges(); break;
        case uhdmpacked_array_typespec:
            rv = ((const packed_array_typespec*)ts)->Ranges(); break;
        default: return std::string(UhdmName(ts->UhdmType())) + span(ts);
    }
    std::string r = std::string(UhdmName(ts->UhdmType())) + span(ts);
    if (!rv) return r + "[]";
    for (auto* rg : *rv) {
        r += " [";
        tree(rg->Left_expr(), r, 0);
        r += " : ";
        tree(rg->Right_expr(), r, 0);
        r += "]";
    }
    return r;
}

static const typespec* actual(const ref_typespec* rt) {
    return rt ? rt->Actual_typespec() : nullptr;
}

static void rowsOf(const instance* inst, std::vector<std::string>& rows) {
    if (!inst) return;
    std::string base = std::string(inst->VpiFullName()) + " | ";
    if (auto* nv = inst->Nets())
        for (auto* n : *nv)
            rows.push_back(base + "net " + std::string(n->VpiName()) + " = " +
                           rangesOf(actual(n->Typespec())));
    if (auto* vv = inst->Variables())
        for (auto* v : *vv)
            rows.push_back(base + "var " + std::string(v->VpiName()) + " = " +
                           rangesOf(actual(v->Typespec())));
}

int main(int argc, char** argv) {
    if (argc < 2) return 1;
    Serializer s;
    s.Restore(std::filesystem::path(argv[1]));
    std::vector<std::string> rows;
    for (auto& [o, id] : s.AllObjects()) {
        if (!o) continue;
        if (o->UhdmType() == uhdmmodule_inst ||
            o->UhdmType() == uhdminterface_inst)
            rowsOf((const instance*)o, rows);
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) std::cout << r << "\n";
    return 0;
}
