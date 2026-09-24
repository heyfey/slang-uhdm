// r11u120 census: per database, how many cells each r11u120 law can move,
// read from a PRISTINE database (the law's trigger as the database shows it).
//   L1 memberSelRhs   cont_assign Rhs = constant with EMPTY VpiValue and no
//                     parent (the bare loc-only mint)
//   L2 ifaceAggParent param_assign whose Lhs parameter is parented at an
//                     interface_inst (not at the param_assign) and whose Rhs is
//                     an assignment-pattern operation (op 75)
//   L3 tpShare        elaborated module_inst listing a type_parameter that is
//                     not its definition's object (an instance copy)
//   L4 tpDefPort      definition port whose typespec is a packed_array_typespec
//                     parented at a type_parameter that no longer points at it
//   L5 tpDimVec       port whose typespec is a located, parent-less, range-less,
//                     alias-less logic_typespec spanning more than one keyword
//                     (the fresh written-type mint `data_t [N-1:0]`)
// prints: <file> L1=<n> L2=<n> L3=<n> L4=<n> L5=<n>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
#include <string>
using namespace UHDM;
int main(int argc, char** argv) {
    for (int ai = 1; ai < argc; ai++) {
        Serializer s;
        auto h = s.Restore(std::filesystem::path(argv[ai]));
        int L1 = 0, L2 = 0, L3 = 0, L4 = 0, L5 = 0;
        const design* d = nullptr;
        for (auto hh : h) d = (const design*)((uhdm_handle*)hh)->object;
        std::map<std::string, const module_inst*> defs;
        if (d && d->AllModules())
            for (auto* m : *d->AllModules())
                if (m->UhdmType() == uhdmmodule_inst) defs[std::string(m->VpiDefName())] = (const module_inst*)m;
        for (auto& [o, id] : s.AllObjects()) {
            if (!o) continue;
            switch (o->UhdmType()) {
            case uhdmcont_assign: {
                auto* r = ((const cont_assign*)o)->Rhs();
                if (r && r->UhdmType() == uhdmconstant && ((const constant*)r)->VpiValue().empty() &&
                    !r->VpiParent() && r->VpiLineNo() > 0) L1++;
                break;
            }
            case uhdmparam_assign: {
                auto* pa = (const param_assign*)o;
                auto* l = pa->Lhs(); auto* r = pa->Rhs();
                if (l && r && l->UhdmType() == uhdmparameter && l->VpiParent() != pa &&
                    l->VpiParent() && l->VpiParent()->UhdmType() == uhdminterface_inst &&
                    r->UhdmType() == uhdmoperation && ((const operation*)r)->VpiOpType() == vpiAssignmentPatternOp)
                    L2++;
                break;
            }
            case uhdmmodule_inst: {
                auto* mi = (const module_inst*)o;
                auto dit = defs.find(std::string(mi->VpiDefName()));
                if (dit == defs.end() || dit->second == mi || !mi->Parameters() || !dit->second->Parameters()) break;
                for (auto* ip : *mi->Parameters()) {
                    if (ip->UhdmType() != uhdmtype_parameter) continue;
                    for (auto* dp : *dit->second->Parameters())
                        if (dp->UhdmType() == uhdmtype_parameter && dp->VpiName() == ip->VpiName() && dp != ip) L3++;
                }
                break;
            }
            case uhdmport: {
                auto* p = (const port*)o;
                auto* rt = p->Typespec();
                auto* a = rt ? rt->Actual_typespec() : nullptr;
                if (!a) break;
                if (a->UhdmType() == uhdmpacked_array_typespec && a->VpiParent() &&
                    a->VpiParent()->UhdmType() == uhdmtype_parameter) {
                    auto* tp = (const type_parameter*)a->VpiParent();
                    if (tp->Typespec() && tp->Typespec()->Actual_typespec() != a &&
                        p->VpiParent() && p->VpiParent()->UhdmType() == uhdmmodule_inst &&
                        defs.count(std::string(((const module_inst*)p->VpiParent())->VpiDefName())) &&
                        defs[std::string(((const module_inst*)p->VpiParent())->VpiDefName())] == p->VpiParent())
                        L4++;
                }
                if (a->UhdmType() == uhdmlogic_typespec) {
                    auto* lt = (const logic_typespec*)a;
                    if (!lt->VpiParent() && lt->VpiLineNo() > 0 && (!lt->Ranges() || lt->Ranges()->empty()) &&
                        !lt->Elem_typespec() && !lt->Typedef_alias() &&
                        (lt->VpiEndLineNo() > lt->VpiLineNo() || lt->VpiEndColumnNo() - lt->VpiColumnNo() > 5))
                        L5++;
                }
                break;
            }
            default: break;
            }
        }
        std::cout << argv[ai] << " L1=" << L1 << " L2=" << L2 << " L3=" << L3 << " L4=" << L4 << " L5=" << L5 << "\n";
    }
}
