// r10uvm159 — CONSTANT-TYPESPEC MULTISET JOIN (golden vs ours), one DB pair.
// MEASUREMENT ONLY: ~/git-repos/UHDM/build/bin/uhdm-cmp is the sole judge.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// The judge reads a constant as (BaseClass) VpiType/VpiName/VpiDefName, then
// (expr) VpiDecompile, VpiSize, Typespec, then (constant) VpiConstType.  So
// the census key is exactly the COMPARE-VISIBLE payload plus the span (which
// the judge does NOT read but which identifies the cell), and the census VALUE
// is the typespec edge.
//
//   key   = <line>:<col>-<endline>:<endcol>|ct|size|dec|value
//   value = NONE | <actual-typespec-kind>[<actual name>]{refname}
//
// vpiParent is deliberately NOT in the key: Surelog parents a SUBSTITUTED
// parameter clone at the DECLARING param_assign while we parent it at the
// expression that uses it, and no generated Compare reads VpiParent.
//
// build: g++ -O2 -std=c++17 ct159join.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct159join
// usage: ct159join <golden.uhdm> <ours.uhdm> --tag=NAME [--list] [--all]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <algorithm>
#include <map>
#include <string>
#include <vector>
using namespace UHDM;
static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("-");
}
static std::string nm(const BaseClass* o) {
    if (!o) return "";
    return std::string(o->VpiName());
}
static std::string homeOf(const BaseClass* o) {
    for (int i = 0; i < 64 && o; ++i) {
        switch (o->UhdmType()) {
            case uhdmpackage: return "pkg:" + nm(o);
            case uhdmclass_defn: return "cls:" + nm(o);
            case uhdmmodule_inst:
            case uhdmprogram: return "mod:" + std::string(o->VpiDefName());
            case uhdminterface_inst: return "iface";
            case uhdmdesign: return "TOP";
            default: break;
        }
        o = o->VpiParent();
    }
    return "TOP";
}
struct Cell { std::string ts, par, own, home; };
static void collect(const char* path, std::map<std::string, std::vector<Cell>>& out,
                    size_t& total, size_t& withTs) {
    Serializer s;
    if (s.Restore(std::string(path)).empty()) { fprintf(stderr, "restore failed %s\n", path); exit(3); }
    total = withTs = 0;
    for (const auto& [obj, i] : s.AllObjects()) {
        if (!obj || obj->UhdmType() != uhdmconstant) continue;
        const constant* c = (const constant*)obj;
        total++;
        char k[900];
        snprintf(k, sizeof k, "%u:%u-%u:%u|ct%d|sz%d|%s|%s", c->VpiLineNo(),
                 (unsigned)c->VpiColumnNo(), c->VpiEndLineNo(), (unsigned)c->VpiEndColumnNo(),
                 c->VpiConstType(), c->VpiSize(),
                 std::string(c->VpiDecompile()).c_str(), std::string(c->VpiValue()).c_str());
        Cell cell;
        const ref_typespec* rt = c->Typespec();
        if (rt) {
            withTs++;
            const typespec* a = rt->Actual_typespec();
            char b[600];
            snprintf(b, sizeof b, "%s[%s]{%s}@%u:%u-%u:%u", kindOf(a).c_str(), nm(a).c_str(),
                     nm(rt).c_str(), a ? a->VpiLineNo() : 0u, a ? (unsigned)a->VpiColumnNo() : 0u,
                     a ? a->VpiEndLineNo() : 0u, a ? (unsigned)a->VpiEndColumnNo() : 0u);
            cell.ts = b;
        } else cell.ts = "NONE";
        cell.par = kindOf(c->VpiParent());
        cell.home = homeOf(c->VpiParent());
        out[k].push_back(cell);
    }
}
int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct159join <golden> <ours> [--tag=T] [--list]\n"); return 2; }
    std::string tag = "PAIR"; bool list = false, all = false;
    for (int a = 3; a < argc; a++) {
        if (!strncmp(argv[a], "--tag=", 6)) tag = argv[a] + 6;
        else if (!strcmp(argv[a], "--list")) list = true;
        else if (!strcmp(argv[a], "--all")) all = true;
    }
    std::map<std::string, std::vector<Cell>> G, O;
    size_t gt = 0, gw = 0, ot = 0, ow = 0;
    collect(argv[1], G, gt, gw);
    collect(argv[2], O, ot, ow);
    size_t onlyG = 0, onlyO = 0, same = 0;
    size_t missOurs = 0, extraOurs = 0, kindDiff = 0, countDiff = 0;
    for (auto& [k, gv] : G) {
        auto it = O.find(k);
        if (it == O.end()) { onlyG += gv.size(); continue; }
        std::vector<std::string> a, b;
        for (auto& c : gv) a.push_back(c.ts);
        for (auto& c : it->second) b.push_back(c.ts);
        std::sort(a.begin(), a.end()); std::sort(b.begin(), b.end());
        if (a == b) { same += a.size(); continue; }
        size_t gn = 0, on = 0;
        for (auto& x : a) if (x != "NONE") gn++;
        for (auto& x : b) if (x != "NONE") on++;
        // CLASSIFY BY THE TYPESPEC POPULATION, NOT BY THE CELL SIZE: a cell
        // whose multiplicity differs for an UNRELATED reason (a duplicated
        // listing elsewhere in the campaign) still has a well-defined
        // "how many of these constants carry a typespec" on each side.
        const char* cls;
        if (gn > on) { cls = "MISSING-OURS"; missOurs += (gn - on); }
        else if (on > gn) { cls = "EXTRA-OURS"; extraOurs += (on - gn); }
        else if (a.size() != b.size()) { cls = "COUNTDIFF"; countDiff++; }
        else { cls = "KINDDIFF"; kindDiff++; }
        if (list || all) {
            printf("%s CELL %s %s home=%s gpar=%s opar=%s\n", tag.c_str(), cls, k.c_str(),
                   gv[0].home.c_str(), gv[0].par.c_str(), it->second[0].par.c_str());
            for (auto& x : a) printf("%s    G %s\n", tag.c_str(), x.c_str());
            for (auto& x : b) printf("%s    O %s\n", tag.c_str(), x.c_str());
        }
    }
    size_t onlyGts = 0, onlyOts = 0;
    for (auto& [k, gv] : G) if (O.find(k) == O.end())
        for (auto& c : gv) if (c.ts != "NONE") onlyGts++;
    for (auto& [k, ov] : O) {
        if (G.find(k) != G.end()) continue;
        onlyO += ov.size();
        for (auto& c : ov) if (c.ts != "NONE") onlyOts++;
    }
    printf("%s SUM gconst=%zu gts=%zu oconst=%zu ots=%zu same=%zu onlyG=%zu onlyO=%zu "
           "MISSING-OURS=%zu EXTRA-OURS=%zu KINDDIFF=%zu COUNTDIFF=%zu "
           "onlyGts=%zu onlyOts=%zu\n",
           tag.c_str(), gt, gw, ot, ow, same, onlyG, onlyO, missOurs, extraOurs, kindDiff,
           countDiff, onlyGts, onlyOts);
    return 0;
}
