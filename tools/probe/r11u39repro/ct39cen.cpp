// r11u39 — THE HIER_PATH ELEMENT-SHAPE CENSUS and MOVER PREDICTOR.
// MEASUREMENT ONLY; `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole
// acceptance judge.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// THE CELL.  One `hier_path`, keyed by (view, VpiName) and PAYLOADED with the
// COMPARE-VISIBLE face of its `Path_elems`: for every element, its UHDM kind,
// its `VpiName` (empty prints as `-`) and the NUMBER OF INDEX EXPRESSIONS it
// carries (`bit_select::VpiIndex` is 0 or 1, `var_select::Exprs` is the vector
// size).  `hier_path::Compare` walks `Path_elems` through the VECTOR overload,
// so a CARDINALITY difference sets both containers and every element's own
// generated Compare reads VpiType / VpiName / VpiDefName plus its per-kind
// fields -- never VpiFullName, VpiFile, line or column.  The payload therefore
// carries exactly what the judge can see and nothing it cannot.
//
// TWO MODES.
//
//   --pred <ours.uhdm> <rowtag>
//       OURS-ONLY, so it runs on every database our binary produces, golden or
//       no golden.  It classifies every hier_path against the two SHAPES this
//       pass's law replaces, both read off the pristine database alone:
//
//         COMPOSITE  an element whose own VpiName carries a `[` -- the
//                    signature of the DOTTED-PATH arm, which flattens a whole
//                    written select run into ONE ref_obj named `a[i][j]` plus
//                    one bit_select named `m[k]`.  This is the shape the new
//                    ROUTING removes.
//         DROPPED    the hier_path's VpiName spells MORE bracket groups than
//                    its Path_elems carry index expressions -- the signature
//                    of a component select run whose steps past the first were
//                    thrown away.  This is the shape the new MID branch fixes.
//         ERASED     a path with NO index-carrying element at all although its
//                    name spells brackets (§ thisPathSelectErased4's deliberate
//                    erasure and friends); reported SEPARATELY so it is never
//                    counted as a predicted mover.
//         OK         everything else.
//
//       A database with a COMPOSITE or DROPPED cell is a PREDICTED MOVER, by
//       name.  A database with none must not move.
//
//   --cen <golden.uhdm> <ours.uhdm> <rowtag>
//       THE COMPARE-VISIBLE CENSUS.  Cells are joined as MULTISETS on
//       (view, hier_path VpiName) with the element-shape string as the payload,
//       so a shape disagreement prints as a SHAPE row rather than as two
//       one-sided keys; keys present on one side only print as GOLDEN-ONLY /
//       OURS-ONLY.  Run it golden-vs-golden FIRST: it must read 0 SHAPE rows.
//
// VIEW comes from the design's own listings (AllModules/AllPackages are the
// DEFINITION listings, TopModules/TopPackages the ELABORATED ones), never
// guessed from a name; an object reachable from neither is `other`.
//
// build: g++ -O2 -std=c++17 ct39cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct39cen
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstring>
#include <map>
#include <string>
#include <vector>

using namespace UHDM;

// ---------------------------------------------------------------- view map
static void viewMap(Serializer& s, std::map<const BaseClass*, std::string>& v) {
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdmdesign) continue;
        const design* d = (const design*)o;
        if (d->AllModules())    for (auto* x : *d->AllModules())    v[x] = "def";
        if (d->TopModules())    for (auto* x : *d->TopModules())    v[x] = "elab";
        if (d->AllPackages())   for (auto* x : *d->AllPackages())   v[x] = "defpkg";
        if (d->TopPackages())   for (auto* x : *d->TopPackages())   v[x] = "elabpkg";
        if (d->AllInterfaces()) for (auto* x : *d->AllInterfaces()) v[x] = "defif";
        if (d->AllPrograms())   for (auto* x : *d->AllPrograms())   v[x] = "defprog";
    }
}
// Walk up the parent chain to the nearest object the view map knows.  The view
// is NOT part of any key (the two producers label the same object differently
// often enough that it would manufacture one-sided rows); it is printed beside
// the cell so a reader can see where it sits.
static std::string viewOf(const std::map<const BaseClass*, std::string>& v,
                          const BaseClass* o) {
    for (int i = 0; o && i < 64; ++i) {
        auto it = v.find(o);
        if (it != v.end()) return it->second;
        o = o->VpiParent();
    }
    return "other";
}

// ------------------------------------------------- the judge-visible payload
static int idxCount(const any* e) {
    switch (e->UhdmType()) {
        case uhdmbit_select:
            return ((const bit_select*)e)->VpiIndex() ? 1 : 0;
        case uhdmvar_select: {
            auto* x = ((const var_select*)e)->Exprs();
            return x ? (int)x->size() : 0;
        }
        case uhdmpart_select:
        case uhdmindexed_part_select:
            return 1;
        default:
            return 0;
    }
}
static std::string shapeOf(const hier_path* hp) {
    std::string out;
    auto* es = hp->Path_elems();
    if (!es) return "<no-elems>";
    for (auto* e : *es) {
        if (!out.empty()) out += " + ";
        const std::string nm = std::string(e->VpiName());
        char b[512];
        snprintf(b, sizeof b, "%s[%s]/%d", UhdmName(e->UhdmType()).data(),
                 nm.empty() ? "-" : nm.c_str(), idxCount(e));
        out += b;
    }
    return out;
}
// Count the BRACKET GROUPS the path's own written name spells.  Nested
// brackets (`a[[i]]`, the decompiled select-index form) count ONCE: only
// depth-0 openers are counted.
static int bracketGroups(const std::string& n) {
    int d = 0, c = 0;
    for (char ch : n) {
        if (ch == '[') { if (d == 0) ++c; ++d; }
        else if (ch == ']' && d) --d;
    }
    return c;
}
static int elemIdx(const hier_path* hp) {
    int n = 0;
    if (auto* es = hp->Path_elems())
        for (auto* e : *es) n += idxCount(e);
    return n;
}
static bool anyBracketName(const hier_path* hp) {
    if (auto* es = hp->Path_elems())
        for (auto* e : *es)
            if (std::string(e->VpiName()).find('[') != std::string::npos)
                return true;
    return false;
}

static void collect(Serializer& s,
                    std::vector<std::pair<std::string, const hier_path*>>& out,
                    std::map<const BaseClass*, std::string>& v) {
    viewMap(s, v);
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdmhier_path) continue;
        out.emplace_back(viewOf(v, o), (const hier_path*)o);
    }
}

static int predMode(const char* db, const char* tag) {
    Serializer s;
    if (s.Restore(std::string(db)).empty()) {
        printf("PRED-RESTORE_FAIL %s\n", tag);
        return 3;
    }
    std::map<const BaseClass*, std::string> v;
    std::vector<std::pair<std::string, const hier_path*>> hps;
    collect(s, hps, v);
    int nComposite = 0, nDropped = 0, nErased = 0, nOk = 0;
    for (auto& [vw, hp] : hps) {
        const std::string nm(hp->VpiName());
        const int bg = bracketGroups(nm), ix = elemIdx(hp);
        const char* cls;
        if (anyBracketName(hp)) { cls = "COMPOSITE"; ++nComposite; }
        else if (bg > ix && ix == 0) { cls = "ERASED"; ++nErased; }
        else if (bg > ix) { cls = "DROPPED"; ++nDropped; }
        else { cls = "OK"; ++nOk; }
        if (strcmp(cls, "OK") != 0)
            printf("PRED %s %s %-9s view=%-7s brackets=%d idx=%d name=%s || %s\n",
                   tag, cls, "", vw.c_str(), bg, ix, nm.c_str(),
                   shapeOf(hp).c_str());
    }
    printf("PREDSUM %s composite=%d dropped=%d erased=%d ok=%d total=%d %s\n",
           tag, nComposite, nDropped, nErased, nOk, (int)hps.size(),
           (nComposite + nDropped) ? "MOVER-PREDICTED" : "NO-MOVE-PREDICTED");
    return 0;
}

// SHAPE LISTER — every hier_path of one database, printed beside the census so
// a census ZERO is never read without the shapes it counted.
static int listMode(const char* db, const char* tag) {
    Serializer s;
    if (s.Restore(std::string(db)).empty()) {
        printf("LIST-RESTORE_FAIL %s\n", tag);
        return 3;
    }
    std::map<const BaseClass*, std::string> v;
    std::vector<std::pair<std::string, const hier_path*>> hps;
    collect(s, hps, v);
    std::multimap<std::string, std::string> rows;
    for (auto& [vw, hp] : hps)
        rows.emplace(std::string(hp->VpiName()), vw + " || " + shapeOf(hp));
    for (auto& r : rows)
        printf("LIST %s %-46s %s\n", tag, r.first.c_str(), r.second.c_str());
    printf("LISTSUM %s paths=%d\n", tag, (int)hps.size());
    return 0;
}

static int cenMode(const char* gdb, const char* odb, const char* tag) {
    Serializer sg, so;
    if (sg.Restore(std::string(gdb)).empty()) {
        printf("CEN-RESTORE_FAIL golden %s\n", tag);
        return 3;
    }
    if (so.Restore(std::string(odb)).empty()) {
        printf("CEN-RESTORE_FAIL ours %s\n", tag);
        return 3;
    }
    std::map<const BaseClass*, std::string> vg, vo;
    std::vector<std::pair<std::string, const hier_path*>> hg, ho;
    collect(sg, hg, vg);
    collect(so, ho, vo);
    // MULTISET join on the NAME; the shape is the payload.  A last-writer dict
    // would silently drop the repeated names (a gen-block body has one path per
    // unrolled instance), so both sides are counted per (name, shape).
    std::map<std::string, std::map<std::string, int>> G, O;
    for (auto& [vw, hp] : hg) G[std::string(hp->VpiName())][shapeOf(hp)]++;
    for (auto& [vw, hp] : ho) O[std::string(hp->VpiName())][shapeOf(hp)]++;
    int shape = 0, gonly = 0, oonly = 0, same = 0;
    for (auto& [nm, gm] : G) {
        auto it = O.find(nm);
        if (it == O.end()) {
            for (auto& [sh, c] : gm) { gonly += c;
                printf("CEN %s GOLDEN-ONLY n=%d name=%s || %s\n", tag, c, nm.c_str(), sh.c_str()); }
            continue;
        }
        for (auto& [sh, c] : gm) {
            int oc = it->second.count(sh) ? it->second[sh] : 0;
            if (oc == c) { same += c; continue; }
            shape += (c > oc ? c - oc : oc - c);
            printf("CEN %s SHAPE g=%d o=%d name=%s || GOLDEN %s\n", tag, c, oc, nm.c_str(), sh.c_str());
        }
        for (auto& [sh, c] : it->second)
            if (!gm.count(sh))
                printf("CEN %s SHAPE g=0 o=%d name=%s || OURS   %s\n", tag, c, nm.c_str(), sh.c_str());
    }
    for (auto& [nm, om] : O)
        if (!G.count(nm))
            for (auto& [sh, c] : om) { oonly += c;
                printf("CEN %s OURS-ONLY n=%d name=%s || %s\n", tag, c, nm.c_str(), sh.c_str()); }
    printf("CENSUM %s shape=%d golden_only=%d ours_only=%d agree=%d gpaths=%d opaths=%d\n",
           tag, shape, gonly, oonly, same, (int)hg.size(), (int)ho.size());
    return 0;
}

int main(int argc, char** argv) {
    if (argc >= 4 && !strcmp(argv[1], "--pred")) return predMode(argv[2], argv[3]);
    if (argc >= 4 && !strcmp(argv[1], "--list")) return listMode(argv[2], argv[3]);
    if (argc >= 5 && !strcmp(argv[1], "--cen")) return cenMode(argv[2], argv[3], argv[4]);
    fprintf(stderr,
            "usage: ct39cen --pred <ours.uhdm> <tag>\n"
            "       ct39cen --list <db.uhdm> <tag>\n"
            "       ct39cen --cen  <golden.uhdm> <ours.uhdm> <tag>\n");
    return 2;
}
