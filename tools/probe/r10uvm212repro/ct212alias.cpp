// r10uvm212 — THE CLONE-vs-BASE LISTING CENSUS.  MEASUREMENT ONLY; the official
// `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.  LHS is ALWAYS golden
// (Surelog); RHS is ALWAYS ours.
//
// Surelog's later typedefs of ONE target take the `clone_tree` path
// (~/git-repos/Surelog/src/DesignCompile/ElaborationStep.cpp:193-200): the clone
// is a deep copy of the BASE typespec with a `Typedef_alias` ref back to it.  So
// for every `class_typespec` that CARRIES a `Typedef_alias`, this tool prints
// the clone's own specialization listing beside THE BASE'S, and flags every row
// where the two disagree.  `NUL` (a NULL vector pointer) and `n0` are printed
// apart, because `BaseClass.h:220` fires only on NULL-vs-non-empty.
//
// usage: ct212alias <db.uhdm>
// build: g++ -O2 -std=c++17 ct212alias.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct212alias
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <map>
#include <string>
#include <vector>

using namespace UHDM;

static std::string vecCell(const std::vector<const BaseClass*>* v) {
    if (!v) return "NUL";
    char b[32];
    snprintf(b, sizeof b, "n%zu", v->size());
    return b;
}
static std::string pOf(const class_typespec* c) {
    return vecCell((const std::vector<const BaseClass*>*)c->Parameters()) + "/" +
           vecCell((const std::vector<const BaseClass*>*)c->Param_assigns());
}
static std::string ownerOf(const BaseClass* o) {
    const BaseClass* p = o ? o->VpiParent() : nullptr;
    if (!p) return "<none>";
    return std::string(UhdmName(p->UhdmType())) + ":" + std::string(p->VpiName());
}

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct212alias <db.uhdm>\n"); return 2; }
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
    std::map<std::string, int> rows;
    size_t clones = 0, disagree = 0;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdmclass_typespec) continue;
        const class_typespec* c = (const class_typespec*)o;
        const ref_typespec* al = c->Typedef_alias();
        if (!al) continue;
        ++clones;
        const BaseClass* act = al->Actual_typespec();
        const class_typespec* b =
            (act && act->UhdmType() == uhdmclass_typespec)
                ? (const class_typespec*)act
                : nullptr;
        const std::string cp = pOf(c);
        const std::string bp = b ? pOf(b) : std::string("<base-not-class_ts>");
        const bool bad = (cp != bp);
        if (bad) ++disagree;
        char buf[900];
        snprintf(buf, sizeof buf, "%s CLONE %-20s in %-42s P/PA=%-11s || BASE %-20s in %-42s P/PA=%s",
                 bad ? "MISMATCH" : "agree   ", std::string(c->VpiName()).c_str(),
                 ownerOf(c).c_str(), cp.c_str(),
                 b ? std::string(b->VpiName()).c_str() : "-",
                 b ? ownerOf(b).c_str() : "-", bp.c_str());
        rows[buf]++;
    }
    printf("# aliased class_typespecs=%zu  clone/base listing MISMATCHES=%zu\n",
           clones, disagree);
    for (auto& kv : rows) printf("x%-4d %s\n", kv.second, kv.first.c_str());
    return 0;
}
