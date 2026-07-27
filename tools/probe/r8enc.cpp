// r8enc: package-parameter TYPESPEC IDENTITY across the four design views.
//
// A package parameter's own typespec is SHARED by pointer into the module
// copies Surelog materializes for a wildcard import. Which of the two package
// views (def / elab) a given module copy shares decides whether its range
// bounds read folded or symbolic — and `Compare` follows the pointer, so a
// def-view share drags the UNELABORATED bound into an elab-module comparison.
// This prints, per view, every parameter's typespec pointer (interned to a
// small id), the typespec's first range-bound KIND, and the parameter's value,
// so the sharing graph can be read off both files side by side.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>
using namespace UHDM;

static std::map<const void*, int> ids;
static int idOf(const void* p) {
    if (!p) return -1;
    auto it = ids.find(p);
    if (it != ids.end()) return it->second;
    int n = (int)ids.size() + 1;
    ids[p] = n;
    return n;
}

static std::string loc(const BaseClass* o) {
    if (!o) return "-";
    return std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo());
}

static VectorOfrange* rangesOf(const typespec* ts) {
    if (!ts) return nullptr;
    switch (ts->UhdmType()) {
        case uhdmlogic_typespec: return ((logic_typespec*)ts)->Ranges();
        case uhdmbit_typespec: return ((bit_typespec*)ts)->Ranges();
        case uhdmarray_typespec: return ((array_typespec*)ts)->Ranges();
        case uhdmpacked_array_typespec:
            return ((packed_array_typespec*)ts)->Ranges();
        default: return nullptr;
    }
}

static void showParam(const parameter* p, const std::string& tag) {
    const typespec* ts = nullptr;
    if (const ref_typespec* rt = p->Typespec()) ts = rt->Actual_typespec();
    std::cout << tag << " param " << p->VpiName() << " val='" << p->VpiValue()
              << "' ts#" << idOf(ts);
    if (ts) {
        std::cout << " (" << UhdmName(ts->UhdmType()) << "@" << loc(ts)
                  << " parent=" << (ts->VpiParent()
                                        ? UhdmName(ts->VpiParent()->UhdmType())
                                        : "-")
                  << ")";
        if (auto* rs = rangesOf(ts))
            for (auto* r : *rs)
                std::cout << " bound["
                          << (r->Left_expr()
                                  ? UhdmName(r->Left_expr()->UhdmType())
                                  : "-")
                          << "]";
    }
    std::cout << "\n";
}

static void showRhs(const param_assign* pa, const std::string& tag) {
    const any* r = pa->Rhs();
    std::cout << tag << " assign " << (pa->Lhs() ? pa->Lhs()->VpiName() : "?")
              << " rhs=" << (r ? UhdmName(r->UhdmType()) : "<null>") << "@"
              << loc(r);
    if (r && r->UhdmType() == uhdmconstant)
        std::cout << " '" << ((const constant*)r)->VpiDecompile() << "' "
                  << ((const constant*)r)->VpiValue();
    if (r && r->UhdmType() == uhdmoperation) {
        auto* op = (const operation*)r;
        std::cout << " op" << op->VpiOpType()
                  << (op->VpiReordered() ? " REORDERED" : "");
        if (op->Operands())
            for (auto* o : *op->Operands())
                std::cout << " {" << UhdmName(o->UhdmType()) << " "
                          << o->VpiName() << "}";
    }
    std::cout << "\n";
}

template <typename V>
static void walkInst(V* v, const char* tag) {
    if (!v) return;
    for (auto* inst : *v) {
        std::string t = std::string(tag) + "[" + std::string(inst->VpiName()) + "]";
        if (inst->Parameters())
            for (auto* p : *inst->Parameters())
                if (p->UhdmType() == uhdmparameter)
                    showParam((const parameter*)p, t);
        if (inst->Param_assigns())
            for (auto* pa : *inst->Param_assigns()) showRhs(pa, t);
    }
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    auto* d = (design*)((uhdm_handle*)h[0])->object;
    walkInst(d->AllPackages(), "defPkg");
    walkInst(d->TopPackages(), "topPkg");
    walkInst(d->AllModules(), "defMod");
    walkInst(d->TopModules(), "topMod");
    return 0;
}
