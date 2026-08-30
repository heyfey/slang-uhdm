// r10uvm161 — a NAME QUERY over a UHDM database.  MEASUREMENT ONLY.
// Prints every object whose VpiName (or whose parent chain) contains the given
// substring, with kind, span, id, parent chain, and — for a scope — the
// `vpiVariables` listing and each variable's vpiAutomatic stamp.
//
// build: g++ -O2 -std=c++17 ct161list.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct161list
// usage: ct161list <db.uhdm> <name-substring> [kind-substring]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <string>
#include <vector>

using namespace UHDM;

static std::string ident(const BaseClass* o) {
    if (!o) return "<null>";
    char b[900];
    const std::string kind(UhdmName(o->UhdmType()));
    const std::string nm(o->VpiName());
    snprintf(b, sizeof b, "%s(%s)@%u:%u-%u:%u#%u", kind.c_str(), nm.c_str(),
             o->VpiLineNo(), (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo(), o->UhdmId());
    return b;
}
static std::string chain(const BaseClass* o) {
    std::string s;
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent())
        s += " < " + ident(p);
    return s;
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct161list <db> <name> [kind]\n"); return 2; }
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
    const std::string want(argv[2]);
    const std::string kwant(argc > 3 ? argv[3] : "");
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        const std::string kind(UhdmName(o->UhdmType()));
        if (!kwant.empty() && kind.find(kwant) == std::string::npos) continue;
        const std::string nm(o->VpiName());
        if (nm.find(want) == std::string::npos) continue;
        printf("%s%s\n", ident(o).c_str(), chain(o).c_str());
        if (const scope* sc = any_cast<const scope*>(o)) {
            auto* v = sc->Variables();
            printf("    Variables=%s\n", v ? std::to_string(v->size()).c_str() : "null");
            if (v)
                for (size_t i = 0; i < v->size(); ++i) {
                    const variables* var = v->at(i);
                    printf("      [%zu] %s vpiAutomatic=%d\n", i, ident(var).c_str(),
                           (int)var->VpiAutomatic());
                }
        }
        if (const ref_obj* ro = any_cast<const ref_obj*>(o))
            printf("    ref_obj::Actual_group = %s\n", ident(ro->Actual_group()).c_str());
        if (const task_func* tf = any_cast<const task_func*>(o))
            printf("    task_func::Stmt = %s   VpiAutomatic=%d\n",
                   ident(tf->Stmt()).c_str(), (int)tf->VpiAutomatic());
        if (const begin* b = any_cast<const begin*>(o)) {
            auto* st = b->Stmts();
            printf("    Stmts=%s\n", st ? std::to_string(st->size()).c_str() : "null");
            if (st)
                for (size_t i = 0; i < st->size(); ++i)
                    printf("      [%zu] %s\n", i, ident(st->at(i)).c_str());
        }
    }
    return 0;
}
