// r10sd8 — THE FULL TWO-DIRECTION INSTANCE CENSUS, over EVERY vpiInstance slot.
//
// sd7 R2 left 25 candidate keys where GOLDEN'S vpiInstance is NULL and at least
// one of OURS is not; sd7 R7 records the CONVERSE deficit (golden 13 184
// instanced objects on SeqDriver to our 9 892).  The brief's hypothesis is that
// both are ONE decode firing in two directions.  A tool that reports one
// direction cannot test that, so this one reports BOTH on the SAME key.
//
// THREE things it does that `ct7cand` does not:
//
//  1. It covers EVERY class that has a `vpiInstance` slot, not just `typespec`
//     and `variables`: `instance_array`, `clocking_block`, `ports`, `instance`,
//     `task_func`, `typespec`, `variables` — the seven headers in the installed
//     UHDM that declare `instance* Instance`.  `ct7cand` read two of the seven,
//     so an unmatched stamp on any of the other five was invisible to it, and
//     the head is `LHS:<null>` / `RHS: package(uvm_pkg)` while every one of
//     ct7cand's 25 rows is stamped `adpcm_pkg` — the head is NOT in its output.
//  2. It compares the two sides' views as a MULTISET per key.  Both package
//     views often produce two objects with the SAME key (the key holds kind,
//     name, span and three parent hops, and the def/elab twins agree on all
//     four), so a "first non-null wins" read invents `ALL:` vs `TOP:`
//     disagreements that are not there.
//  3. It reports NO_TWIN — objects of ours that carry a stamp and have NO
//     golden object at their key at all.  A key-join silently drops those, and
//     "the join found nothing" and "there is nothing" print the same.
//
// It also tags every row with its LISTING MEMBERSHIP (which scope's Typespecs
// vector holds it, in which view), because "package-LISTING typespec" is the
// population the brief names.
//
// GUARD: an empty join (zero shared keys) is a hard error.
//
// build: g++ -O2 -std=c++17 ct8cens.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct8cens
// usage: ct8cens <golden.uhdm> <ours.uhdm> [--rows]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static std::string span(const BaseClass* p) {
    return std::to_string(p->VpiLineNo()) + ":" + std::to_string(p->VpiColumnNo()) + "-" +
           std::to_string(p->VpiEndLineNo()) + ":" + std::to_string(p->VpiEndColumnNo());
}
static std::string ident(const BaseClass* p) {
    if (!p) return "<null>";
    std::string s = UhdmName(p->UhdmType());
    std::string nm(p->VpiName());
    if (!nm.empty()) s += "(" + nm + ")";
    return s + "@" + span(p);
}
// VpiFile is EXCLUDED on purpose (sd2 R7 — our typespecs mostly carry no file,
// and a file-keyed join reads green by matching nothing).
static std::string key(const BaseClass* p) {
    std::string k = ident(p);
    const BaseClass* q = p->VpiParent();
    for (int i = 0; i < 3 && q; i++) { k += " <- " + ident(q); q = q->VpiParent(); }
    return k;
}

struct Row {
    std::string view;
    std::string listing;
    const BaseClass* obj;
};

struct Side {
    std::map<std::string, std::vector<Row>> rows;
    std::set<const BaseClass*> allp, topp;
    std::map<const BaseClass*, std::string> listedIn;
    std::string view(const instance* i) const {
        if (!i) return "<null>";
        std::string nm(i->VpiName());
        if (topp.count(i)) return "TOP:" + nm;
        if (allp.count(i)) return "ALL:" + nm;
        return "OTHER:" + nm;
    }
};

// Every class in the installed UHDM whose header declares `instance* Instance`.
static bool instSlot(const any* o, const instance*& in) {
    if (auto* t = any_cast<const typespec*>(o))       { in = t->Instance(); return true; }
    if (auto* v = any_cast<const variables*>(o))      { in = v->Instance(); return true; }
    if (auto* f = any_cast<const task_func*>(o))      { in = f->Instance(); return true; }
    if (auto* p = any_cast<const ports*>(o))          { in = p->Instance(); return true; }
    if (auto* c = any_cast<const clocking_block*>(o)) { in = c->Instance(); return true; }
    if (auto* i2 = any_cast<const instance*>(o))      { in = i2->Instance(); return true; }
    return false;
}

static void load(const char* path, Side& S, size_t& nobj) {
    static Serializer s1, s2;
    static int which = 0;
    Serializer& s = (which++ == 0) ? s1 : s2;
    auto h = s.Restore(std::filesystem::path(path));
    if (h.empty()) { std::cerr << "RESTORE FAILED " << path << "\n"; exit(3); }
    auto* d = (design*)((uhdm_handle*)h[0])->object;
    if (auto* v = d->AllPackages()) for (auto* p : *v) S.allp.insert(p);
    if (auto* v = d->TopPackages()) for (auto* p : *v) S.topp.insert(p);

    // Listing membership, first writer wins.
    auto notePkg = [&](const VectorOfpackage* v, const char* tag) {
        if (!v) return;
        for (auto* p : *v)
            if (p->Typespecs())
                for (auto* t : *p->Typespecs())
                    if (t && !S.listedIn.count(t))
                        S.listedIn[t] = std::string(tag) + ":" + std::string(p->VpiName());
    };
    notePkg(d->AllPackages(), "ALLPKG");
    notePkg(d->TopPackages(), "TOPPKG");
    if (auto* v = d->AllModules())
        for (auto* m : *v)
            if (m->Typespecs())
                for (auto* t : *m->Typespecs())
                    if (t && !S.listedIn.count(t))
                        S.listedIn[t] = "ALLMOD:" + std::string(m->VpiName());
    if (auto* v = d->TopModules())
        for (auto* m : *v)
            if (m->Typespecs())
                for (auto* t : *m->Typespecs())
                    if (t && !S.listedIn.count(t))
                        S.listedIn[t] = "TOPMOD:" + std::string(m->VpiName());
    if (auto* v = d->Typespecs())
        for (auto* t : *v)
            if (t && !S.listedIn.count(t)) S.listedIn[t] = "DESIGN";
    for (const auto& [obj, id] : s.AllObjects()) {
        if (!obj || obj->UhdmType() != uhdmclass_defn) continue;
        auto* cd = (class_defn*)obj;
        if (cd->Typespecs())
            for (auto* t : *cd->Typespecs())
                if (t && !S.listedIn.count(t))
                    S.listedIn[t] = "CLASS:" + std::string(cd->VpiName());
    }

    for (const auto& [obj, id] : s.AllObjects()) {
        if (!obj) continue;
        nobj++;
        const instance* in = nullptr;
        if (!instSlot((const any*)obj, in)) continue;
        auto lit = S.listedIn.find(obj);
        S.rows[key(obj)].push_back(
            {S.view(in), lit == S.listedIn.end() ? std::string("-") : lit->second, obj});
    }
}

static std::string kindOf(const std::string& k) {
    size_t a = k.find('('), b = k.find('@');
    return k.substr(0, std::min(a == std::string::npos ? k.size() : a,
                                b == std::string::npos ? k.size() : b));
}

int main(int argc, char** argv) {
    if (argc < 3) { std::cerr << "usage: ct8cens <golden> <ours> [--rows]\n"; return 2; }
    bool wantRows = (argc > 3 && std::string(argv[3]) == "--rows");
    Side G, O;
    size_t ng = 0, no = 0;
    load(argv[1], G, ng);
    load(argv[2], O, no);
    std::cout << "objects: golden=" << ng << " ours=" << no
              << "   instance-slot keys: golden=" << G.rows.size()
              << " ours=" << O.rows.size() << "\n";

    size_t shared = 0, match = 0, oursOnly = 0, goldOnly = 0, viewDiff = 0;
    size_t noTwinStamped = 0, noTwinRows = 0;
    std::map<std::string, int> kOursOnly, kGoldOnly, kViewDiff, kNoTwin, kGoldNoTwin;
    for (auto& [k, ov] : O.rows) {
        auto it = G.rows.find(k);
        if (it == G.rows.end()) {
            for (auto& r : ov) {
                noTwinRows++;
                if (r.view != "<null>") {
                    noTwinStamped++;
                    kNoTwin[kindOf(k) + "  ours=" + r.view + "  list=" + r.listing]++;
                    if (wantRows) std::cout << "NO_TWIN " << r.view << " [" << r.listing << "]  " << k << "\n";
                }
            }
            continue;
        }
        shared++;
        // MULTISET of views, both sides.
        std::map<std::string, int> gm, om;
        for (auto& r : it->second) gm[r.view]++;
        for (auto& r : ov) om[r.view]++;
        if (gm == om) { match++; continue; }
        int gNull = gm.count("<null>") ? gm["<null>"] : 0;
        int oNull = om.count("<null>") ? om["<null>"] : 0;
        bool gAllNull = (gNull == (int)it->second.size());
        bool oAllNull = (oNull == (int)ov.size());
        std::string gv, ovv;
        for (auto& [v, c] : gm) if (v != "<null>") gv += (gv.empty() ? "" : "+") + v + "x" + std::to_string(c);
        for (auto& [v, c] : om) if (v != "<null>") ovv += (ovv.empty() ? "" : "+") + v + "x" + std::to_string(c);
        if (gv.empty()) gv = "<null>";
        if (ovv.empty()) ovv = "<null>";
        std::string lst = ov.empty() ? "-" : ov[0].listing;
        std::string glst = it->second.empty() ? "-" : it->second[0].listing;
        if (gAllNull && !oAllNull) {
            oursOnly++;
            kOursOnly[kindOf(k) + "  ours=" + ovv + "  ourList=" + lst + "  goldList=" + glst]++;
            if (wantRows) std::cout << "OURS_ONLY " << ovv << " [" << lst << "|" << glst << "]  " << k << "\n";
        } else if (!gAllNull && oAllNull) {
            goldOnly++;
            kGoldOnly[kindOf(k) + "  gold=" + gv + "  ourList=" + lst + "  goldList=" + glst]++;
            if (wantRows) std::cout << "GOLD_ONLY " << gv << " [" << lst << "|" << glst << "]  " << k << "\n";
        } else {
            viewDiff++;
            kViewDiff[kindOf(k) + "  gold=" + gv + "  ours=" + ovv]++;
            if (wantRows) std::cout << "VIEW_DIFF g=" << gv << " o=" << ovv << " [" << lst << "]  " << k << "\n";
        }
    }
    // Golden keys with no twin of ours — the other half of R7's deficit.
    size_t gNoTwinStamped = 0;
    for (auto& [k, gvv] : G.rows) {
        if (O.rows.count(k)) continue;
        for (auto& r : gvv)
            if (r.view != "<null>") {
                gNoTwinStamped++;
                kGoldNoTwin[kindOf(k) + "  gold=" + r.view + "  list=" + r.listing]++;
            }
    }
    std::cout << "[S] SHARED_KEYS=" << shared << " MATCH=" << match
              << " OURS_ONLY=" << oursOnly << " GOLD_ONLY=" << goldOnly
              << " VIEW_DIFF=" << viewDiff
              << " OURS_NOTWIN_STAMPED=" << noTwinStamped
              << " GOLD_NOTWIN_STAMPED=" << gNoTwinStamped << "\n";
    auto dump = [&](const char* t, std::map<std::string, int>& m) {
        std::cout << "--- " << t << "\n";
        std::vector<std::pair<int, std::string>> v;
        for (auto& [k, c] : m) v.push_back({c, k});
        std::sort(v.rbegin(), v.rend());
        for (auto& [c, k] : v) std::cout << "    " << c << "\t" << k << "\n";
    };
    dump("OURS_ONLY (golden all-null, ours stamped) by kind/view/listing", kOursOnly);
    dump("GOLD_ONLY (golden stamped, ours all-null) by kind/view/listing", kGoldOnly);
    dump("VIEW_DIFF (both stamped, multisets differ) by kind", kViewDiff);
    dump("OURS NO_TWIN stamped by kind", kNoTwin);
    dump("GOLDEN NO_TWIN stamped by kind", kGoldNoTwin);
    if (shared == 0) {
        std::cerr << "REFUSING TO REPORT: zero shared keys — the join matched nothing\n";
        return 5;
    }
    return 0;
}
