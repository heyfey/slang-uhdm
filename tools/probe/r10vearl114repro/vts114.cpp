// r10vearl114 -- INDEPENDENT hier_path TYPESPEC-EDGE READER (measurement only).
// The official uhdm-cmp is the sole acceptance judge.  LHS is ALWAYS golden.
//
// For EVERY hier_path in a database, print one TSV row:
//   span \t name \t tsEdge(path) \t rootKind \t rootName \t tsEdge(root)
//     \t parentKind \t scopeChain
// so a verifier can ask, cell by cell and WITHOUT the implementer's key:
//   * does GOLDEN hang a typespec here, and on WHICH object?
//   * does OURS?
//   * what is the ROOT object's own kind and typespec on each side?
// No dedup, no scoring: the raw rows, sorted, so a diff IS the finding.
//
// build:
//   g++ -O2 -std=c++17 vts114.cpp -I ~/.local/include \
//       -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o vts114
// usage: vts114 <db.uhdm> [tag]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <string>
#include <vector>

using namespace UHDM;

static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : "-";
}
static std::string bn(std::string f) {
    auto p = f.rfind('/');
    if (p != std::string::npos) f = f.substr(p + 1);
    return f.empty() ? std::string("-") : f;
}
static std::string spanOf(const BaseClass* o) {
    char b[160];
    snprintf(b, sizeof b, "%s:%u:%u-%u:%u", bn(std::string(o->VpiFile())).c_str(),
             o->VpiLineNo(), (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo());
    return b;
}
static std::string tsEdge(const expr* e) {
    if (!e) return "ts=notexpr";
    auto* rt = e->Typespec();
    if (!rt) return "ts=<none>";
    std::string s = "ts=rt(n='" + std::string(rt->VpiName()) + "',dn='" +
                    std::string(rt->VpiDefName()) + "')->";
    auto* a = rt->Actual_typespec();
    s += kindOf(a);
    if (a) s += "('" + std::string(a->VpiName()) + "')";
    return s;
}
// The ANCESTOR CHAIN by kind+name, so gen depth / carrier / def-vs-elab are
// readable off the row itself instead of being asserted.
static std::string chainOf(const BaseClass* o) {
    std::string s;
    int d = 0;
    for (const BaseClass* p = o->VpiParent(); p && d < 24; p = p->VpiParent(), d++) {
        s += "/" + kindOf(p);
        if (!std::string(p->VpiName()).empty())
            s += "'" + std::string(p->VpiName()) + "'";
    }
    return s.empty() ? "-" : s;
}

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: vts114 <db.uhdm> [tag]\n"); return 2; }
    const char* tag = argc > 2 ? argv[2] : "-";
    Serializer s;
    std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
    if (restored.empty()) { printf("VTSRC 1\n"); return 0; }
    std::vector<std::string> rows;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdmhier_path) continue;
        auto* h = (const hier_path*)o;
        const any* rv = h->Root_value();
        const expr* rve = rv ? any_cast<const expr*>(rv) : nullptr;
        std::string row = std::string(tag) + "\t" + spanOf(h) + "\t" +
                          std::string(h->VpiName()) + "\t" + tsEdge(h) + "\t" +
                          "rv=" + kindOf(rv) + "('" +
                          (rv ? std::string(rv->VpiName()) : std::string()) +
                          "')\trts=" + (rv ? (rve ? tsEdge(rve) : std::string("ts=notexpr"))
                                           : std::string("ts=norv")) +
                          "\tpe=" + std::to_string(h->Path_elems() ? h->Path_elems()->size() : 0) +
                          "\tsz=" + std::to_string(h->VpiSize()) +
                          "\tdc='" + std::string(h->VpiDecompile()) + "'" +
                          "\t" + chainOf(h);
        rows.push_back(row);
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) printf("%s\n", r.c_str());
    printf("VTSCOUNT %zu\nVTSRC 0\n", rows.size());
    return 0;
}
