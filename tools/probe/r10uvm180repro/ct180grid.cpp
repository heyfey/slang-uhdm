// r10uvm180 — THE SINGLE-DATABASE CELL DUMP the arm scorer joins on.
// MEASUREMENT ONLY; `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.
//
// Prints one line per PACKAGE-SUBROUTINE-BODY typespec binding:
//
//     <package>/<path of kind@line:col down to the ref>#<n>\t<kind>[<ts> -> <alias>]
//
// The key is the walk's own downward path (UHDM's `UhdmListener` callstack),
// which is producer-independent: no ids, no vpiFullName, no vector index.  The
// walk refuses any path that dives through a `class_defn` or another typespec
// — that is the SHARED class world, which the two producers reach by different
// routes and which no path key can pair.
//
// build: g++ -O2 -std=c++17 ct180grid.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct180grid
// usage: ct180grid <db.uhdm> <tag>        (tag is echoed as the first column)
#include <uhdm/uhdm.h>
#include <uhdm/UhdmListener.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <map>
#include <string>

using namespace UHDM;

static bool scalarTdKind(UHDM_OBJECT_TYPE t) {
    switch (t) {
        case uhdmlogic_typespec: case uhdmbit_typespec: case uhdmint_typespec:
        case uhdminteger_typespec: case uhdmbyte_typespec:
        case uhdmshort_int_typespec: case uhdmlong_int_typespec:
        case uhdmenum_typespec: case uhdmstruct_typespec:
        case uhdmunion_typespec: case uhdmclass_typespec: return true;
        default: return false;
    }
}
static const design* topDesign(Serializer& s) {
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign)
            return (const design*)kv.first;
    return nullptr;
}
class GridDump final : public UhdmListener {
  public:
    std::map<std::string, int> occ;
    std::map<std::string, std::string> rows;
    void enterRef_typespec(const ref_typespec* const o) override {
        const typespec* at = o->Actual_typespec();
        if (!at || !scalarTdKind(at->UhdmType())) return;
        const auto& cs = getCallstack();
        int pkgAt = -1;
        for (int i = (int)cs.size() - 2; i >= 0; --i)
            if (cs[i]->UhdmType() == uhdmpackage) { pkgAt = i; break; }
        if (pkgAt < 0) return;
        for (size_t i = (size_t)pkgAt + 1; i + 1 < cs.size(); ++i)
            if (cs[i]->UhdmType() == uhdmclass_defn ||
                any_cast<const typespec*>(cs[i]))
                return;
        std::string key(cs[pkgAt]->VpiName());
        char e[220];
        for (size_t i = (size_t)pkgAt + 1; i + 1 < cs.size(); ++i) {
            snprintf(e, sizeof e, "/%s@%u:%u", UhdmName(cs[i]->UhdmType()).data(),
                     cs[i]->VpiLineNo(), (unsigned)cs[i]->VpiColumnNo());
            key += e;
        }
        key += "#" + std::to_string(++occ[key]);
        const ref_typespec* al = at->Typedef_alias();
        const typespec* tg = al ? al->Actual_typespec() : nullptr;
        char v[900];
        snprintf(v, sizeof v, "%s[%s -> %s]", UhdmName(at->UhdmType()).data(),
                 std::string(at->VpiName()).c_str(),
                 tg ? std::string(tg->VpiName()).c_str() : "-");
        rows.emplace(key, v);
    }
};

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct180grid <db.uhdm> <tag>\n"); return 2; }
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { fprintf(stderr, "RESTORE_FAIL\n"); return 3; }
    const design* d = topDesign(s);
    if (!d) { fprintf(stderr, "NO_DESIGN\n"); return 3; }
    GridDump g;
    g.listenDesign(d);
    for (auto& [k, v] : g.rows) printf("%s\t%s\t%s\n", argv[2], k.c_str(), v.c_str());
    return 0;
}
