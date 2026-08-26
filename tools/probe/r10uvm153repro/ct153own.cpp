// r10uvm153 — THE OWNER-FINDER for the `LHS: class_var (uvm_pkg::clp)` /
// `RHS: <null>` head.  MEASUREMENT ONLY: ~/git-repos/UHDM/build/bin/uhdm-cmp
// is the sole judge; this tool links the SAME generated Compare and only
// reports.  LHS IS ALWAYS GOLDEN (Surelog); RHS IS ALWAYS OURS.
//
// Three questions, three modes, all answered from the databases themselves:
//   --head        run the OFFICIAL design::Compare and print both failed
//                 objects with their full VpiParent chains.
//   --refs=<id>   REVERSE-REFERENCE scan: every golden object X and every vpi
//                 relation T for which `X.GetByVpiType(T)` yields the target
//                 (singular) or contains it (vector, with its INDEX).  This is
//                 what names the CONTAINER the `<null>` belongs to — the head
//                 print alone never does (RESUME.md §9).
//   --owner=<id>  mask the target into a fresh visited set and re-run the
//                 official design::Compare (ct146own.cpp / ct113own.cpp) — the
//                 head that comes back is the NEXT one, which proves the mask
//                 was the failing cell.
//   --list=<name> print the Variables listing of every object whose VpiName
//                 matches, on BOTH sides, index by index.
//
// build: g++ -O2 -std=c++17 ct153own.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct153own
// usage: ct153own <golden.uhdm> <ours.uhdm> [--head] [--refs=N] [--owner=N]
//                 [--list=<name>] [--maxtype=N]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstdlib>
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
    char b[1200];
    const std::string kind(UhdmName(o->UhdmType()));
    const std::string nm(o->VpiName());
    snprintf(b, sizeof b, "%s(%s)@%s:%u:%u-%u:%u#%u", kind.c_str(), nm.c_str(),
             base(o->VpiFile()).c_str(), o->VpiLineNo(),
             (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo(), o->UhdmId());
    return b;
}
static void chain(const char* tag, const BaseClass* o, int n = 12) {
    printf("%s", tag);
    for (int i = 0; i < n && o; i++) {
        printf("%s%s\n", i ? "        < " : "", ident(o).c_str());
        o = o->VpiParent();
    }
    if (!o) printf("        < <root>\n");
}
struct Head { const BaseClass* lhs = nullptr; const BaseClass* rhs = nullptr; int32_t r = 0; };
static Head runCompare(const design* dg, const design* dou,
                       const std::vector<const BaseClass*>& mask) {
    CompareContext c;
    for (const BaseClass* m : mask) c.m_visited.insert(m);
    Head h;
    h.r = dg->Compare(dou, &c);
    h.lhs = c.m_failedLhs;
    h.rhs = c.m_failedRhs;
    return h;
}
static const BaseClass* byId(Serializer& s, unsigned id) {
    for (const auto& [obj, i] : s.AllObjects())
        if (obj && obj->UhdmId() == id) return obj;
    return nullptr;
}
static void listVars(const char* tag, const BaseClass* o) {
    // scope-derived kinds only
    const scope* sc = dynamic_cast<const scope*>(o);
    if (!sc) { printf("%s %s  <not a scope>\n", tag, ident(o).c_str()); return; }
    auto* v = sc->Variables();
    printf("%s %s Variables=%zu\n", tag, ident(o).c_str(), v ? v->size() : 0);
    if (!v) return;
    for (size_t i = 0; i < v->size(); i++)
        printf("%s   [%zu] %s\n", tag, i, ident((*v)[i]).c_str());
}
int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct153own golden ours [--head] [--refs=N] [--owner=N] [--list=NAME]\n"); return 2; }
    bool doHead = false;
    long refsId = -1, ownerId = -1;
    bool refsOurs = false;
    int maxType = 3200;  // only --alltypes reads it
    // The relation ids to scan.  Default = vpiActual (700) plus the singular
    // expression/typespec relations a variable can hang off; --alltypes widens
    // to every id in 1..maxtype (slow: ~190k objects x N virtual dispatches).
    std::vector<int> types;
    std::vector<std::string> lists, ats;
    for (int a = 3; a < argc; a++) {
        if (!strcmp(argv[a], "--head")) doHead = true;
        else if (!strncmp(argv[a], "--refs=", 7)) refsId = atol(argv[a] + 7);
        else if (!strncmp(argv[a], "--refsours=", 11)) { refsId = atol(argv[a] + 11); refsOurs = true; }
        else if (!strncmp(argv[a], "--owner=", 8)) ownerId = atol(argv[a] + 8);
        else if (!strncmp(argv[a], "--maxtype=", 10)) maxType = atoi(argv[a] + 10);
        else if (!strncmp(argv[a], "--list=", 7)) lists.push_back(argv[a] + 7);
        else if (!strncmp(argv[a], "--at=", 5)) ats.push_back(argv[a] + 5);
        else if (!strncmp(argv[a], "--types=", 8)) {
            const char* q = argv[a] + 8;
            while (*q) { types.push_back(atoi(q)); const char* c = strchr(q, ','); if (!c) break; q = c + 1; }
        }
        else if (!strcmp(argv[a], "--alltypes")) { for (int t = 1; t <= maxType; t++) types.push_back(t); }
    }
    if (types.empty()) types.push_back(700 /*vpiActual*/);
    Serializer sg, so;
    const std::vector<vpiHandle> hg = sg.Restore(std::string(argv[1]));
    const std::vector<vpiHandle> ho = so.Restore(std::string(argv[2]));
    if (hg.empty() || ho.empty()) { fprintf(stderr, "restore failed\n"); return 3; }
    const design* dg = (const design*)((const uhdm_handle*)hg[0])->object;
    const design* dou = (const design*)((const uhdm_handle*)ho[0])->object;

    if (doHead) {
        Head h = runCompare(dg, dou, {});
        printf("HEAD r=%d\n", h.r);
        chain("LHS:    ", h.lhs);
        chain("RHS:    ", h.rhs);
    }
    if (refsId >= 0) {
        Serializer& sr = refsOurs ? so : sg;
        const BaseClass* tgt = byId(sr, (unsigned)refsId);
        printf("REFS target(%s) %s\n", refsOurs ? "ours" : "golden", ident(tgt).c_str());
        if (tgt) {
            for (const auto& [obj, i] : sr.AllObjects()) {
                if (!obj) continue;
                for (int t : types) {
                    auto [single, vt, vec] = obj->GetByVpiType(t);
                    if (single == tgt)
                        printf("REF  SINGULAR vpiType=%d holder=%s\n", t, ident(obj).c_str());
                    if (vec)
                        for (size_t k = 0; k < vec->size(); k++)
                            if ((*vec)[k] == tgt)
                                printf("REF  VECTOR   vpiType=%d idx=%zu/%zu holder=%s\n",
                                       t, k, vec->size(), ident(obj).c_str());
                }
            }
        }
    }
    if (ownerId >= 0) {
        const BaseClass* tgt = byId(sg, (unsigned)ownerId);
        printf("MASK %s\n", ident(tgt).c_str());
        std::vector<const BaseClass*> m;
        if (tgt) m.push_back(tgt);
        Head h = runCompare(dg, dou, m);
        printf("NEXT r=%d\n", h.r);
        chain("LHS:    ", h.lhs);
        chain("RHS:    ", h.rhs);
    }
    // --at=<line>[:<col>] — every object AT that source line on BOTH sides,
    // with its vpiActual (the binding) spelled out.  This is how "ours is
    // bare" is measured rather than assumed.
    for (const std::string& at : ats) {
        unsigned ln = 0, cl = 0;
        sscanf(at.c_str(), "%u:%u", &ln, &cl);
        for (int side = 0; side < 2; side++) {
            Serializer& ss = side ? so : sg;
            const char* tag = side ? "OURS" : "GOLD";
            for (const auto& [obj, i] : ss.AllObjects()) {
                if (!obj || obj->VpiLineNo() != ln) continue;
                if (cl && obj->VpiColumnNo() != cl) continue;
                auto [single, vt, vec] = obj->GetByVpiType(700);
                printf("%s AT %s  vpiActual=%s\n", tag, ident(obj).c_str(),
                       ident(single).c_str());
            }
        }
    }
    for (const std::string& nm : lists) {
        for (const auto& [obj, i] : sg.AllObjects())
            if (obj && obj->VpiName() == nm) listVars("GOLD", obj);
        for (const auto& [obj, i] : so.AllObjects())
            if (obj && obj->VpiName() == nm) listVars("OURS", obj);
    }
    return 0;
}
