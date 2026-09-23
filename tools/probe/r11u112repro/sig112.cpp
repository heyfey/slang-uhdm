// sig112 <uhdm>: per-face DATABASE signatures for the r11u112 census (read-only).
//   F2C  cast operations (vpiCastOp) whose typespec actual carries a Typedef_alias
//   F2R  variables parented by a ref_obj (body-local return vars) whose typespec
//        actual carries a Typedef_alias
//   F3N  struct_net + packed_array_net objects under a module_inst
//   F4V  var_select objects whose vpiIndex list ends in an indexed_part_select
//   F1T  constants WITH a typespec whose parent is an operation whose parent is a
//        bit_select (the folded operand of an index operation)
//   F5P  property_spec objects under a property_decl whose vpiPropertyExpr is an
//        operation (the kept property expression)
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
int main(int argc, char** argv) {
    if (argc < 2) return 2;
    Serializer s; s.Restore(std::filesystem::path(argv[1]));
    long f2c = 0, f2r = 0, f3n = 0, f4v = 0, f1t = 0, f5p = 0;
    auto hasAlias = [](const ref_typespec* rt) {
        return rt && rt->Actual_typespec() && rt->Actual_typespec()->Typedef_alias();
    };
    for (auto& [obj, id] : s.AllObjects()) {
        if (!obj) continue;
        auto t = obj->UhdmType();
        const any* par = obj->VpiParent();
        if (t == uhdmoperation) {
            auto* op = (const operation*)obj;
            if (op->VpiOpType() == vpiCastOp && hasAlias(op->Typespec())) f2c++;
        } else if (auto* v = any_cast<const variables*>(obj)) {
            if (par && par->UhdmType() == uhdmref_obj && hasAlias(v->Typespec())) f2r++;
        }
        if ((t == uhdmstruct_net || t == uhdmpacked_array_net) && par &&
            par->UhdmType() == uhdmmodule_inst) f3n++;
        if (t == uhdmvar_select) {
            auto* vs = (const var_select*)obj;
            if (vs->Exprs() && !vs->Exprs()->empty() &&
                vs->Exprs()->back()->UhdmType() == uhdmindexed_part_select) f4v++;
        }
        if (t == uhdmconstant && ((const constant*)obj)->Typespec() && par &&
            par->UhdmType() == uhdmoperation && par->VpiParent() &&
            par->VpiParent()->UhdmType() == uhdmbit_select) f1t++;
        if (t == uhdmproperty_spec && par && par->UhdmType() == uhdmproperty_decl) {
            auto* ps = (const property_spec*)obj;
            if (ps->VpiPropertyExpr() && ps->VpiPropertyExpr()->UhdmType() == uhdmoperation) f5p++;
        }
    }
    std::cout << "F2C=" << f2c << " F2R=" << f2r << " F3N=" << f3n << " F4V=" << f4v
              << " F1T=" << f1t << " F5P=" << f5p << "\n";
    return 0;
}
