// r11u6/tsedge — the EDGE census: for every design listing (AllPackages,
// TopPackages, AllModules, TopModules) and every parameter in it, print the
// IDENTITY (pointer-interned id) of the parameter's Actual_typespec, the
// identity of its Typedef_alias target and of its Instance(), and the FOLD
// SHAPE of each of its own ranges' left bound (plus, for a $clog2 inside the
// bound, the shape of the call's ARGUMENT).
//
// Identity is read from the OBJECT POINTER, never from dump order, which is
// the only way to tell two text-identical elaborated copies apart.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>
#include <vector>
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

static const char* kindName(const any* a) {
    if (!a) return "<null>";
    switch (a->UhdmType()) {
        case uhdmconstant: return "constant";
        case uhdmoperation: return "operation";
        case uhdmref_obj: return "ref_obj";
        case uhdmsys_func_call: return "sys_func_call";
        case uhdmfunc_call: return "func_call";
        default: return "other";
    }
}

// deep-search the bound tree for a $clog2 and report its first argument shape
static std::string clogArg(const any* e) {
    if (!e) return "";
    if (e->UhdmType() == uhdmsys_func_call) {
        auto* c = (const sys_func_call*)e;
        if (std::string(c->VpiName()) == "$clog2") {
            if (auto* a = c->Tf_call_args(); a && !a->empty())
                return std::string("/clog2arg=") + kindName((*a)[0]);
            return "/clog2arg=<none>";
        }
    }
    if (e->UhdmType() == uhdmoperation)
        if (auto* ops = ((const operation*)e)->Operands())
            for (auto* o : *ops) {
                auto r = clogArg(o);
                if (!r.empty()) return r;
            }
    return "";
}

// § the unpacked-array holder: a parameter written `logic [MSB:0] A[N]`
// hangs its DECLARED packed range off the array typespec's ELEMENT, so the
// shape has to be read through Elem_typespec too (r11u6 R2 / g4).
static std::string shapeOf(const typespec* ts, int depth = 0);

static std::string elemOf(const typespec* ts, int depth) {
    if (depth > 4) return "";
    const ref_typespec* er = nullptr;
    if (ts->UhdmType() == uhdmarray_typespec)
        er = ((const array_typespec*)ts)->Elem_typespec();
    else if (ts->UhdmType() == uhdmpacked_array_typespec)
        er = ((const packed_array_typespec*)ts)->Elem_typespec();
    if (!er || !er->Actual_typespec()) return "";
    return "->" + shapeOf(er->Actual_typespec(), depth + 1);
}

static std::string shapeOf(const typespec* ts, int depth) {
    if (!ts) return "<null>";
    const VectorOfrange* rs = nullptr;
    if (ts->UhdmType() == uhdmlogic_typespec)
        rs = ((const logic_typespec*)ts)->Ranges();
    else if (ts->UhdmType() == uhdmpacked_array_typespec)
        rs = ((const packed_array_typespec*)ts)->Ranges();
    else if (ts->UhdmType() == uhdmbit_typespec)
        rs = ((const bit_typespec*)ts)->Ranges();
    else if (ts->UhdmType() == uhdmarray_typespec)
        rs = ((const array_typespec*)ts)->Ranges();
    std::string out = "[";
    if (rs)
        for (size_t i = 0; i < rs->size(); i++) {
            if (i) out += ",";
            const expr* l = (*rs)[i]->Left_expr();
            out += kindName(l);
            out += clogArg(l);
        }
    out += "]";
    return out + elemOf(ts, depth);
}

static void one(const char* listing, const std::string& owner, const any* p) {
    if (p->UhdmType() != uhdmparameter) return;
    auto* pa = (const parameter*)p;
    auto* rt = pa->Typespec();
    const typespec* ts = rt ? rt->Actual_typespec() : nullptr;
    int aliasId = -1;
    if (ts && ts->UhdmType() == uhdmlogic_typespec)
        if (auto* al = ((const logic_typespec*)ts)->Typedef_alias())
            aliasId = idOf(al->Actual_typespec());
    std::cout << "  " << listing << "  " << owner << "." << pa->VpiName()
              << "  ts#" << idOf(ts) << " alias#" << aliasId << " inst#"
              << idOf(ts ? (const void*)ts->Instance() : nullptr) << "  "
              << shapeOf(ts) << "\n";
}

static void walkScope(const char* listing, const std::string& owner,
                      const VectorOfany* params) {
    if (!params) return;
    for (auto* p : *params) one(listing, owner, p);
}

static void walkMod(const char* listing, const module_inst* m) {
    walkScope(listing, std::string(m->VpiFullName()), m->Parameters());
    if (m->Modules())
        for (auto* c : *m->Modules()) walkMod(listing, c);
}

int main(int argc, char** argv) {
    for (int i = 1; i < argc; i++) {
        Serializer s;
        auto h = s.Restore(std::filesystem::path(argv[i]));
        if (h.empty()) { std::cout << "## " << argv[i] << " RESTORE-FAILED\n"; continue; }
        auto* d = (design*)((uhdm_handle*)h[0])->object;
        ids.clear();
        std::cout << "## " << argv[i] << "\n";
        if (d->AllPackages())
            for (auto* p : *d->AllPackages())
                walkScope("allPkg ", std::string(p->VpiName()), p->Parameters());
        if (d->TopPackages())
            for (auto* p : *d->TopPackages())
                walkScope("topPkg ", std::string(p->VpiName()), p->Parameters());
        if (d->AllModules())
            for (auto* m : *d->AllModules()) walkMod("allMod ", m);
        if (d->TopModules())
            for (auto* m : *d->TopModules()) walkMod("topMod ", m);
        std::cout << "\n";
    }
    return 0;
}
