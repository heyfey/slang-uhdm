// r10uvm168 — THE CONST-TYPE CENSUS over a database PAIR.  MEASUREMENT ONLY;
// the official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.
// LHS is ALWAYS golden (Surelog), RHS is ALWAYS ours.
//
//   usage: ct168cen <golden.uhdm> <ours.uhdm> <tag>
//
// Prints one row per PARAM_ASSIGN CELL that exists on at least one side:
//
//   PA <tag> <section> <lhs-fullname> <span> G=<ct/kind> O=<ct/kind> <verdict>
//
// and one row per WHOLE-DESIGN CONSTANT cell (a depth-keyed identity census,
// RESUME §9: a slot-keyed census is blind below the slot), keyed by the
// enclosing-kind chain + span + the constant's own compared fields:
//
//   CN <tag> <chain> <span> G=<ct> O=<ct> <verdict>
//
// plus a TALLY line.  A cell present on one side only is reported as such and
// never scored — an ONLY-GOLDEN gap is a residue, not a disagreement.
//
// The `kind` column is the constant's Typespec ACTUAL kind, which is what
// separates the enum-origin population this pass owns from every other folded
// constant.  `ORIG` is the enum-member origin classification read off the
// database alone: ENUM when the constant's typespec actual is an enum_typespec.
//
// build: g++ -O2 -std=c++17 ct168cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct168cen
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <map>
#include <string>
#include <vector>

using namespace UHDM;

static std::string span(const BaseClass* o) {
    char b[80];
    snprintf(b, sizeof b, "%u:%u:%u:%u", o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
             o->VpiEndLineNo(), (unsigned)o->VpiEndColumnNo());
    return b;
}
// The design-level list an object belongs to, walked from its parent chain:
// a package/module reached through `VpiTop` is the ELABORATED listing, the
// other the definition listing.  Both hold the SAME spans, so a census that
// does not separate them silently reports one of the two (the `allPackages`
// vs `topPackages` collision this pass measured on its own grid).
static std::string section(const BaseClass* o) {
    std::string tail = "?";
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
        UHDM_OBJECT_TYPE t = p->UhdmType();
        if (t == uhdmpackage) {
            tail = ((const package*)p)->VpiTop() ? "topPkg" : "defPkg";
        } else if (t == uhdmmodule_inst) {
            tail = ((const module_inst*)p)->VpiTop() ? "topMod" : "defMod";
        } else if (t == uhdmclass_defn) {
            tail = "class";
        } else if (t == uhdminterface_inst) {
            tail = "iface";
        } else if (t == uhdmdesign) {
            if (tail == "?") tail = "design";
            break;
        }
    }
    return tail;
}
static std::string chainOf(const BaseClass* o) {
    std::string s;
    int g = 0;
    for (const BaseClass* p = o->VpiParent(); p && g < 4; p = p->VpiParent(), ++g) {
        s += "/";
        s += UhdmName(p->UhdmType());
    }
    return s.empty() ? "/" : s;
}
static std::string tsKind(const constant* c) {
    const ref_typespec* rt = c->Typespec();
    if (!rt) return std::string("nots");
    const typespec* a = rt->Actual_typespec();
    if (!a) return std::string("nact");
    return UhdmName(a->UhdmType());
}
static std::string lhsName(const any* l) {
    // A param_assign Lhs is a `parameter` (or a `class` type param); its
    // fullname is the stable key.  Fall back to the plain name when the
    // fullname is empty so a cell is never keyed on nothing.
    if (const parameter* p = any_cast<const parameter*>(l)) {
        std::string f(p->VpiFullName());
        if (!f.empty()) return f;
    }
    std::string n(l->VpiName());
    return n.empty() ? std::string("?") : n;
}
struct Cell {
    int ct = -1;
    std::string kind;
    std::string dec;
    int size = -1;
};
static void collect(Serializer& s, std::map<std::string, Cell>& pa,
                    std::map<std::string, int>& cn) {
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        if (o->UhdmType() == uhdmparam_assign) {
            const param_assign* p = (const param_assign*)o;
            const any* r = p->Rhs();
            const any* l = p->Lhs();
            if (!r || r->UhdmType() != uhdmconstant) continue;
            const constant* c = (const constant*)r;
            std::string key = section(o) + "|" +
                              (l ? lhsName(l) : std::string("?")) + "|" + span(o);
            Cell cell;
            cell.ct = c->VpiConstType();
            cell.kind = tsKind(c);
            cell.dec = std::string(c->VpiDecompile());
            cell.size = c->VpiSize();
            // Two cells cannot share a key: the section + Lhs fullname + span
            // triple is unique per listing.  If one does, say so loudly rather
            // than letting a last-writer dict drop a row.
            auto it = pa.find(key);
            if (it != pa.end() && (it->second.ct != cell.ct ||
                                   it->second.dec != cell.dec ||
                                   it->second.size != cell.size))
                it->second.kind += "!!COLLIDE!!";
            else
                pa[key] = cell;
        }
        if (o->UhdmType() == uhdmconstant) {
            const constant* c = (const constant*)o;
            char b[600];
            snprintf(b, sizeof b, "%s|%s|%s|%d|%s", section(o).c_str(),
                     chainOf(o).c_str(), span(o).c_str(), c->VpiSize(),
                     std::string(c->VpiDecompile()).c_str());
            cn[std::string(b) + "|ct" + std::to_string(c->VpiConstType())]++;
        }
    }
}

int main(int argc, char** argv) {
    if (argc < 4) { fprintf(stderr, "usage: ct168cen <golden> <ours> <tag> [all]\n"); return 2; }
    const char* tag = argv[3];
    // `all` prints EVERY param_assign cell, agreeing ones included, so the
    // A-PRIORI MOVER PREDICTION can be made from the PRISTINE databases before
    // the patched sweep ever runs (RESUME §6: "PREDICT the mover set BY NAME
    // from pristine databases FIRST").
    const bool showAll = argc > 4 && std::string(argv[4]) == "all";
    Serializer sg, so;
    if (sg.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL %s golden\n", tag); return 3; }
    if (so.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL %s ours\n", tag); return 3; }
    std::map<std::string, Cell> pg, po;
    std::map<std::string, int> cg, co;
    collect(sg, pg, cg);
    collect(so, po, co);
    long agree = 0, ctdiff = 0, onlyg = 0, onlyo = 0, otherdiff = 0;
    for (auto& kv : pg) {
        auto it = po.find(kv.first);
        if (it == po.end()) {
            ++onlyg;
            printf("PA %s %s G=ct%d/%s/%s/%d O=<ABSENT> ONLY-GOLDEN\n", tag,
                   kv.first.c_str(), kv.second.ct, kv.second.kind.c_str(),
                   kv.second.dec.c_str(), kv.second.size);
            continue;
        }
        const bool ctsame = kv.second.ct == it->second.ct;
        const bool restsame = kv.second.dec == it->second.dec &&
                              kv.second.size == it->second.size;
        if (ctsame && restsame) {
            ++agree;
            if (showAll)
                printf("PA %s %s G=ct%d/%s/%s/%d O=ct%d/%s/%s/%d AGREE\n", tag,
                       kv.first.c_str(), kv.second.ct, kv.second.kind.c_str(),
                       kv.second.dec.c_str(), kv.second.size, it->second.ct,
                       it->second.kind.c_str(), it->second.dec.c_str(),
                       it->second.size);
            continue;
        }
        if (!ctsame) ++ctdiff; else ++otherdiff;
        printf("PA %s %s G=ct%d/%s/%s/%d O=ct%d/%s/%s/%d %s\n", tag,
               kv.first.c_str(), kv.second.ct, kv.second.kind.c_str(),
               kv.second.dec.c_str(), kv.second.size, it->second.ct,
               it->second.kind.c_str(), it->second.dec.c_str(), it->second.size,
               ctsame ? "SAME-CT-OTHER-DIFF" : "CT-DIFF");
    }
    for (auto& kv : po)
        if (pg.find(kv.first) == pg.end()) {
            ++onlyo;
            printf("PA %s %s G=<ABSENT> O=ct%d/%s/%s/%d ONLY-OURS\n", tag,
                   kv.first.c_str(), kv.second.ct, kv.second.kind.c_str(),
                   kv.second.dec.c_str(), kv.second.size);
        }
    long cnG = 0, cnO = 0, cnBoth = 0;
    for (auto& kv : cg) {
        auto it = co.find(kv.first);
        int have = it == co.end() ? 0 : it->second;
        if (have >= kv.second) cnBoth += kv.second;
        else { cnBoth += have; cnG += kv.second - have; }
    }
    for (auto& kv : co) {
        auto it = cg.find(kv.first);
        int have = it == cg.end() ? 0 : it->second;
        if (kv.second > have) cnO += kv.second - have;
    }
    printf("TALLY %s PA agree=%ld ct-diff=%ld other-diff=%ld only-golden=%ld "
           "only-ours=%ld | CN both=%ld only-golden=%ld only-ours=%ld\n",
           tag, agree, ctdiff, otherdiff, onlyg, onlyo, cnBoth, cnG, cnO);
    return 0;
}
