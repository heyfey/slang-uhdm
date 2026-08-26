// r10earl98 -- THE CENSUS.  Every ref_obj-derived node inside a GEN-SCOPE
// continuous assignment, keyed by identity and carrying a COMPARE-VISIBLE
// payload (the Actual_group binding, which is exactly what ref_obj::Compare
// reads).  MEASUREMENT ONLY -- the official uhdm-cmp is the judge.
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// KEY   <genScopeFullName> | <ca span> | <refKind> | <refName> | <ref span> | <slot>
// PAY   bound=0            or   bound=1:<targetKind>:<targetName>
// The key carries NO file (our objects have an empty VpiFile) and no id.
// `slot` is Lhs / Rhs / deep so a whole-Rhs ref and the Lhs ref of the same
// name never collide.
//
// build: g++ -O2 -std=c++17 ct98cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct98cen
// usage: ct98cen <file.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
#include <vector>
#include <map>
using namespace UHDM;

static std::string fullOf(const BaseClass* o) {
    if (!o) return "";
    if (const scope* x = any_cast<const scope*>(o)) return std::string(x->VpiFullName());
    if (const variables* x = any_cast<const variables*>(o)) return std::string(x->VpiFullName());
    if (const nets* x = any_cast<const nets*>(o)) return std::string(x->VpiFullName());
    if (const ref_obj* x = any_cast<const ref_obj*>(o)) return std::string(x->VpiFullName());
    if (const parameter* x = any_cast<const parameter*>(o)) return std::string(x->VpiFullName());
    if (const gen_scope_array* x = any_cast<const gen_scope_array*>(o)) return std::string(x->VpiFullName());
    return "";
}
static std::string span(const BaseClass* o) {
    char b[64];
    snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
             o->VpiEndLineNo(), (unsigned)o->VpiEndColumnNo());
    return b;
}
int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct98cen <file.uhdm>\n"); return 2; }
    Serializer s;
    const std::vector<vpiHandle> h = s.Restore(std::string(argv[1]));
    if (h.empty()) { fprintf(stderr, "restore failed\n"); return 3; }
    // cont_assign -> its owning gen_scope (nullptr when not gen-scope homed)
    std::map<const cont_assign*, const BaseClass*> caScope;
    for (const auto& [obj, id] : s.AllObjects()) {
        if (!obj || obj->UhdmType() != uhdmcont_assign) continue;
        const BaseClass* p = obj->VpiParent();
        if (p && p->UhdmType() == uhdmgen_scope) caScope[(const cont_assign*)obj] = p;
    }
    std::map<std::string, int> rows;
    for (const auto& [obj, id] : s.AllObjects()) {
        if (!obj) continue;
        const ref_obj* r = any_cast<const ref_obj*>(obj);
        if (!r) continue;
        // Walk up to the owning cont_assign (bounded) and record the slot.
        const BaseClass* p = r->VpiParent();
        const cont_assign* ca = nullptr;
        int depth = 0;
        for (; depth < 40 && p; depth++) {
            if (p->UhdmType() == uhdmcont_assign) { ca = (const cont_assign*)p; break; }
            p = p->VpiParent();
        }
        if (!ca) continue;
        auto it = caScope.find(ca);
        if (it == caScope.end()) continue;
        const char* slot = (ca->Lhs() == (const expr*)r) ? "Lhs"
                         : (ca->Rhs() == (const expr*)r) ? "Rhs" : "deep";
        char key[1400];
        snprintf(key, sizeof key, "%s|%s|%s|%s|%s|%s|d%d",
                 fullOf(it->second).c_str(), span(ca).c_str(),
                 std::string(UhdmName(r->UhdmType())).c_str(),
                 std::string(r->VpiName()).c_str(), span(r).c_str(), slot, depth);
        const any* a = r->Actual_group();
        std::string pay = "bound=0";
        if (a) {
            pay = "bound=1:" + std::string(UhdmName(a->UhdmType())) + ":" +
                  std::string(a->VpiName());
        }
        rows[std::string(key) + "\t" + pay]++;
    }
    for (const auto& [k, c] : rows) printf("%d\t%s\n", c, k.c_str());
    return 0;
}
