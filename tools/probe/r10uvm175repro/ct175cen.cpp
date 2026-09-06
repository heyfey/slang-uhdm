// r10uvm175 — THE HIER_PATH ELEMENT-SHAPE CENSUS.  MEASUREMENT ONLY; the
// official ~/git-repos/UHDM/build/bin/uhdm-cmp is the sole judge.  LHS is
// ALWAYS golden (Surelog), RHS is ALWAYS ours.
//
// ONE ROW per `hier_path` object:
//
//     KEY   L<line>:<col>|<path VpiName>
//     VALUE the ORDERED element vector, one entry per Path_elems slot:
//           <kind>|<VpiName>|<start-end>|idx=<kind>@<span>^<parent kind>
//
// WHY THIS KEY.  The law under measurement changes ONLY the ELEMENTS of a path
// (a text-subscripted `ref_obj` becomes a `bit_select` named for the base, with
// a `vpiIndex` child and a span that stops at the `[`).  It never changes the
// path's own VpiName — that name is composed from the written text on both
// sides and by both producers — and never moves where the path STARTS.  So the
// key is invariant under the law BY CONSTRUCTION and the whole moving part is
// on the value side; a key carrying an element shape could not see a cell move
// (RESUME.md §9).  The path's END column is deliberately out of the key: the
// `with`-clause span is a live field of a neighbouring law.
//
// The home chain is EVIDENCE, never a key — the two producers label the
// DEF / elaborated / wildcard-import copies of one body differently, so a home
// in the key would join nothing; the copies show up as the key's MULTIPLICITY
// instead, and the scorer compares the SET of vectors at a key, never the
// multiplicity (r10uvm170 residue R6).
//
// build: g++ -O2 -std=c++17 ct175cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct175cen
// usage: ct175cen <db.uhdm> [--pred]
//   --pred  THE A-PRIORI MOVER SUPERSET, computable from ONE PRISTINE database
//           alone: every `hier_path` whose LAST element is a
//           `method_func_call` carrying a `vpiWith` (that IS the array-locator
//           `with` form — Surelog and we both put the clause there) and which
//           holds at least one `ref_obj` element whose VpiName carries a `[`,
//           with the first element NOT `this`/`super`.  The law additionally
//           needs slang's bound receiver to agree with the written text
//           component for component (`builtinRecvStepSelectors74`), which this
//           tool cannot see, so this is deliberately a SUPERSET: a database
//           printing nothing here CANNOT move.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <map>
#include <string>
#include <vector>

using namespace UHDM;

static std::string kn(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("<null>");
}
static std::string nm(const BaseClass* o) {
    return o ? std::string(o->VpiName()) : std::string("<null>");
}
static std::string span(const BaseClass* o) {
    if (!o) return "-";
    char b[64];
    snprintf(b, sizeof b, "%u:%u-%u:%u", (unsigned)o->VpiLineNo(),
             (unsigned)o->VpiColumnNo(), (unsigned)o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo());
    return b;
}
static const BaseClass* indexOf(const BaseClass* e) {
    if (!e) return nullptr;
    if (e->UhdmType() == uhdmbit_select)
        return any_cast<const bit_select*>(e)->VpiIndex();
    return nullptr;
}
static std::string elemShape(const BaseClass* e) {
    std::string s = kn(e) + "|" + nm(e) + "|" + span(e) + "|idx=";
    const BaseClass* ix = indexOf(e);
    if (!ix)
        s += "-";
    else
        s += kn(ix) + "@" + span(ix) + "^" + kn(ix->VpiParent());
    return s;
}
static std::string homeChain(const BaseClass* o) {
    std::string s;
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
        const UHDM_OBJECT_TYPE t = p->UhdmType();
        if (t != uhdmpackage && t != uhdmclass_defn && t != uhdmmodule_inst &&
            t != uhdmfunction && t != uhdmtask)
            continue;
        s += "<" + kn(p) + ":" + nm(p);
    }
    return s;
}

int main(int argc, char** argv) {
    if (argc < 2) {
        fprintf(stderr, "usage: ct175cen <db.uhdm> [--pred]\n");
        return 2;
    }
    const bool predMode = (argc > 2 && strcmp(argv[2], "--pred") == 0);
    // --wface: the LAW'S FACE, counted.  Every `hier_path` whose last element
    // is a `method_func_call` carrying a `vpiWith` is classified by what its
    // NON-LAST elements look like: SUBSCRIPTED-REFOBJ (a `ref_obj` whose
    // VpiName carries a `[`), BITSEL (a `bit_select`), or PLAIN.  Run on a
    // GOLDEN database it measures Surelog's rule; run on ours it measures the
    // defect.  A path can hold both, and is then counted in both buckets.
    const bool wface = (argc > 2 && strcmp(argv[2], "--wface") == 0);
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) {
        printf("RESTORE_FAIL\n");
        return 3;
    }
    std::vector<std::string> out;
    long wPaths = 0, wSub = 0, wBit = 0, wPlain = 0, wThis = 0;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* X = kv.first;
        if (!X || X->UhdmType() != uhdmhier_path) continue;
        const hier_path* hp = any_cast<const hier_path*>(X);
        const VectorOfany* els = hp->Path_elems();
        if (!els || els->empty()) continue;
        if (wface) {
            const BaseClass* last = els->back();
            if (!last || last->UhdmType() != uhdmmethod_func_call) continue;
            if (!any_cast<const method_func_call*>(last)->With()) continue;
            wPaths++;
            const std::string first = nm(els->front());
            if (first == "this" || first == "super") { wThis++; continue; }
            bool sub = false, bit = false;
            for (size_t i = 0; i + 1 < els->size(); i++) {
                const BaseClass* e = els->at(i);
                if (!e) continue;
                if (e->UhdmType() == uhdmbit_select) bit = true;
                else if (e->UhdmType() == uhdmref_obj &&
                         nm(e).find('[') != std::string::npos)
                    sub = true;
            }
            if (sub) wSub++;
            if (bit) wBit++;
            if (!sub && !bit) wPlain++;
            continue;
        }
        if (predMode) {
            const BaseClass* last = els->back();
            if (!last || last->UhdmType() != uhdmmethod_func_call) continue;
            if (!any_cast<const method_func_call*>(last)->With()) continue;
            const std::string first = nm(els->front());
            if (first == "this" || first == "super") continue;
            int cand = 0;
            for (const BaseClass* e : *els)
                if (e && e->UhdmType() == uhdmref_obj &&
                    nm(e).find('[') != std::string::npos)
                    cand++;
            if (!cand) continue;
            char b[1200];
            snprintf(b, sizeof b, "PRED L%u:%u path=%s cand=%d",
                     (unsigned)hp->VpiLineNo(), (unsigned)hp->VpiColumnNo(),
                     nm(hp).c_str(), cand);
            out.push_back(b);
            continue;
        }
        std::string v;
        for (size_t i = 0; i < els->size(); i++) {
            if (i) v += ";";
            v += elemShape(els->at(i));
        }
        char b[240];
        snprintf(b, sizeof b, "L%u:%u|", (unsigned)hp->VpiLineNo(),
                 (unsigned)hp->VpiColumnNo());
        out.push_back(std::string(b) + nm(hp) + "\t" + v + "\thome=" +
                      homeChain(hp));
    }
    if (wface) {
        printf("-- WFACE withpaths=%ld this_super=%ld SUBSCRIPTED-REFOBJ=%ld "
               "BITSEL=%ld PLAIN=%ld\n",
               wPaths, wThis, wSub, wBit, wPlain);
        return 0;
    }
    std::sort(out.begin(), out.end());
    if (predMode) {
        out.erase(std::unique(out.begin(), out.end()), out.end());
        for (const std::string& r : out) printf("%s\n", r.c_str());
        printf("-- PRED cells=%zu\n", out.size());
        return 0;
    }
    for (const std::string& r : out) printf("%s\n", r.c_str());
    return 0;
}
