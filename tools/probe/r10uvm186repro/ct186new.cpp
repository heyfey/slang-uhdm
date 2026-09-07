// r10uvm186 — THE DYNAMIC-ARRAY `new[...]` ARGUMENT BINDING CENSUS.
// MEASUREMENT ONLY; `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// One row per `ref_obj` / `ref_var` whose IMMEDIATE parent is a
// `method_func_call` NAMED `new` that carries no `vpiFunction` — i.e. the
// argument face of BOTH `new` spellings — carrying, beside the argument's own
// `vpiActual` (at IDENTITY granularity: kind(name)@line:col), the two-pass
// DYN flag that separates the DYNAMIC-ARRAY form from the CLASS constructor.
//
// THE DYN CLASSIFIER, and why it is a POSITION-keyed two-pass.  Surelog's
// `CompileHelper::compileBlockingAssignment` gives the CLASS form's `fcall` a
// `VpiParent` (the assignment) and the DYNAMIC-ARRAY form's NONE
// (CompileHelper.cpp:4483-4498; the whole decode is § newArrayArgNoBind16 in
// include/UhdmExporter.h).  But a WILDCARD-IMPORT CLONE re-parents everything
// it copies, so in a clone listing BOTH forms are parented and the per-object
// test is blind there.  Every UVM subroutine is listed at HOME as well, so the
// classifier keys on the SOURCE POSITION of the call and marks that position
// DYN when ANY instance of it in the database is unparented.  Measured to
// agree on both sides for every position in the nine UVM databases.
//
// KEY (id-free, span-free on the ancestors):
//
//     LISTING | LINE:COL | NAME | ARGIDX | DYN
//
// THE LISTING MUST NOT BE READ OFF `VpiParent`.  A bottom-up walk from the
// argument dies at the UNPARENTED `new` call in every home and elaborated
// listing (and on OUR side in the clone too, since we never parent that call
// and no generated `Compare` reads `VpiParent` — RESUME §9), so a naive
// listing key collapses four listings into one bucket and a PRE-EXISTING
// residue in the elaborated listing then masquerades as a MOVED-WRONG on the
// clone cell.  The fix is an OWNER INDEX built in pass 1: every `assignment`
// whose `Rhs()` is a `method_func_call` names that call's real owner, so the
// walk resumes from the assignment and reaches the true root.  A cell with no
// such owner is reported as `noowner:` and is scored in its own bucket rather
// than silently merged.
//
// The VALUE is the ACTUAL's own FACE (`kind(name)@line:col`) — IDENTITY
// granularity, not a three-valued verdict, so a move between two different
// WRONG objects cannot hide (r10v184 §4 named that blind spot).  Values are
// joined as a MULTISET per key: a wildcard-import clone is listed TWICE under
// one root and a dictionary keyed by position alone drops the second copy
// (RESUME §9).
//
// build: g++ -O2 -std=c++17 ct186new.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct186new
// usage: ct186new <db.uhdm> [name-substr]
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
// vpiFullName is DUMP-ONLY (no generated Compare reads it, RESUME §9); it is
// carried as a trailing readability column and is never part of the key.
static std::string fullOf(const BaseClass* o) {
    if (const ref_obj* r = any_cast<const ref_obj*>(o)) return std::string(r->VpiFullName());
    if (const ref_var* r = any_cast<const ref_var*>(o)) return std::string(r->VpiFullName());
    return {};
}
static const BaseClass* actualOf(const BaseClass* o) {
    if (const ref_obj* r = any_cast<const ref_obj*>(o)) return r->Actual_group();
    if (const ref_var* r = any_cast<const ref_var*>(o)) return r->Actual_group();
    return nullptr;
}
// The listing root, walked through the OWNER INDEX so an unparented `new`
// call cannot truncate the chain (see the header note).
static std::string listingOf(const BaseClass* o,
                             const std::map<const BaseClass*, const BaseClass*>& own) {
    std::string root;
    bool cls = false;
    const BaseClass* p = o->VpiParent();
    if (!p) { auto it = own.find(o); if (it != own.end()) p = it->second; }
    for (; p;) {
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
    if (argc < 2) { fprintf(stderr, "usage: ct186new <db.uhdm> [name-substr]\n"); return 2; }
    const char* want = argc > 2 ? argv[2] : nullptr;
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }

    // PASS 1 — the DYN classifier (keyed on the call's own source position)
    // and the OWNER INDEX that lets the listing walk survive an unparented
    // call.
    std::set<std::string> dynPos;
    std::map<const BaseClass*, const BaseClass*> own;
    size_t nNewCalls = 0;
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
        ++nNewCalls;
        if (!m->VpiParent()) dynPos.insert(posOf(m));
    }

    // PASS 2 — the rows.
    std::vector<std::string> rows;
    size_t nBare = 0, nBound = 0, nDyn = 0;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        if (o->UhdmType() != uhdmref_obj && o->UhdmType() != uhdmref_var) continue;
        const BaseClass* par = o->VpiParent();
        if (!par || par->UhdmType() != uhdmmethod_func_call) continue;
        const method_func_call* m = (const method_func_call*)par;
        if (m->VpiName() != "new" || m->Function()) continue;
        const std::string nm(o->VpiName());
        if (want && nm.find(want) == std::string::npos) continue;
        int argIdx = -1;
        if (m->Tf_call_args())
            for (size_t i = 0; i < m->Tf_call_args()->size(); ++i)
                if (m->Tf_call_args()->at(i) == (const any*)o) argIdx = (int)i;
        const bool dyn = dynPos.count(posOf(m)) != 0;
        const BaseClass* act = actualOf(o);
        if (dyn) ++nDyn;
        if (act) ++nBound; else ++nBare;
        char b[2400];
        snprintf(b, sizeof b, "%-26s %7u:%-3u %-24s arg%-2d %-3s %-40s full=%s",
                 listingOf(o, own).c_str(), o->VpiLineNo(),
                 (unsigned)o->VpiColumnNo(), nm.c_str(), argIdx,
                 dyn ? "DYN" : "CLS", face(act).c_str(),
                 fullOf(o).empty() ? "-" : fullOf(o).c_str());
        rows.push_back(b);
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) printf("%s\n", r.c_str());
    printf("ROWS %zu  DYN %zu  BOUND %zu  BARE %zu  NEWCALLS %zu  DYNPOS %zu\n",
           rows.size(), nDyn, nBound, nBare, nNewCalls, dynPos.size());
    return 0;
}
