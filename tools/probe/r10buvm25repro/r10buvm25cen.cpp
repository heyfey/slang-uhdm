// r10buvm25 — THE FOREACH LOOP-VARIABLE *KIND AND TYPESPEC* CENSUS.
// MEASUREMENT ONLY; nothing here is an acceptance judge (uhdm-cmp and
// scripts/verify_golden.py are).
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// buvm17's r10buvm17cen answered the BINDING side of a foreach loop variable
// (does a body reference bind the listed object).  This one answers the
// LISTING side that buvm24's R0 head names: WHAT KIND of object is listed in
// `vpiLoopVars`, and WHAT TYPESPEC hangs under it.
//
// One row per (foreach_stmt x loop-variable SLOT):
//   key   = enclosing subroutine full name | foreach line:col | slot index
//           | the loop variable's NAME            (never the file: OUR
//             expression nodes carry an EMPTY VpiFile — buvm16 §4)
//   view  = ELABPKG / DEFPKG / TOPMOD / DEFMOD / DEFCLASS / DEFPROG / DEFIFACE
//           (which of the design's lists holds the foreach's ROOT ancestor,
//           stopping ONE STEP BELOW uhdmdesign — buvm17 census trap 1)
//   value = lvkind ; lvts (typespec kind) ; lvtsname ; lvtsloc
//           ; arrkind ; arrts ; arrtsname ; arrtsloc ; arrname
//           ; elem= the array_typespec's Elem_typespec kind/name
//           ; idxts= its Index_typespec kind/name
//           ; nranges
//
// `lvtsloc` is `-` when the typespec carries NO location — the discriminator
// between a FRESH `s.MakeArray_typespec()` (Surelog's
// getSimpleVarFromTypespec `else` arm, CompileType.cpp:219-227) and a shared
// declaration object.
//
// usage: r10buvm25cen <file.uhdm> [tag]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <iostream>
#include <map>
#include <set>
#include <string>
#include <vector>
using namespace UHDM;

static std::string nm(const any* t) { return t ? std::string(t->VpiName()) : "-"; }
static std::string kd(const any* t) { return t ? std::string(UhdmName(t->UhdmType())) : "NULL"; }
static std::string loc(const any* o) {
    if (!o) return "-";
    if (o->VpiLineNo() == 0) return "-";
    return std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo());
}
static std::string fn(const any* t) {
    if (!t) return "-";
    if (t->UhdmType() == uhdmfunction) return std::string(((const function*)t)->VpiFullName());
    if (t->UhdmType() == uhdmtask) return std::string(((const task*)t)->VpiFullName());
    return std::string(t->VpiName());
}
// the ACTUAL typespec behind a variables' ref_typespec slot
static const typespec* actTs(const any* v) {
    if (!v) return nullptr;
    if (const expr* e = any_cast<const expr*>(v))
        if (const ref_typespec* rt = e->Typespec()) return rt->Actual_typespec();
    return nullptr;
}
static std::string tsDesc(const typespec* t) {
    if (!t) return "NULL;-;-";
    std::string r = kd(t) + ";" + (nm(t).empty() ? "''" : nm(t)) + ";" + loc(t);
    return r;
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: r10buvm25cen <file.uhdm> [tag]\n"; return 2; }
    std::string tag = argc > 2 ? argv[2] : "T";
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { std::cout << "RESTORE_FAIL " << tag << "\n"; return 3; }

    std::map<const any*, std::string> rootView;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o || o->UhdmType() != uhdmdesign) continue;
        const design* d = (const design*)o;
        if (auto* v = d->TopPackages()) for (auto* p : *v) rootView.emplace(p, "ELABPKG");
        if (auto* v = d->TopModules()) for (auto* p : *v) rootView.emplace(p, "TOPMOD");
        if (auto* v = d->AllPackages()) for (auto* p : *v) rootView.emplace(p, "DEFPKG");
        if (auto* v = d->AllModules()) for (auto* p : *v) rootView.emplace(p, "DEFMOD");
        if (auto* v = d->AllClasses()) for (auto* p : *v) rootView.emplace(p, "DEFCLASS");
        if (auto* v = d->AllPrograms()) for (auto* p : *v) rootView.emplace(p, "DEFPROG");
        if (auto* v = d->AllInterfaces()) for (auto* p : *v) rootView.emplace(p, "DEFIFACE");
    }

    std::vector<std::string> rows;
    long nfe = 0, nlv = 0;
    std::map<std::string, long> kindHist;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o || o->UhdmType() != uhdmforeach_stmt) continue;
        nfe++;
        const foreach_stmt* f = (const foreach_stmt*)o;

        std::string home, homeKind = "-", view = "OTHER", chain;
        const any* p = o->VpiParent();
        const any* last = o;
        int d = 0;
        while (p && d++ < 64) {
            UHDM_OBJECT_TYPE t = p->UhdmType();
            if (home.empty() && (t == uhdmfunction || t == uhdmtask)) {
                home = fn(p); if (home == "-" || home.empty()) home = nm(p);
                homeKind = kd(p);
            }
            if (t != uhdmbegin && t != uhdmnamed_begin)
                chain += (chain.empty() ? "" : "<") + kd(p);
            if (t != uhdmdesign) last = p;
            p = p->VpiParent();
        }
        auto rv = rootView.find(last);
        view = (rv != rootView.end()) ? rv->second : ("ROOT-" + kd(last));
        if (home.empty()) home = "<nosub>";

        // the foreach header's ARRAY reference: the FIRST vpiVariables entry
        // (Surelog lists it there), described the same way.
        // foreach_stmt::Compare reads Variable() (SINGULAR) FIRST, then
        // VpiLoopVars (generated foreach_stmt.cpp:100-101) — so the header
        // array reference is the singular slot, not scope::Variables.
        std::string arr = "NONE;-;-;-;-";
        if (const any* a = f->Variable())
            arr = kd(a) + ";" + (nm(a).empty() ? "''" : nm(a)) + ";" + tsDesc(actTs(a));
        else if (auto* vs = f->Variables())
            if (!vs->empty()) {
                const any* a = (*vs)[0];
                arr = kd(a) + ";" + (nm(a).empty() ? "''" : nm(a)) + ";" + tsDesc(actTs(a));
            }

        int slot = 0;
        if (auto* vs = f->VpiLoopVars())
            for (auto* v : *vs) {
                nlv++;
                const typespec* lt = actTs(v);
                std::string extra = "-;-";
                std::string nr = "0";
                if (lt && lt->UhdmType() == uhdmarray_typespec) {
                    const array_typespec* at = (const array_typespec*)lt;
                    const typespec* et = nullptr;
                    if (auto* rt = at->Elem_typespec()) et = rt->Actual_typespec();
                    const typespec* it = nullptr;
                    if (auto* rt = at->Index_typespec()) it = rt->Actual_typespec();
                    extra = (et ? kd(et) + "(" + (nm(et).empty() ? "''" : nm(et)) + ")" : "-");
                    extra += ";";
                    extra += (it ? kd(it) + "(" + (nm(it).empty() ? "''" : nm(it)) + ")" : "-");
                    if (auto* rr = at->Ranges()) nr = std::to_string(rr->size());
                }
                kindHist[kd(v)]++;
                rows.push_back("LV " + tag + " key=" + home + "|" + loc(o) + "|" +
                               std::to_string(slot) + "|" + nm(v) +
                               " view=" + view +
                               " lv=" + kd(v) +
                               " lvts=" + tsDesc(lt) +
                               " ext=" + extra + " nr=" + nr +
                               " arr=" + arr +
                               " hk=" + homeKind +
                               " ch=" + (chain.empty() ? "-" : chain));
                slot++;
            }
        if (slot == 0)
            rows.push_back("LV " + tag + " key=" + home + "|" + loc(o) + "|NONE|- view=" + view +
                           " lv=<none> lvts=NULL;-;- ext=-;- nr=0 arr=" + arr +
                           " hk=" + homeKind + " ch=" + (chain.empty() ? "-" : chain));
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) std::cout << r << "\n";
    std::cout << "SUMMARY " << tag << " foreach=" << nfe << " loopvars=" << nlv;
    for (auto& [k, v] : kindHist) std::cout << " " << k << "=" << v;
    std::cout << "\n";
    return 0;
}
