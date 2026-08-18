// r10buvm14cen — THE CENSUS INSTRUMENT for the HIER_PATH ELEMENT-LIST family,
// with a named sub-family for a hier_path whose LAST element is a
// METHOD_FUNC_CALL (the built-in / class method-call receiver path).
//
// MEASUREMENT ONLY.  The official uhdm-cmp is the acceptance judge.
// LHS is ALWAYS golden; this tool reads ONE database and tags its rows, so the
// caller joins golden rows against ours (cenjoin14.py).
//
// Reads a .uhdm out of Serializer::AllObjects() (NEVER dump TEXT) and prints
//
//   HP <tag> key=<view>|<file>|<line>:<col> name=<VpiName> n=<elems>
//      mc=<0|1>            last element is a method_func_call
//      nsel=<k>            how many elements are bit_select / part_select /…
//      shape=<kind(name)[full]|kind(name)[full]|…>
//      args=<n args on the trailing method_func_call, -1 when not a call>
//
//   SUMMARY <tag> hier_paths=<n> mc=<n> …
//
// WHY THE KEY IS THE LOCATION AND NOT THE NAME.  This pass changes the ELEMENT
// LIST; a law that also moved the hier_path's own VpiName would make a
// name-keyed join report every moved cell as ARITY-DIFF rather than as a
// DISAGREE that converts, i.e. the census could not see its own subject.  The
// hier_path's own start location is stable across the change on both sides and
// is what the two producers agree on at the head (21564:13 on both).  The NAME
// is carried as a VALUE so a name move is still reported — as a DISAGREE.
//
// THE VIEW IS **NOT** IN THE KEY, AND THAT IS A MEASURED DECISION, not an
// omission.  A package/class body IS emitted twice (DEF and ELAB) and the two
// copies do live at the same file:line:col -- but the two PRODUCERS label the
// same object differently: uvm_pkg.sv:8620:9's hier_path climbs to a TopPackage
// in Surelog's database (ELAB) and to an AllPackages copy in ours (DEF), while
// the TOTALS agree exactly (2821/2822 DEF, 4912/4912 ELAB).  Keying or valuing
// on the view therefore turns every row into a MISSING/EXTRA pair.  The two
// copies land in ONE bucket instead and the MULTISET compare separates them by
// CONTENT, which is the field the judge can actually see.  (buvm13 hit the
// mirror image of this trap: there the view had to be taken from the OWNER.)
//
// usage: r10buvm14cen <file.uhdm> [tag]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <map>
#include <string>
#include <vector>

using namespace UHDM;

static std::string nm(const any* t) {
    if (!t) return "-";
    std::string n(t->VpiName());
    return n.empty() ? "" : n;
}
// VpiFullName lives on the leaf classes, not on `any`: read it through the
// bases that actually declare it: `ref_obj` (which `bit_select` derives from)
// and `scope`.  `method_func_call` (a `tf_call`) declares NO VpiFullName at
// all, so its cell reads "" on both sides by construction — a field the census
// cannot see is reported as absent rather than invented.
static std::string full(const any* t) {
    if (!t) return "-";
    if (auto* e = dynamic_cast<const ref_obj*>(t)) return std::string(e->VpiFullName());
    if (auto* c = dynamic_cast<const scope*>(t)) return std::string(c->VpiFullName());
    return "";
}
static std::string loc(const any* o) {
    if (!o) return "-";
    return std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo());
}
// OUR hier_paths carry an EMPTY VpiFile while Surelog's carry the source path,
// so the file is inherited from the nearest ANCESTOR that has one.  Without
// this the file half of the key is "" on every one of our rows and the join
// reports 100% MISSING/EXTRA -- measured, not guessed (the first run of this
// tool did exactly that).
static std::string fileOf(const any* o) {
    if (!o) return "-";
    for (const any* p = o; p; p = p->VpiParent()) {
        std::string f(p->VpiFile());
        if (f.empty()) continue;
        auto sl = f.rfind('/');
        return sl == std::string::npos ? f : f.substr(sl + 1);
    }
    return "";
}
static std::string viewOf(const any* o, const std::map<const any*, std::string>& mv) {
    const any* last = o;
    int guard = 0;
    for (const any* p = o; p && guard < 60; p = p->VpiParent(), guard++) {
        if (p->UhdmType() == uhdmdesign) break;
        last = p;
        auto it = mv.find(p);
        if (it != mv.end()) return it->second;
    }
    auto it = mv.find(last);
    return it == mv.end() ? "OTHER" : it->second;
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: r10buvm14cen <file.uhdm> [tag]\n"; return 2; }
    std::string tag = argc > 2 ? argv[2] : "T";
    Serializer s;
    const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
    if (restored.empty()) { std::cout << "RESTORE_FAIL " << tag << "\n"; return 3; }

    std::map<const any*, std::string> mv;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o || o->UhdmType() != uhdmdesign) continue;
        auto* d = (const design*)o;
        if (auto* v = d->TopPackages()) for (auto* p : *v) mv[p] = "ELAB";
        if (auto* v = d->TopModules()) for (auto* p : *v) mv[p] = "ELAB";
        if (auto* v = d->AllPackages()) for (auto* p : *v) if (!mv.count(p)) mv[p] = "DEF";
        if (auto* v = d->AllModules()) for (auto* p : *v) if (!mv.count(p)) mv[p] = "DEF";
        if (auto* v = d->AllClasses()) for (auto* p : *v) if (!mv.count(p)) mv[p] = "DEF";
    }

    long nhp = 0, nmc = 0;
    std::vector<std::string> rows;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o || o->UhdmType() != uhdmhier_path) continue;
        auto* hp = (const hier_path*)o;
        nhp++;
        auto* els = hp->Path_elems();
        std::string shape;
        int n = 0, nsel = 0, args = -1, mc = 0;
        if (els) {
            for (auto* e : *els) {
                if (!shape.empty()) shape += "|";
                if (!e) { shape += "<null>"; n++; continue; }
                UHDM_OBJECT_TYPE t = e->UhdmType();
                shape += std::string(UhdmName(t)) + "(" + nm(e) + ")[" + full(e) + "]";
                if (t == uhdmbit_select || t == uhdmpart_select ||
                    t == uhdmindexed_part_select || t == uhdmvar_select)
                    nsel++;
                n++;
            }
            if (!els->empty() && els->back() &&
                els->back()->UhdmType() == uhdmmethod_func_call) {
                mc = 1; nmc++;
                auto* a = ((const method_func_call*)els->back())->Tf_call_args();
                args = a ? (int)a->size() : 0;
            }
        }
        rows.push_back("HP " + tag + " key=" + fileOf(o) +
                       "|" + loc(o) + " name=" + nm(o) +
                       " n=" + std::to_string(n) +
                       " mc=" + std::to_string(mc) +
                       " nsel=" + std::to_string(nsel) +
                       " args=" + std::to_string(args) +
                       " shape=" + (shape.empty() ? "<none>" : shape));
    }
    for (auto& r : rows) std::cout << r << "\n";
    std::cout << "SUMMARY " << tag << " hier_paths=" << nhp << " mc=" << nmc << "\n";
    return 0;
}
