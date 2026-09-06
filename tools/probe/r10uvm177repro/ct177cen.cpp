// r10uvm177 — THE RETURN-VARIABLE CENSUS.  MEASUREMENT ONLY; the official
// `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.  LHS is ALWAYS
// golden (Surelog); RHS is ALWAYS ours.
//
// One row per FUNCTION RETURN POSITION.  A position is
//   (listing, home, function name, line, start column)
// where
//   * LISTING is read STRUCTURALLY so both producers answer it identically:
//     walk the parent chain and stop at the first ancestor that is a member of
//     `design->AllPackages` (PKGDEF), `TopPackages` (PKGELAB), `AllModules`
//     (MODDEF), `TopModules` (MODELAB) or `AllClasses` (CLASSDEF).
//   * HOME records whether the walk crossed a `class_defn` (CLASSBODY vs
//     PKGLIST) and whether the function's own VpiName carries `::`
//     (Surelog's spelling for the OUT-OF-BODY definition clone that
//     `UhdmWriter::writePackage` leaves in the package's Task_funcs).
//
// The VALUE is the return variable's KIND and its typespec target's
// KIND / NAME (and, separately, its SPAN — printed but kept OUT of the join
// key on request, because `uhdm-cmp` reads no span).
//
// build: g++ -O2 -std=c++17 ct177cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct177cen
// usage: ct177cen <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <map>
#include <set>
#include <string>
#include <tuple>
#include <vector>

using namespace UHDM;

static const design* topDesign(Serializer& s) {
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign)
            return (const design*)kv.first;
    return nullptr;
}

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct177cen <db.uhdm>\n"); return 2; }
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
    const design* d = topDesign(s);
    if (!d) { printf("NO_DESIGN\n"); return 3; }

    std::map<const BaseClass*, std::string> tag;
    if (auto* v = d->AllPackages())
        for (auto* o : *v) tag[o] = "PKGDEF:" + std::string(o->VpiName());
    if (auto* v = d->TopPackages())
        for (auto* o : *v) tag[o] = "PKGELAB:" + std::string(o->VpiName());
    if (auto* v = d->AllModules())
        for (auto* o : *v) tag[o] = "MODDEF:" + std::string(o->VpiDefName());
    if (auto* v = d->TopModules())
        for (auto* o : *v) tag[o] = "MODELAB:" + std::string(o->VpiDefName());
    if (auto* v = d->AllClasses())
        for (auto* o : *v) tag[o] = "CLASSDEF:" + std::string(o->VpiName());

    std::vector<std::string> rows;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdmfunction) continue;
        const function* f = (const function*)o;
        const variables* rv = f->Return();
        if (!rv) continue;

        std::string listing = "-";
        bool crossedClass = false;
        std::string clsName;
        int g = 0;
        for (const BaseClass* p = o->VpiParent(); p && g < 128;
             p = p->VpiParent(), ++g) {
            auto it = tag.find(p);
            if (it != tag.end()) { listing = it->second; break; }
            if (p->UhdmType() == uhdmclass_defn) {
                if (!crossedClass) clsName = p->VpiName();
                crossedClass = true;
            }
        }
        std::string fname(f->VpiName());
        bool oob = fname.find("::") != std::string::npos;
        std::string home = std::string(crossedClass ? "CLASSBODY:" : "PKGLIST:") +
                           (crossedClass ? clsName : std::string("-")) +
                           (oob ? "|OOBNAME" : "|BARENAME");

        std::string tsk = "<nots>";
        std::string tsn = "-";
        char tspan[64] = "-";
        const ref_typespec* rt = rv->Typespec();
        if (rt) {
            if (const typespec* at = rt->Actual_typespec()) {
                tsk = std::string(UhdmName(at->UhdmType()));
                tsn = at->VpiName();
                snprintf(tspan, sizeof tspan, "%u:%u-%u:%u", at->VpiLineNo(),
                         (unsigned)at->VpiColumnNo(), at->VpiEndLineNo(),
                         (unsigned)at->VpiEndColumnNo());
            } else {
                tsk = "<refnull>";
            }
        }
        char b[2400];
        snprintf(b, sizeof b, "%s\t%s\t%s\t%u:%u\t%s\t%s\t%s\t%s\t%s",
                 listing.c_str(), home.c_str(), fname.c_str(), rv->VpiLineNo(),
                 (unsigned)rv->VpiColumnNo(),
                 std::string(UhdmName(rv->UhdmType())).c_str(),
                 std::string(rv->VpiName()).c_str(), tsk.c_str(), tsn.c_str(),
                 tspan);
        rows.push_back(b);
    }
    std::sort(rows.begin(), rows.end());
    printf("#LISTING\tHOME\tFN\tRVPOS\tRVKIND\tRVNAME\tTSKIND\tTSNAME\tTSSPAN\n");
    for (auto& r : rows) printf("%s\n", r.c_str());
    fprintf(stderr, "ROWS=%zu\n", rows.size());
    return 0;
}
