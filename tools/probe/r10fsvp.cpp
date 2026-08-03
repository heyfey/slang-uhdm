// r10fsvp: assignment-pattern (opType 75) element census, per package VIEW.
// Prints, for every param_assign whose Rhs is a vpiAssignmentPatternOp, each
// tagged_pattern's member name and the CMP-relevant projection of its
// vpiPattern (VpiType / VpiConstType / VpiSize / VpiDecompile).  Decides
// whether the ELABORATED view re-sizes each element to the struct member's
// width (it does, in Surelog) and what encoding it lands on.
//   g++ -std=c++17 -I$HOME/.local/include r10fsvp.cpp -o r10fsvp \
//       -L$HOME/.local/lib64 -luhdm -lcapnp -lkj
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string vdesc(const any* v) {
    if (!v) return "-";
    if (v->UhdmType() != uhdmconstant)
        return std::string(UhdmName(v->UhdmType()));
    auto* c = (const constant*)v;
    std::string dc(c->VpiDecompile());
    if (dc.size() > 24) dc = dc.substr(0, 8) + "..(" + std::to_string(dc.size()) + ")";
    return "const ct" + std::to_string(c->VpiConstType()) + " sz" +
           std::to_string(c->VpiSize()) + " dc'" + dc + "' val'" +
           std::string(c->VpiValue()).substr(0, 24) + "'";
}

static void doInst(const std::string& tag, const instance* in) {
    if (!in->Param_assigns()) return;
    for (auto* pa : *in->Param_assigns()) {
        auto* r = pa->Rhs();
        if (!r || r->UhdmType() != uhdmoperation) continue;
        auto* op = (const operation*)r;
        if (op->VpiOpType() != vpiAssignmentPatternOp) continue;
        std::string nm = pa->Lhs() ? std::string(pa->Lhs()->VpiName()) : "?";
        std::cout << tag << " " << in->VpiName() << "::" << nm << " operands="
                  << (op->Operands() ? op->Operands()->size() : 0) << "\n";
        if (!op->Operands()) continue;
        for (auto* o : *op->Operands()) {
            if (o->UhdmType() == uhdmtagged_pattern) {
                auto* tp = (const tagged_pattern*)o;
                std::string mn = "?";
                if (tp->Typespec() && tp->Typespec()->Actual_typespec())
                    mn = tp->Typespec()->Actual_typespec()->VpiName();
                std::cout << "   " << mn << " = " << vdesc(tp->Pattern()) << "\n";
            }
            else {
                std::cout << "   <plain> = " << vdesc(o) << "\n";
            }
        }
    }
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    if (d->AllPackages()) for (auto* p : *d->AllPackages()) doInst("ALLPKG", p);
    if (d->TopPackages()) for (auto* p : *d->TopPackages()) doInst("TOPPKG", p);
    if (d->AllModules()) for (auto* m : *d->AllModules()) doInst("ALLMOD", m);
    if (d->TopModules()) for (auto* m : *d->TopModules()) doInst("TOPMOD", m);
    return 0;
}
