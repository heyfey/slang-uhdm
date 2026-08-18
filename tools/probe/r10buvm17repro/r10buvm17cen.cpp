// r10buvm17 — THE FOREACH LOOP-VARIABLE BIND CENSUS.  MEASUREMENT ONLY;
// nothing here is an acceptance judge (uhdm-cmp and scripts/verify_golden.py
// are).
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// One row per `foreach_stmt`, carrying
//   * the KEY: the enclosing subroutine's FULL NAME + the foreach's own
//     line:col + the sorted `name@line:col` shape of every reference to a loop
//     variable inside it.  Locations, not files: OUR expression nodes carry an
//     EMPTY VpiFile (buvm16 § 4 paid for that trap), so a file key joins on
//     nothing; the subroutine full name plus the loc separates two same-lined
//     sites in different sources.
//   * the VIEW: DEFPKG / ELABPKG / DEFCLASS / MODULE / OTHER, decided by which
//     of `design->AllPackages()` / `TopPackages()` / `AllClasses()` /
//     `AllModules()` / `TopModules()` the foreach's ROOT ancestor sits in.
//     This is the axis the whole pass turns on: golden's un-elaborated package
//     listing lists an unresolved `ref_var` loop variable and binds nothing,
//     while its elaborated listing lists a TYPED variable and binds every body
//     reference to it.
//   * `lv=` every vpiLoopVars entry as kind(name) — the RESOLVEDNESS of the
//     listing, which is the producer's own discriminator
//     (UhdmWriter::lateBinding skips a loop var whose UhdmType is uhdmref_var).
//   * `r=` every reference to a loop-variable NAME anywhere under the foreach,
//     as name@loc:parentkind->actualkind(name) or ->BARE.  This is the VALUE.
//
// References are attributed by walking each ref_obj / bit_select's OWN
// VpiParent chain up to the foreach_stmt, not by a hand-written statement
// walker: every statement kind is covered for free and an unparented node is
// counted as ORPHAN instead of silently vanishing.
//
// usage: r10buvm17cen <file.uhdm> [tag]
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
static std::string fn(const any* t) {
    // task_func carries VpiFullName; `any` does not, so ask the scope kinds.
    if (!t) return "-";
    if (t->UhdmType() == uhdmfunction) return std::string(((const function*)t)->VpiFullName());
    if (t->UhdmType() == uhdmtask) return std::string(((const task*)t)->VpiFullName());
    return std::string(t->VpiName());
}
static std::string kd(const any* t) { return t ? std::string(UhdmName(t->UhdmType())) : "NULL"; }
static std::string loc(const any* o) {
    return o ? std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo()) : "-";
}

struct FE {
    const any* fe = nullptr;
    std::string view = "OTHER";
    std::string home, homeKind, chain, lv;
    int homeInst = -1;
    std::vector<std::string> refs;
    std::set<std::string> names;
};

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: r10buvm17cen <file.uhdm> [tag]\n"; return 2; }
    std::string tag = argc > 2 ? argv[2] : "T";
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { std::cout << "RESTORE_FAIL " << tag << "\n"; return 3; }

    // ---- root classification.  A root pointer can legitimately appear in two
    // lists (a top package is also an all-package in some writers), so the
    // FIRST match wins and the order is the elaboration order: top* before
    // all*, because the elaborated listing is the interesting one.
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

    // ---- one record per foreach_stmt.
    std::map<const any*, FE> fes;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o || o->UhdmType() != uhdmforeach_stmt) continue;
        FE r;
        r.fe = o;
        const foreach_stmt* f = (const foreach_stmt*)o;
        if (auto* vs = f->VpiLoopVars())
            for (auto* v : *vs) {
                if (!r.lv.empty()) r.lv += ",";
                r.lv += kd(v) + "(" + nm(v) + ")";
                if (v && !v->VpiName().empty()) r.names.insert(std::string(v->VpiName()));
            }
        if (r.lv.empty()) r.lv = "<none>";
        // the ancestor chain: kinds up to the root, and the nearest subroutine.
        const any* p = o->VpiParent();
        const any* last = o;
        int d = 0;
        while (p && d++ < 64) {
            UHDM_OBJECT_TYPE t = p->UhdmType();
            if (r.home.empty() && (t == uhdmfunction || t == uhdmtask)) {
                r.home = fn(p);
                if (r.home == "-" || r.home.empty()) r.home = nm(p);
                r.homeKind = kd(p);
                r.homeInst = (t == uhdmfunction) ? (((const function*)p)->Instance() ? 1 : 0)
                                                 : (((const task*)p)->Instance() ? 1 : 0);
            }
            if (t != uhdmbegin && t != uhdmnamed_begin)
                r.chain += (r.chain.empty() ? "" : "<") + kd(p);
            // The design is everyone's ancestor; the LISTING is the object
            // just below it, and that is what the view lookup is keyed on.
            if (p->UhdmType() != uhdmdesign) last = p;
            p = p->VpiParent();
        }
        auto rv = rootView.find(last);
        if (rv != rootView.end()) r.view = rv->second;
        else r.view = "ROOT-" + kd(last);
        if (r.home.empty()) { r.home = "<nosub>"; r.homeKind = "-"; }
        fes[o] = std::move(r);
    }

    // ---- attribute every reference by walking ITS parent chain to a foreach.
    long orphan = 0, refsSeen = 0;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o) continue;
        UHDM_OBJECT_TYPE t = o->UhdmType();
        if (t != uhdmref_obj && t != uhdmbit_select) continue;
        std::string n = std::string(o->VpiName());
        if (n.empty()) continue;
        const any* p = o->VpiParent();
        const any* imm = p;
        int d = 0;
        while (p && d++ < 64) {
            if (p->UhdmType() == uhdmforeach_stmt) break;
            p = p->VpiParent();
        }
        if (!p) { if (!o->VpiParent()) orphan++; continue; }
        auto it = fes.find(p);
        if (it == fes.end()) continue;
        if (!it->second.names.count(n)) continue;
        const any* ag = nullptr;
        if (t == uhdmref_obj) ag = ((const ref_obj*)o)->Actual_group();
        else ag = ((const bit_select*)o)->Actual_group();
        it->second.refs.push_back(n + "@" + loc(o) + ":" + kd(imm) + "->" +
                                  (ag ? kd(ag) + "(" + nm(ag) + ")" : "BARE"));
        refsSeen++;
    }

    std::vector<std::string> rows;
    long bound = 0, bare = 0;
    for (auto& [k, r] : fes) {
        std::vector<std::string> shape;
        std::string acts;
        auto rs = r.refs;
        std::sort(rs.begin(), rs.end());
        for (auto& x : rs) {
            shape.push_back(x.substr(0, x.find("->")));
            if (!acts.empty()) acts += ";";
            acts += x;
            if (x.find("->BARE") == std::string::npos) bound++; else bare++;
        }
        std::string sh;
        for (auto& x : shape) sh += "[" + x + "]";
        rows.push_back("FE " + tag + " key=" + r.home + "|" + loc(r.fe) + "|" +
                       (sh.empty() ? "<none>" : sh) + " view=" + r.view +
                       " nref=" + std::to_string(rs.size()) +
                       " lv=" + r.lv + " a=" + (acts.empty() ? "<none>" : acts) +
                       " hk=" + r.homeKind + " hi=" + std::to_string(r.homeInst) +
                       " ch=" + (r.chain.empty() ? "-" : r.chain));
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) std::cout << r << "\n";
    std::cout << "SUMMARY " << tag << " foreach=" << fes.size() << " refs=" << refsSeen
              << " bound=" << bound << " bare=" << bare << " orphanrefs=" << orphan << "\n";
    return 0;
}
