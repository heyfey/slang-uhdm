// r10uvm143 — HEAD OWNER LOCATOR for the `LHS: <null>` io_decl head.
// MEASUREMENT ONLY.  The official ~/git-repos/UHDM/build/bin/uhdm-cmp is the
// sole acceptance judge; this tool links the SAME generated Compare and only
// reports.
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// It (a) prints the head pair with full parent chains, and (b) — given
// --probe=<kind>:<name>:<line>:<col> — masks the matching GOLDEN objects into a
// fresh CompareContext m_visited and reports whether the head MOVED, which
// convicts (or acquits) a candidate owner.  Every generated `<kind>::Compare`
// opens with an LHS-keyed visited-insert and returns 0 on a hit, so masking an
// LHS object makes exactly that comparison succeed.
//
// build: g++ -O2 -std=c++17 ct143own.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct143own
// usage: ct143own <golden.uhdm> <ours.uhdm> [--probe=kind:name:line:col]...
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>

using namespace UHDM;

static std::string base(std::string_view p) {
    size_t i = p.find_last_of('/');
    return std::string(i == std::string_view::npos ? p : p.substr(i + 1));
}
static std::string ident(const BaseClass* o) {
    if (!o) return "<null>";
    char b[768];
    const std::string kind(UhdmName(o->UhdmType()));
    const std::string nm(o->VpiName());
    snprintf(b, sizeof b, "%s(%s)@%s:%u:%u-%u:%u#%u", kind.c_str(), nm.c_str(),
             base(o->VpiFile()).c_str(), o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
             o->VpiEndLineNo(), (unsigned)o->VpiEndColumnNo(), o->UhdmId());
    return b;
}
static void chain(const char* tag, const BaseClass* o, int n = 14) {
    printf("%s", tag);
    for (int i = 0; i < n && o; i++) { printf("%s%s\n", i ? "      < " : "", ident(o).c_str()); o = o->VpiParent(); }
    if (!o) return;
}
struct Head { const BaseClass* lhs = nullptr; const BaseClass* rhs = nullptr; int r = 0; };
static Head runCompare(const design* dg, const design* dou, const std::vector<const BaseClass*>& mask) {
    CompareContext c;
    for (const BaseClass* m : mask) c.m_visited.insert(m);
    Head h; h.r = dg->Compare(dou, &c);
    h.lhs = c.m_failedLhs; h.rhs = c.m_failedRhs; return h;
}
int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct143own golden ours [--probe=kind:name:line:col]\n"); return 2; }
    Serializer sg, so;
    const std::vector<vpiHandle> hg = sg.Restore(std::string(argv[1]));
    const std::vector<vpiHandle> ho = so.Restore(std::string(argv[2]));
    if (hg.empty() || ho.empty()) { fprintf(stderr, "restore failed\n"); return 3; }
    const design* dg = (const design*)((const uhdm_handle*)hg[0])->object;
    const design* dou = (const design*)((const uhdm_handle*)ho[0])->object;

    Head h0 = runCompare(dg, dou, {});
    printf("HEAD r=%d\n", h0.r);
    chain("LHS: ", h0.lhs);
    chain("RHS: ", h0.rhs);

    for (int a = 3; a < argc; a++) {
        if (strncmp(argv[a], "--probe=", 8)) continue;
        char kind[64] = {0}, name[256] = {0}; unsigned ln = 0, col = 0;
        if (sscanf(argv[a] + 8, "%63[^:]:%255[^:]:%u:%u", kind, name, &ln, &col) != 4) {
            printf("PROBE-BADSPEC %s\n", argv[a] + 8); continue;
        }
        std::vector<const BaseClass*> mask;
        for (const auto& [obj, id] : sg.AllObjects()) {
            if (!obj) continue;
            if (std::string(UhdmName(obj->UhdmType())) != kind) continue;
            if (obj->VpiName() != std::string_view(name)) continue;
            if (obj->VpiLineNo() != ln || (unsigned)obj->VpiColumnNo() != col) continue;
            mask.push_back(obj);
        }
        Head h = runCompare(dg, dou, mask);
        printf("PROBE %s masked=%zu -> %s  r=%d\n  newLHS=%s\n  newRHS=%s\n",
               argv[a] + 8, mask.size(),
               (h.lhs == h0.lhs && h.rhs == h0.rhs && h.r == h0.r) ? "HEAD-UNCHANGED" : "HEAD-MOVED",
               h.r, ident(h.lhs).c_str(), ident(h.rhs).c_str());
    }
    return 0;
}
