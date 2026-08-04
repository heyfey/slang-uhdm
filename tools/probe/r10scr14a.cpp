// r10scr14a: DEEP param_assign RHS tree census (r10scr12a + operation
// TYPESPEC: the cast typespec a spliced override tree carries is invisible
// without it, and it IS compared), one row per assign, reached
// through the instance tree (module_inst / interface_inst / package), keyed by
// the owning instance's fullname + the Lhs name.  Unlike r10scr9c (top-level
// shape only) this prints the WHOLE Rhs tree flattened, projected onto the
// CMP-relevant fields plus the ref/typespec span that the miseval SPLICE rules
// (§ elabVarRangeMisevalSubst / § elabMisevalArgNoFold) turn on.  `diff golden
// ours` names the parameter AND the sub-node that disagrees.
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10scr14a.cpp -o /tmp/r10scr14_a \
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
    if (depth > 12) { r += "..."; return; }
    if (!e) { r += "<null>"; return; }
    r += std::string(UhdmName(e->UhdmType()));
    if (!e->VpiName().empty()) r += "(" + std::string(e->VpiName()) + ")";
    r += span(e);
    switch (e->UhdmType()) {
        case uhdmconstant: {
            auto* c = (const constant*)e;
            r += "{ct=" + std::to_string(c->VpiConstType()) +
                 ",sz=" + std::to_string(c->VpiSize()) +
                 ",v=" + std::string(c->VpiValue()) +
                 ",dc=" + std::string(c->VpiDecompile()) + "}";
            break;
        }
        case uhdmref_obj: {
            auto* ro = (const ref_obj*)e;
            if (auto* rt = ro->Typespec()) {
                r += "{ts=";
                if (auto* at = rt->Actual_typespec())
                    r += std::string(UhdmName(at->UhdmType())) + span(at);
                else
                    r += "<none>";
                r += "}";
            } else {
                r += "{ts=<null>}";
            }
            break;
        }
        case uhdmoperation: {
            auto* o = (const operation*)e;
            r += "{op=" + std::to_string(o->VpiOpType());
            if (auto* rt = o->Typespec()) {
                r += ",ts=";
                if (auto* at = rt->Actual_typespec())
                    r += std::string(UhdmName(at->UhdmType())) + span(at);
                else
                    r += "<none>";
            }
            r += "}[";
            if (o->Operands())
                for (size_t i = 0; i < o->Operands()->size(); ++i) {
                    if (i) r += ", ";
                    tree((*o->Operands())[i], r, depth + 1);
                }
            r += "]";
            break;
        }
        case uhdmsys_func_call: {
            auto* c = (const sys_func_call*)e;
            r += "(";
            if (c->Tf_call_args())
                for (size_t i = 0; i < c->Tf_call_args()->size(); ++i) {
                    if (i) r += ", ";
                    tree((*c->Tf_call_args())[i], r, depth + 1);
                }
            r += ")";
            break;
        }
        default:
            break;
    }
}

static void rowsOf(const instance* inst, std::vector<std::string>& rows) {
    if (!inst || !inst->Param_assigns()) return;
    for (auto* pa : *inst->Param_assigns()) {
        std::string ln =
            pa->Lhs() ? std::string(pa->Lhs()->VpiName()) : std::string("?");
        std::string t;
        tree(pa->Rhs(), t, 0);
        rows.push_back(std::string(inst->VpiFullName()) + " | " + ln + " = " + t);
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
