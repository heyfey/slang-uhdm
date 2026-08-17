// r10buvm11cen — THE CENSUS INSTRUMENT for the array_var ELEMENT-RANGE family.
//
// MEASUREMENT ONLY.  The official uhdm-cmp is the acceptance judge.
// LHS is ALWAYS golden; this tool reads ONE database and tags its rows, so the
// caller joins golden rows against ours.
//
// Reads a .uhdm and prints, out of Serializer::AllObjects() (never dump TEXT),
// one row per array_var / packed_array_var:
//
//   AV <tag> key=<parent-chain kinds+names>::<name>@<line:col> at=<vpiArrayType>
//      size=<vpiSize> avR=<n> avM=<dim marker shape> nv=<#Variables>
//      ek=<element kind> ets=<element typespec kind:name> evR=<n>
//      shared=<0|1|-> evM=<element range marker shape>
//
// `avM` / `evM` spell each range's Right_expr constant value: `f` = a folded
// fixed bound, `A` = STRING:associative, `Q` = STRING:$, `U` = STRING:unsized,
// `?` = anything else.  `shared` is 1 when EVERY range object on the element is
// the SAME OBJECT as the array_var's range at the same index (Surelog hands the
// element var the array's own vector, so identity — not equality — is the fact).
//
// usage: r10buvm11cen <file.uhdm> [tag]
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
    return n.empty() ? "<anon>" : n;
}
static std::string loc(const any* o) {
    if (!o) return "-";
    return std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo());
}
static std::string chainOf(const any* o) {
    std::string r;
    int guard = 0;
    for (const any* p = o ? o->VpiParent() : nullptr; p && guard < 12;
         p = p->VpiParent(), guard++) {
        if (!r.empty()) r += "<";
        r += std::string(UhdmName(p->UhdmType())) + "(" + nm(p) + ")";
    }
    return r.empty() ? "-" : r;
}
// Ranges live on four classes only (array_var / bit_var / logic_var /
// packed_array_var); every other variables kind has none, which is itself a
// measured fact and not an omission.
static const VectorOfrange* rangesOf(const any* o) {
    if (!o) return nullptr;
    switch (o->UhdmType()) {
        case uhdmarray_var: return ((const array_var*)o)->Ranges();
        case uhdmbit_var: return ((const bit_var*)o)->Ranges();
        case uhdmlogic_var: return ((const logic_var*)o)->Ranges();
        case uhdmpacked_array_var: return ((const packed_array_var*)o)->Ranges();
        default: return nullptr;
    }
}
static std::string markerOf(const VectorOfrange* v) {
    if (!v) return "-";
    if (v->empty()) return "()";
    std::string r;
    for (auto* rg : *v) {
        const expr* re = rg ? rg->Right_expr() : nullptr;
        if (!re) { r += '?'; continue; }
        if (re->UhdmType() != uhdmconstant) { r += 'e'; continue; }
        std::string val(((const constant*)re)->VpiValue());
        if (val == "STRING:associative") r += 'A';
        else if (val == "STRING:$") r += 'Q';
        else if (val == "STRING:unsized") r += 'U';
        else if (val.rfind("UINT:", 0) == 0 || val.rfind("INT:", 0) == 0) r += 'f';
        else r += '?';
    }
    return r;
}
static std::string tsOf(const any* v) {
    const ref_typespec* rt = nullptr;
    if (auto* vv = dynamic_cast<const variables*>(v)) rt = vv->Typespec();
    if (!rt) return "-";
    auto* at = rt->Actual_typespec();
    if (!at) return "<unlinked>";
    return std::string(UhdmName(at->UhdmType())) + ":" + nm(at);
}

// The VIEW an object lives in: Surelog writes each package / module / class
// TWICE — once in the design's `All*` listing (the DEF view, un-elaborated) and
// once in `Top*` (the ELAB view).  A key that ignores the split would collide
// the two objects of one declaration, so the view rides in the key.
static std::string viewOf(const any* o, const std::map<const any*, std::string>& mv) {
    const any* last = o;
    int guard = 0;
    for (const any* p = o; p && guard < 24; p = p->VpiParent(), guard++) {
        if (p->UhdmType() == uhdmdesign) break;
        last = p;
        auto it = mv.find(p);
        if (it != mv.end()) return it->second;
    }
    auto it = mv.find(last);
    return it == mv.end() ? "OTHER" : it->second;
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: r10buvm11cen <file.uhdm> [tag]\n"; return 2; }
    std::string tag = argc > 2 ? argv[2] : "T";
    Serializer s;
    const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
    if (restored.empty()) { std::cout << "RESTORE_FAIL " << tag << "\n"; return 3; }

    // ELAB / DEF membership, read off the design's own listings.
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

    long nav = 0, nelem = 0, nshared = 0, nelemr = 0;
    std::vector<std::string> rows;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o) continue;
        if (o->UhdmType() != uhdmarray_var) continue;
        auto* av = (const array_var*)o;
        nav++;
        const VectorOfrange* ar = av->Ranges();
        auto* vars = av->Variables();
        const variables* el = (vars && !vars->empty()) ? vars->at(0) : nullptr;
        const VectorOfrange* er = rangesOf(el);
        std::string shared = "-";
        if (el) {
            nelem++;
            if (er && !er->empty()) nelemr++;
            if (!er) shared = "N";
            else if (!ar) shared = er->empty() ? "0e" : "X";
            else {
                bool same = ar->size() == er->size();
                if (same)
                    for (size_t i = 0; i < ar->size(); i++)
                        if (ar->at(i) != er->at(i)) { same = false; break; }
                shared = same ? (er->empty() ? "0e" : "1") : "X";
                if (same && !er->empty()) nshared++;
            }
        }
        rows.push_back(
            std::string("AV ") + tag + " view=" + viewOf(av, mv) +
            " key=" + chainOf(av) + "::" + nm(av) +
            "@" + loc(av) + " at=" + std::to_string(av->VpiArrayType()) +
            " size=" + std::to_string(av->VpiSize()) +
            " avR=" + std::to_string(ar ? (long)ar->size() : -1) +
            " avM=" + markerOf(ar) +
            " nv=" + std::to_string(vars ? (long)vars->size() : -1) +
            " ek=" + (el ? UhdmName(el->UhdmType()) : "-") +
            " ets=" + (el ? tsOf(el) : "-") +
            " evR=" + std::to_string(er ? (long)er->size() : -1) +
            " shared=" + shared + " evM=" + markerOf(er));
    }
    for (auto& r : rows) std::cout << r << "\n";
    std::cout << "TOTALS " << tag << " array_var=" << nav << " withElem=" << nelem
              << " elemWithRanges=" << nelemr << " elemSharesArrayRanges=" << nshared
              << "\n";
    return 0;
}
