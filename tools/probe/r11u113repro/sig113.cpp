// sig113 <uhdm>: per-face DATABASE signatures for the r11u113 census (read-only).
//   R1S  constants parented by a range whose parent is a typespec, with NO typespec and a
//        vpiSize in (0,64) (face 1: the bare, declared-width range bound)
//   C2U  unsupported_typespec actuals of a cast operation's ref_typespec (face 2)
//   E3M  enum_typespec objects parented by a typespec_member (face 3)
//   Q4R  range objects that are an OPERAND of an operation (face 4)
//   V5T  constants WITH a typespec whose parent is an operation whose parent is a
//        var_select (face 5, § caVarSelIdxOpFoldTs113)
//   B5T  the same under a bit_select (face 5b, § genCaBitSelIdxOpFoldTsParse113; also
//        pass 112's module-scope stamps)
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
int main(int argc, char** argv) {
    if (argc < 2) return 2;
    Serializer s; s.Restore(std::filesystem::path(argv[1]));
    long r1s = 0, c2u = 0, e3m = 0, q4r = 0, v5t = 0, b5t = 0;
    for (auto& [obj, id] : s.AllObjects()) {
        if (!obj) continue;
        auto t = obj->UhdmType();
        const any* par = obj->VpiParent();
        if (t == uhdmconstant) {
            auto* c = (const constant*)obj;
            if (!c->Typespec() && par && par->UhdmType() == uhdmrange && par->VpiParent() &&
                any_cast<const typespec*>(par->VpiParent()) && c->VpiSize() > 0 && c->VpiSize() < 64)
                r1s++;
            if (c->Typespec() && par && par->UhdmType() == uhdmoperation && par->VpiParent()) {
                if (par->VpiParent()->UhdmType() == uhdmvar_select) v5t++;
                if (par->VpiParent()->UhdmType() == uhdmbit_select) b5t++;
            }
        }
        if (t == uhdmoperation) {
            auto* op = (const operation*)obj;
            if (op->VpiOpType() == vpiCastOp && op->Typespec() && op->Typespec()->Actual_typespec() &&
                op->Typespec()->Actual_typespec()->UhdmType() == uhdmunsupported_typespec) c2u++;
            if (op->Operands())
                for (auto* o : *op->Operands())
                    if (o && o->UhdmType() == uhdmrange) q4r++;
        }
        if (t == uhdmenum_typespec && par && par->UhdmType() == uhdmtypespec_member) e3m++;
    }
    std::cout << "R1S=" << r1s << " C2U=" << c2u << " E3M=" << e3m << " Q4R=" << q4r
              << " V5T=" << v5t << " B5T=" << b5t << "\n";
    return 0;
}
