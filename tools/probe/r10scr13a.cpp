// r10scr13a: PORT High_conn census, one row per port of every module_inst /
// interface_inst reached through the instance tree, projected onto the
// CMP-relevant fields (VpiType / VpiName / constant encoding) plus spans.
// This is the census for the § connActualParamFold family: an instance
// CONNECTION whose actual reads a parameter is answered in golden by that
// parameter's own constant at the USE SITE span, where we keep a ref_obj.
// `diff golden ours` names the instance, the port and the sub-node.
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10scr13a.cpp -o /tmp/r10scr13_pa \
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
            r += "{act=";
            if (auto* a = ro->Actual_group())
                r += std::string(UhdmName(a->UhdmType())) + span(a);
            else
                r += "<none>";
            r += "}";
            break;
        }
        case uhdmoperation: {
            auto* o = (const operation*)e;
            r += "{op=" + std::to_string(o->VpiOpType()) + "}[";
            if (o->Operands())
                for (size_t i = 0; i < o->Operands()->size(); ++i) {
                    if (i) r += ", ";
                    tree((*o->Operands())[i], r, depth + 1);
                }
            r += "]";
            break;
        }
        case uhdmpart_select:
        case uhdmindexed_part_select:
        case uhdmbit_select:
        case uhdmhier_path:
            break;
        default:
            break;
    }
}

static void portRows(const VectorOfport* pv, const std::string& base,
                     std::vector<std::string>& rows) {
    if (!pv) return;
    for (auto* p : *pv) {
        std::string r = base + "port " + std::string(p->VpiName()) + " hi=";
        tree(p->High_conn(), r, 0);
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
        if (o->UhdmType() == uhdmmodule_inst)
            portRows(((const module_inst*)o)->Ports(),
                     std::string(((const module_inst*)o)->VpiFullName()) +
                         " | ",
                     rows);
        else if (o->UhdmType() == uhdminterface_inst)
            portRows(((const interface_inst*)o)->Ports(),
                     std::string(((const interface_inst*)o)->VpiFullName()) +
                         " | ",
                     rows);
        else if (o->UhdmType() == uhdmref_module)
            // DEF-view instance: Surelog keeps the child as a ref_module whose
            // ports carry their own high_conns (§ connExprBindsNet reads
            // DIFFERENTLY here than in the elaborated view).
            portRows(((const ref_module*)o)->Ports(),
                     "REFMOD " + std::string(o->VpiName()) + "@" +
                         std::to_string(o->VpiLineNo()) + " | ",
                     rows);
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) std::cout << r << "\n";
    return 0;
}
