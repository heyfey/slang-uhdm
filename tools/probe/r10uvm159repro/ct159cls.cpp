// r10uvm159 — CLASSIFIED CONSTANT-TYPESPEC JOIN (golden vs ours), one DB pair.
// MEASUREMENT ONLY: ~/git-repos/UHDM/build/bin/uhdm-cmp is the sole judge.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// Same multiset key as ct159join (the COMPARE-VISIBLE payload plus the span),
// but every cell also carries the ORIGIN/OWNER/HOME classification the law is
// scored on:
//
//   own  = kind of the first NON-vpiParent holder (the object that USES the
//          constant).  vpiParent is excluded on purpose: Surelog parents a
//          substituted parameter clone at the DECLARING param_assign while we
//          parent it at the expression that uses it, and no generated Compare
//          reads VpiParent.
//   ctx  = the first enclosing SCOPE walking up from the OWNER:
//          tf / proc / ca / nda / param_assign / gen / other
//   home = pkg:<name> / cls:<name> / mod:<defname> / iface / TOP
//   rhs  = 1 when the constant IS its parent param_assign's Rhs (the parameter
//          DECLARATION's own value object) — a different population from a
//          USE-SITE substitution, and the two must never be pooled.
//
// build: g++ -O2 -std=c++17 ct159cls.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct159cls
// usage: ct159cls <golden.uhdm> <ours.uhdm> [--tag=T] [--list] [--only=CLASS]
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
    return o ? std::string(o->VpiName()) : std::string();
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
static std::string ctxOf(const BaseClass* o) {
    for (int i = 0; i < 64 && o; ++i) {
        switch (o->UhdmType()) {
            case uhdmfunction:
            case uhdmtask: return "tf";
            case uhdmalways:
            case uhdminitial:
            case uhdmfinal_stmt: return "proc";
            case uhdmcont_assign: return "ca";
            case uhdmparam_assign: return "param_assign";
            case uhdmgen_scope: return "gen";
            case uhdmclass_defn: return "clsbody";
            case uhdmpackage:
            case uhdmmodule_inst:
            case uhdmdesign: return "scope";
            default: break;
        }
        o = o->VpiParent();
    }
    return "other";
}
struct Cell { std::string ts, own, ctx, home; int rhs, orphan; };
static void collect(const char* path, std::map<std::string, std::vector<Cell>>& out,
                    size_t& total, size_t& withTs) {
    Serializer s;
    if (s.Restore(std::string(path)).empty()) { fprintf(stderr, "restore failed %s\n", path); exit(3); }
    std::map<const BaseClass*, const BaseClass*> owner;
    for (const auto& [obj, i] : s.AllObjects()) {
        if (!obj) continue;
        for (int t = 1; t < 1100; ++t) {
            if (t == vpiParent) continue;
            auto [single, vt, vec] = obj->GetByVpiType(t);
            if (single && !owner.count(single)) owner[single] = obj;
            if (vec) for (auto* e : *vec) if (e && !owner.count(e)) owner[e] = obj;
        }
    }
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
            snprintf(b, sizeof b, "%s[%s]@%u:%u-%u:%u", kindOf(a).c_str(), nm(a).c_str(),
                     a ? a->VpiLineNo() : 0u, a ? (unsigned)a->VpiColumnNo() : 0u,
                     a ? a->VpiEndLineNo() : 0u, a ? (unsigned)a->VpiEndColumnNo() : 0u);
            cell.ts = b;
        } else cell.ts = "NONE";
        auto oit = owner.find(obj);
        const BaseClass* ow = oit == owner.end() ? nullptr : oit->second;
        // ORPHAN = nothing in the database points at this constant and it has
        // no parent either: the weaklyReferenced TAIL, which is UNREACHABLE to
        // the judge (RESUME.md §9 -- "never count tail stamps").  Surelog's
        // -parse databases are full of them: a class-method expression that
        // golden left as a `ref_obj` still leaves the reduced constant behind
        // as a stray, and scoring it as a golden cell manufactures phantom
        // AWAY-GOLDEN readings for anything we fold there.
        cell.orphan = (!ow && !c->VpiParent()) ? 1 : 0;
        cell.own = kindOf(ow);
        cell.ctx = ctxOf(ow ? ow : c->VpiParent());
        cell.home = homeOf(ow ? ow : c->VpiParent());
        cell.rhs = 0;
        const BaseClass* p = c->VpiParent();
        if (p && p->UhdmType() == uhdmparam_assign &&
            ((const param_assign*)p)->Rhs() == (const any*)c)
            cell.rhs = 1;
        out[k].push_back(cell);
    }
}
static std::string desc(const Cell& c) {
    return c.ts + " own=" + c.own + " ctx=" + c.ctx + " home=" + c.home +
           (c.rhs ? " RHS" : "") + (c.orphan ? " ORPHAN" : "");
}
int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct159cls <golden> <ours> [--tag=T] [--list]\n"); return 2; }
    std::string tag = "PAIR", only;
    bool list = false;
    for (int a = 3; a < argc; a++) {
        if (!strncmp(argv[a], "--tag=", 6)) tag = argv[a] + 6;
        else if (!strncmp(argv[a], "--only=", 7)) only = argv[a] + 7;
        else if (!strcmp(argv[a], "--list")) list = true;
    }
    std::map<std::string, std::vector<Cell>> G, O;
    size_t gt = 0, gw = 0, ot = 0, ow = 0;
    collect(argv[1], G, gt, gw);
    collect(argv[2], O, ot, ow);
    // Per-(own,ctx,home-kind) tallies of the MISSING/EXTRA typespec population.
    std::map<std::string, int> missBy, extraBy;
    size_t miss = 0, extra = 0, noGolden = 0;
    for (auto& [k, gv] : G) {
        auto it = O.find(k);
        if (it == O.end()) continue;
        size_t gn = 0, on = 0, greach = 0, oreach = 0;
        for (auto& c : gv) { if (!c.orphan) { greach++; if (c.ts != "NONE") gn++; } }
        for (auto& c : it->second) { if (!c.orphan) { oreach++; if (c.ts != "NONE") on++; } }
        // A cell where GOLDEN has no reachable constant at all is not a cell
        // where golden made a typespec decision -- it is an OVER-FOLD of ours
        // (golden kept a ref_obj and left the reduced value in the tail).  A
        // stamp there is neither TO-GOLDEN nor AWAY-GOLDEN; counting it as
        // AWAY manufactures the phantom RESUME.md §9 warns about.
        if (greach == 0) { if (on) noGolden += on; continue; }
        if (oreach == 0) continue;
        if (gn == on) continue;
        const char* cls = gn > on ? "MISSING-OURS" : "EXTRA-OURS";
        if (gn > on) miss += gn - on; else extra += on - gn;
        // key the tally on the side that HAS the typespec
        const std::vector<Cell>& side = gn > on ? gv : it->second;
        for (auto& c : side)
            if (c.ts != "NONE" && !c.orphan) {
                std::string hk = c.home.substr(0, c.home.find(':'));
                std::string key = std::string(cls) + " own=" + c.own +
                                  " ctx=" + c.ctx + " home=" + hk;
                (gn > on ? missBy : extraBy)[key]++;
            }
        if (list && (only.empty() || only == cls)) {
            printf("%s CELL %s %s\n", tag.c_str(), cls, k.c_str());
            for (auto& c : gv) printf("%s    G %s\n", tag.c_str(), desc(c).c_str());
            for (auto& c : it->second) printf("%s    O %s\n", tag.c_str(), desc(c).c_str());
        }
    }
    for (auto& [k, v] : missBy) printf("%s TALLY %s n=%d\n", tag.c_str(), k.c_str(), v);
    for (auto& [k, v] : extraBy) printf("%s TALLY %s n=%d\n", tag.c_str(), k.c_str(), v);
    printf("%s SUM gconst=%zu gts=%zu oconst=%zu ots=%zu MISSING-OURS=%zu EXTRA-OURS=%zu "
           "NO-GOLDEN-OBJ=%zu\n",
           tag.c_str(), gt, gw, ot, ow, miss, extra, noGolden);
    return 0;
}
