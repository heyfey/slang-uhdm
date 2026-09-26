// cen171.cpp <db.uhdm> : the trigger census of the r11u171 laws (and the landed r11u172 TypeEmit laws) on ONE
// database, one line per candidate object:
//   AGG   <kind> <file> <line> <col> <endline> <endcol>      struct/union/enum typespec (FILE172: relocated span)
//   UNF   <file-empty>                                         union_typespec with no file (CASTUNIONFILE171)
//   MEM   <file> <line>                                        typespec_member (MEMBERROOTFILE171: filed outside the roots)
//   VAL   <decompile> <value>                                  constant whose written digits differ from its UINT value (VALUE172)
//   SGN   <name> <line> <col> <endline> <endcol>               $signed/$unsigned wider than its name (SPAN172)
//   CAD   <lhs kind> <decompile>                               cont_assign: select Lhs, bare-decimal constant Rhs (SELDECSHARE171)
//   SWL   <line> <col>                                         port HighConn: concat whose first operand is a concat (UDPSWALLOW171)
//   NET   <file> <line> <col> <endline> <endcol>               the typespec of a logic_net (NETENDCOL171 candidates)
//   GTE   <fullname>                                           a gate terminal reference under a gen_scope (GENELSEIF171)
//   SPT   <n ports> <line> <names>                             one typespec object shared by ports of different names (SPLITPORTKEY171)
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <iostream>
#include <map>
#include <set>
#include <string>
using namespace UHDM;
int main(int argc, char** argv) {
    Serializer s;
    auto designs = s.Restore(std::string(argv[1]));
    (void)designs;
    std::map<const typespec*, std::set<std::string>> portTs;
    for (auto& [obj, id] : s.AllObjects()) {
        if (!obj) continue;
        auto t = obj->UhdmType();
        if (t == uhdmstruct_typespec || t == uhdmunion_typespec || t == uhdmenum_typespec) {
            std::cout << "AGG " << UhdmName(t) << " " << (obj->VpiFile().empty() ? "-" : std::string(obj->VpiFile())) << " "
                      << obj->VpiLineNo() << " " << obj->VpiColumnNo() << " " << obj->VpiEndLineNo() << " " << obj->VpiEndColumnNo() << "\n";
            if (t == uhdmunion_typespec && obj->VpiFile().empty() && obj->VpiLineNo() != 0) std::cout << "UNF -\n";
        } else if (t == uhdmtypespec_member) {
            std::cout << "MEM " << (obj->VpiFile().empty() ? "-" : std::string(obj->VpiFile())) << " " << obj->VpiLineNo() << "\n";
        } else if (t == uhdmconstant) {
            auto* c = (const constant*)obj;
            std::string d(c->VpiDecompile()), v(c->VpiValue());
            if (v.rfind("UINT:", 0) == 0 && !d.empty() && d.find_first_not_of("0123456789_") == std::string::npos) {
                std::string dd; for (char ch : d) if (ch != '_') dd.push_back(ch);
                if (dd != v.substr(5)) std::cout << "VAL " << d << " " << v << "\n";
            }
        } else if (t == uhdmsys_func_call) {
            std::string n(obj->VpiName());
            if ((n == "$signed" || n == "$unsigned") &&
                !(obj->VpiLineNo() == obj->VpiEndLineNo() && obj->VpiEndColumnNo() - obj->VpiColumnNo() == (int)n.size()))
                std::cout << "SGN " << n << " " << obj->VpiLineNo() << " " << obj->VpiColumnNo() << " " << obj->VpiEndLineNo() << " " << obj->VpiEndColumnNo() << "\n";
        } else if (t == uhdmcont_assign) {
            auto* ca = (const cont_assign*)obj;
            auto* l = ca->Lhs(); auto* r = ca->Rhs();
            if (l && r && r->UhdmType() == uhdmconstant &&
                (l->UhdmType() == uhdmpart_select || l->UhdmType() == uhdmbit_select || l->UhdmType() == uhdmindexed_part_select)) {
                std::string d(((const constant*)r)->VpiDecompile());
                if (d.find('\'') == std::string::npos) std::cout << "CAD " << UhdmName(l->UhdmType()) << " " << d << "\n";
            }
        } else if (t == uhdmport) {
            auto* p = (const port*)obj;
            if (auto* h = p->High_conn(); h && h->UhdmType() == uhdmoperation) {
                auto* op = (const operation*)h;
                if (op->VpiOpType() == vpiConcatOp && op->Operands() && !op->Operands()->empty()) {
                    auto* f = op->Operands()->at(0);
                    if (f && f->UhdmType() == uhdmoperation && ((const operation*)f)->VpiOpType() == vpiConcatOp)
                        std::cout << "SWL " << h->VpiLineNo() << " " << h->VpiColumnNo() << "\n";
                }
            }
            if (auto* rt = p->Typespec(); rt && rt->Actual_typespec())
                portTs[rt->Actual_typespec()].insert(std::string(p->VpiName()));
        } else if (t == uhdmprim_term) {
            // a gate terminal reference whose gate sits in a generate scope
            auto* g = obj->VpiParent();
            auto* pt = (const prim_term*)obj;
            if (g && g->VpiParent() && g->VpiParent()->UhdmType() == uhdmgen_scope)
                if (auto* e = pt->Expr(); e && e->UhdmType() == uhdmref_obj)
                    std::cout << "GTE " << ((const ref_obj*)e)->VpiFullName() << "\n";
        } else if (t == uhdmlogic_net) {
            if (auto* rt = ((const logic_net*)obj)->Typespec(); rt && rt->Actual_typespec()) {
                auto* a = rt->Actual_typespec();
                std::cout << "NET " << (a->VpiFile().empty() ? "-" : std::string(a->VpiFile())) << " " << a->VpiLineNo() << " "
                          << a->VpiColumnNo() << " " << a->VpiEndLineNo() << " " << a->VpiEndColumnNo() << "\n";
            }
        }
    }
    for (auto& [ts, names] : portTs)
        if (names.size() > 1) {
            std::cout << "SPT " << names.size() << " " << ts->VpiLineNo();
            for (auto& n : names) std::cout << " " << n;
            std::cout << "\n";
        }
}
