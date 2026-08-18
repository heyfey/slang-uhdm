// r10buvm19 — THE FOREACH HEADER ARRAY-REFERENCE TYPESPEC CENSUS.
// MEASUREMENT ONLY; nothing here is an acceptance judge (uhdm-cmp and
// scripts/verify_golden.py are).
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// One row per `foreach_stmt`, carrying
//   * the KEY: the enclosing subroutine's FULL NAME + the foreach's own
//     line:col.  Locations, not files: OUR expression nodes carry an EMPTY
//     VpiFile (buvm16 § 4 paid for that trap).
//   * the VIEW: ELABPKG / DEFPKG / TOPMOD / DEFMOD / DEFCLASS / DEFPROG /
//     DEFIFACE, decided by which of the design's listings the foreach's ROOT
//     ancestor (the object one step below `uhdmdesign`) sits in — buvm17's
//     trap 1: walking all the way to the design answers "design" for every
//     row and silently reads the axis as a constant.
//   * the VALUE: the `vpiVariables` array reference's KIND and NAME, whether
//     it carries a `vpiTypespec` at all, and that typespec's ACTUAL kind and
//     name.  `TS=NONE` is the shape this pass is about.
//   * `lv=` the whole vpiLoopVars listing as kind(name) — carried so that a
//     change to the array reference that also moved a loop variable cannot
//     hide (§ foreachElabLoopVarAnyKindBinds17 owns those and must not move).
//
// usage: r10buvm19cen <file.uhdm> [tag]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <iostream>
#include <map>
#include <string>
#include <vector>
using namespace UHDM;

static std::string nm(const any* t) { return t ? std::string(t->VpiName()) : "-"; }
static std::string kd(const any* t) { return t ? std::string(UhdmName(t->UhdmType())) : "NULL"; }
static std::string loc(const any* o) {
    return o ? std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo()) : "-";
}
static std::string fn(const any* t) {
    if (!t) return "-";
    if (t->UhdmType() == uhdmfunction) return std::string(((const function*)t)->VpiFullName());
    if (t->UhdmType() == uhdmtask) return std::string(((const task*)t)->VpiFullName());
    return std::string(t->VpiName());
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: r10buvm19cen <file.uhdm> [tag]\n"; return 2; }
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
    long nots = 0, uts = 0, other = 0, nover = 0;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o || o->UhdmType() != uhdmforeach_stmt) continue;
        const foreach_stmt* f = (const foreach_stmt*)o;

        std::string home = "<nosub>", view = "OTHER";
        const any* p = o->VpiParent();
        const any* last = o;
        int d = 0;
        while (p && d++ < 64) {
            UHDM_OBJECT_TYPE t = p->UhdmType();
            if (home == "<nosub>" && (t == uhdmfunction || t == uhdmtask)) home = fn(p);
            if (t != uhdmdesign) last = p;
            p = p->VpiParent();
        }
        auto rv = rootView.find(last);
        view = rv != rootView.end() ? rv->second : ("ROOT-" + kd(last));

        const any* var = f->Variable();
        std::string vk = "NOVAR", vn = "-", ts = "NOVAR", act = "-";
        if (var) {
            vk = kd(var); vn = nm(var);
            const ref_typespec* rt = nullptr;
            if (const variables* vv = any_cast<const variables*>(var)) rt = vv->Typespec();
            else if (const expr* ve = any_cast<const expr*>(var)) rt = ve->Typespec();
            if (!rt) { ts = "NONE"; nots++; }
            else {
                const typespec* a = rt->Actual_typespec();
                ts = a ? "TS" : "TSNULL";
                act = a ? kd(a) + "(" + nm(a) + ")" : "-";
                if (a && a->UhdmType() == uhdmunsupported_typespec) uts++; else other++;
            }
        } else nover++;

        std::string lv;
        if (auto* vs = f->VpiLoopVars())
            for (auto* v : *vs) {
                if (!lv.empty()) lv += ",";
                lv += kd(v) + "(" + nm(v) + ")";
            }
        if (lv.empty()) lv = "<none>";

        rows.push_back("FA " + tag + " key=" + home + "|" + loc(o) + " view=" + view +
                       " vk=" + vk + " vn=" + vn + " ts=" + ts + " act=" + act +
                       " lv=" + lv);
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) std::cout << r << "\n";
    std::cout << "SUMMARY " << tag << " foreach=" << rows.size()
              << " TSNONE=" << nots << " TSunsupported=" << uts
              << " TSother=" << other << " NOVAR=" << nover << "\n";
    return 0;
}
