// r10v186 (VERIFIER) — THE WHOLE-WINDOW `new[...]` BINDING CENSUS.
// MEASUREMENT ONLY; ~/git-repos/UHDM/build/bin/uhdm-cmp is the sole judge.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// r10uvm186's own ct186new censuses only the refs whose IMMEDIATE parent is
// the `new` call — the DIRECT Tf_call_args faces.  But the production gate the
// pass moves (`newArrayArgNoBind16`) is guarded by newArrayArgDepth16 > 0,
// a WINDOW that covers every NESTED expression inside the argument list too
// (an operation operand, a select index, a nested call's own argument, a loop
// iterator).  A regression at a nested face is therefore INVISIBLE to the
// implementer's scorer.  This census closes that hole: one row for EVERY
// ref_obj / ref_var whose VpiParent chain reaches a `new` method_func_call,
// with the ANCESTOR DEPTH at which it does.
//
// KEY   LISTING | LINE:COL | NAME | DEPTH | DYN
// VALUE the actual's own FACE, kind(name)@line:col, or BARE (identity
//       granularity — a move between two wrong objects cannot hide).
//
// DYN classifier and OWNER INDEX are r10uvm186's, re-implemented here and
// re-measured: a call POSITION is DYN when ANY instance of it in the database
// is unparented (a wildcard clone re-parents its copy, so the per-object test
// is blind in a clone listing).
//
// build: g++ -O2 -std=c++17 ct186v.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct186v
// usage: ct186v <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("<null>");
}
static std::string face(const BaseClass* o) {
    if (!o) return "BARE";
    char b[600];
    snprintf(b, sizeof b, "%s(%s)@%u:%u", kindOf(o).c_str(),
             std::string(o->VpiName()).c_str(), o->VpiLineNo(),
             (unsigned)o->VpiColumnNo());
    return b;
}
static std::string posOf(const BaseClass* o) {
    char b[64];
    snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
             o->VpiEndLineNo(), (unsigned)o->VpiEndColumnNo());
    return b;
}
static const BaseClass* actualOf(const BaseClass* o) {
    if (const ref_obj* r = any_cast<const ref_obj*>(o)) return r->Actual_group();
    if (const ref_var* r = any_cast<const ref_var*>(o)) return r->Actual_group();
    return nullptr;
}
static std::string listingOf(const BaseClass* o,
                             const std::map<const BaseClass*, const BaseClass*>& own) {
    std::string root;
    bool cls = false;
    const BaseClass* p = o->VpiParent();
    if (!p) { auto it = own.find(o); if (it != own.end()) p = it->second; }
    int guard = 0;
    for (; p && guard < 400; ++guard) {
        if (p->UhdmType() == uhdmclass_defn) cls = true;
        if (p->UhdmType() == uhdmdesign) break;
        root = kindOf(p) + ":" + std::string(p->VpiName());
        const BaseClass* q = p->VpiParent();
        if (!q) { auto it = own.find(p); if (it != own.end()) q = it->second; }
        if (!q) return (root.empty() ? std::string("-") : "noowner:" + root) +
                      (cls ? "+cls" : "");
        p = q;
    }
    return (root.empty() ? std::string("-") : root) + (cls ? "+cls" : "");
}

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct186v <db.uhdm>\n"); return 2; }
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }

    std::set<std::string> dynPos;
    std::map<const BaseClass*, const BaseClass*> own;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        if (o->UhdmType() == uhdmassignment) {
            const assignment* as = (const assignment*)o;
            if (const any* r = as->Rhs()) own[(const BaseClass*)r] = o;
        }
        if (o->UhdmType() != uhdmmethod_func_call) continue;
        const method_func_call* m = (const method_func_call*)o;
        if (m->VpiName() != "new" || m->Function()) continue;
        if (!m->VpiParent()) dynPos.insert(posOf(m));
    }

    std::vector<std::string> rows;
    size_t nBare = 0, nBound = 0, nDeep = 0;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        if (o->UhdmType() != uhdmref_obj && o->UhdmType() != uhdmref_var) continue;
        // walk UP to a `new` call, recording the depth at which it is reached
        const method_func_call* nc = nullptr;
        int depth = 0;
        for (const BaseClass* p = o->VpiParent(); p && depth < 40;
             p = p->VpiParent()) {
            ++depth;
            if (p->UhdmType() == uhdmmethod_func_call) {
                const method_func_call* m = (const method_func_call*)p;
                if (m->VpiName() == "new" && !m->Function()) { nc = m; break; }
            }
        }
        if (!nc) continue;
        if (depth > 1) ++nDeep;
        const bool dyn = dynPos.count(posOf(nc)) != 0;
        const BaseClass* act = actualOf(o);
        if (act) ++nBound; else ++nBare;
        char b[2400];
        snprintf(b, sizeof b, "%-26s %7u:%-3u %-24s d%-2d %-3s %s",
                 listingOf(o, own).c_str(), o->VpiLineNo(),
                 (unsigned)o->VpiColumnNo(), std::string(o->VpiName()).c_str(),
                 depth, dyn ? "DYN" : "CLS", face(act).c_str());
        rows.push_back(b);
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) printf("%s\n", r.c_str());
    printf("ROWS %zu  NESTED %zu  BOUND %zu  BARE %zu  DYNPOS %zu\n",
           rows.size(), nDeep, nBound, nBare, dynPos.size());
    return 0;
}
