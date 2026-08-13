// r10sd3 — THE DECODE INSTRUMENT for § instanceIsNeverAClassDefn2.
//
// r10sd2 proved the LAW (golden never points vpiInstance at a class_defn; we do
// it 428/216/216/203 times).  It did NOT answer the only question a FIX needs:
//
//     what does GOLDEN put in those same slots — NULL, or the class's HOME
//     scope (its package / module)?
//
// "Null it" and "re-point it at the home package" are different patches and the
// law's negative phrasing ("never a class_defn") cannot distinguish them.  This
// tool answers it from golden's cells.
//
// Method: key every object that carries a singular Instance() by
// (uhdmType | VpiName | line:col-endline:endcol) — VpiFile is EXCLUDED because
// our emission leaves it empty (sd2 R7) — and keep the whole MULTISET of
// Instance states per key on each side, because Surelog emits one copy of every
// package-homed object PER PACKAGE VIEW and a one-value-per-key census collapses
// them (sd2 §4.5).  Then, for every key where OUR multiset contains a
// class_defn state, print GOLDEN's multiset for the same key.
//
// Output sections:
//   [A] whole-database state totals (ct2view's table, kept for continuity)
//   [B] per-key verdict histogram: for the keys where ours says class_defn,
//       what does golden say?   GOLDEN_NULL_ONLY / GOLDEN_PKG / GOLDEN_MIXED /
//       KEY_ABSENT_IN_GOLDEN
//   [C] the surplus accounted per verdict, and examples
//   [D] owner-type and owner-name breakdown of the class_defn population
//
// build: g++ -O2 -std=c++17 ct3cls.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct3cls
// usage: ct3cls <golden.uhdm> <ours.uhdm> [maxexamples]
#include <uhdm/uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <map>
#include <sstream>
#include <string>
#include <vector>

using namespace UHDM;

static int g_maxex = 10;

static std::string span(const BaseClass* p) {
    std::ostringstream k;
    k << UhdmName(p->UhdmType()) << "|" << p->VpiName() << "|" << p->VpiLineNo()
      << ":" << p->VpiColumnNo() << "-" << p->VpiEndLineNo() << ":"
      << p->VpiEndColumnNo();
    return k.str();
}

struct Side {
    std::map<std::string, std::map<std::string, int>> byKey;  // key -> state -> n
};

// Owner-side detail we only keep for OUR database.
struct Detail {
    std::string key;
    std::string ownerType;
    std::string cls;      // class_defn name
    std::string parent;   // VpiParent type(name)
};
static std::vector<Detail> g_ours;

static void collect(const char* path, Side& s, bool mine) {
    Serializer ser;
    auto h = ser.Restore(std::filesystem::path(path));
    if (h.empty()) { std::cerr << "RESTORE_FAIL " << path << "\n"; exit(3); }
    auto* d = (design*)((uhdm_handle*)h[0])->object;
    std::map<const BaseClass*, std::string> pkgState;
    if (d->AllPackages())
        for (auto* p : *d->AllPackages())
            pkgState[p] = "ALL:" + std::string(p->VpiName());
    if (d->TopPackages())
        for (auto* p : *d->TopPackages())
            pkgState[p] = "TOP:" + std::string(p->VpiName());
    for (const auto& [p, id] : ser.AllObjects()) {
        if (!p) continue;
        const typespec* t = any_cast<const typespec*>(p);
        const variables* v = any_cast<const variables*>(p);
        const task_func* f = any_cast<const task_func*>(p);
        const ports* q = any_cast<const ports*>(p);
        const clocking_block* cb = any_cast<const clocking_block*>(p);
        const instance* in = any_cast<const instance*>(p);
        if (!(t || v || f || q || cb || in)) continue;
        const instance* val = t    ? t->Instance()
                              : v  ? v->Instance()
                              : f  ? f->Instance()
                              : q  ? q->Instance()
                              : cb ? cb->Instance()
                                   : in->Instance();
        std::string st = "<null>";
        if (val) {
            auto it = pkgState.find((const BaseClass*)val);
            st = it != pkgState.end()
                     ? it->second
                     : ("OTHER:" + std::string(UhdmName(val->UhdmType())) + "(" +
                        std::string(val->VpiName()) + ")");
        }
        std::string k = span(p);
        s.byKey[k][st]++;
        if (mine && val && val->UhdmType() == uhdmclass_defn) {
            Detail dt;
            dt.key = k;
            dt.ownerType = UhdmName(p->UhdmType());
            dt.cls = val->VpiName();
            const BaseClass* par = p->VpiParent();
            dt.parent = par ? (std::string(UhdmName(par->UhdmType())) + "(" +
                               std::string(par->VpiName()) + ")")
                            : "<null>";
            g_ours.push_back(dt);
        }
    }
}

int main(int argc, char** argv) {
    if (argc < 3) {
        std::cerr << "usage: ct3cls <golden.uhdm> <ours.uhdm> [maxex]\n";
        return 2;
    }
    if (argc > 3) g_maxex = atoi(argv[3]);
    Side G, O;
    collect(argv[1], G, false);
    collect(argv[2], O, true);
    std::cout << "keys: golden=" << G.byKey.size() << " ours=" << O.byKey.size()
              << "\n";

    std::map<std::string, int> gt, ot;
    for (auto& [k, m] : G.byKey)
        for (auto& [st, n] : m) gt[st] += n;
    for (auto& [k, m] : O.byKey)
        for (auto& [st, n] : m) ot[st] += n;
    std::cout << "\n[A] vpiInstance state totals (whole database)\n";
    printf("%-42s %9s %9s %9s\n", "state", "GOLDEN", "OURS", "DELTA");
    std::vector<std::string> sts;
    for (auto& [k, v] : gt) sts.push_back(k);
    for (auto& [k, v] : ot)
        if (!gt.count(k)) sts.push_back(k);
    std::sort(sts.begin(), sts.end());
    long gcls = 0, ocls = 0;
    for (const auto& st : sts) {
        if (st.rfind("OTHER:class_defn", 0) == 0) { gcls += gt[st]; ocls += ot[st]; continue; }
        printf("%-42s %9d %9d %+9d\n", st.c_str(), gt[st], ot[st], ot[st] - gt[st]);
    }
    printf("%-42s %9ld %9ld %+9ld   <== THE LAW\n", "OTHER:class_defn(*) [summed]",
           gcls, ocls, ocls - gcls);

    // [B]/[C] the decode.
    std::map<std::string, int> verdict, verdictSlots;
    std::map<std::string, std::vector<std::string>> ex;
    // group our class_defn details by key
    std::map<std::string, int> ourClsByKey;
    for (auto& d : g_ours) ourClsByKey[d.key]++;
    for (const auto& [k, n] : ourClsByKey) {
        auto git = G.byKey.find(k);
        std::string vd;
        std::ostringstream line;
        line << "  " << k << "  ours class_defn x" << n;
        if (git == G.byKey.end()) {
            vd = "KEY_ABSENT_IN_GOLDEN";
            line << "\n      golden: <key absent>";
        } else {
            bool hasNull = git->second.count("<null>") > 0;
            bool hasPkg = false, hasCls = false, hasOther = false;
            for (auto& [st, c] : git->second) {
                if (st == "<null>") continue;
                if (st.rfind("OTHER:class_defn", 0) == 0) hasCls = true;
                else if (st.rfind("ALL:", 0) == 0 || st.rfind("TOP:", 0) == 0) hasPkg = true;
                else hasOther = true;
            }
            if (hasCls) vd = "GOLDEN_CLASS_DEFN(!!)";
            else if (hasNull && !hasPkg && !hasOther) vd = "GOLDEN_NULL_ONLY";
            else if (!hasNull && (hasPkg || hasOther)) vd = "GOLDEN_NONNULL_ONLY";
            else vd = "GOLDEN_MIXED";
            line << "\n      golden:";
            for (auto& [a, b] : git->second) line << " " << a << "=" << b;
            line << "\n      ours  :";
            for (auto& [a, b] : O.byKey[k]) line << " " << a << "=" << b;
        }
        verdict[vd]++;
        verdictSlots[vd] += n;
        if ((int)ex[vd].size() < g_maxex) ex[vd].push_back(line.str());
    }
    std::cout << "\n[B] keys whose OUR multiset contains a class_defn state — "
                 "what does GOLDEN hold at the SAME key?\n";
    printf("%-24s %8s %8s\n", "verdict", "KEYS", "SLOTS");
    for (auto& [v, n] : verdict) printf("%-24s %8d %8d\n", v.c_str(), n, verdictSlots[v]);

    std::cout << "\n[C] examples per verdict\n";
    for (auto& [v, lines] : ex) {
        std::cout << "--- " << v << "\n";
        for (auto& l : lines) std::cout << l << "\n";
    }

    std::cout << "\n[D] our class_defn population, by OWNER TYPE and CLASS NAME\n";
    std::map<std::string, int> byOwner, byCls, byParent;
    for (auto& d : g_ours) { byOwner[d.ownerType]++; byCls[d.cls]++; byParent[d.parent.substr(0, d.parent.find('('))]++; }
    std::cout << "owner types:";
    for (auto& [k, v] : byOwner) std::cout << " " << k << "=" << v;
    std::cout << "\nparent types:";
    for (auto& [k, v] : byParent) std::cout << " " << k << "=" << v;
    std::cout << "\nclass names (" << byCls.size() << "):";
    for (auto& [k, v] : byCls) std::cout << " " << k << "=" << v;
    std::cout << "\nTOTAL class_defn-valued Instance() slots on OUR side: "
              << g_ours.size() << "\n";
    return 0;
}
