// r10earl120 — the TWO-SIDED JOIN of every `typespec::Instance` edge whose
// target is a package, keyed so golden and ours pair up.
//
// MEASUREMENT ONLY.  `uhdm-cmp` is the judge.
//
// KEY.  Our typespecs carry an EMPTY `VpiFile` in places (RESUME.md
// section 9), so the file is NOT in the key.  The key is the typespec kind,
// the parent chain (kind:name) up to `depth` levels, and line:col.  The
// PAYLOAD is the package the edge lands on, spelled by its ROLE
// (AllPackages[i] / TopPackages[i]) and not by pointer identity, because the
// two producers mint different objects.
//
// Rows: BOTH (both sides carry an edge, same role), ROLE-DIFF (both carry one,
// different role), GOLDEN-ONLY (golden's edge, our typespec has Instance null
// or no such typespec), OURS-ONLY.  GOLDEN-ONLY is the head's family.
//
// build: g++ -O2 -std=c++17 join120.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o join120
// usage: join120 <golden.uhdm> <ours.uhdm> [--depth=N] [--pkg=NAME] [--list]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstring>
#include <map>
#include <string>
#include <vector>

using namespace UHDM;

static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("<null>");
}
static std::string node(const BaseClass* o) {
    return o ? kindOf(o) + ":" + std::string(o->VpiName()) : std::string("^");
}

struct Side {
    Serializer s;
    const design* d = nullptr;
    std::map<const BaseClass*, std::string> role;   // package obj -> role string
};

static void loadRoles(Side& S) {
    if (S.d->AllPackages())
        for (size_t i = 0; i < S.d->AllPackages()->size(); i++)
            S.role[S.d->AllPackages()->at(i)] += "All[" + std::to_string(i) + "]";
    if (S.d->TopPackages())
        for (size_t i = 0; i < S.d->TopPackages()->size(); i++)
            S.role[S.d->TopPackages()->at(i)] += "Top[" + std::to_string(i) + "]";
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: join120 <golden> <ours> [--depth=N] [--pkg=NAME] [--list]\n");
        return 2;
    }
    int depth = 4;
    bool list = false;
    std::string onlyPkg;
    for (int i = 3; i < argc; i++) {
        if (!strncmp(argv[i], "--depth=", 8)) depth = atoi(argv[i] + 8);
        if (!strncmp(argv[i], "--pkg=", 6)) onlyPkg = argv[i] + 6;
        if (!strcmp(argv[i], "--list")) list = true;
    }
    Side G, O;
    auto hg = G.s.Restore(std::string(argv[1]));
    auto ho = O.s.Restore(std::string(argv[2]));
    if (hg.empty() || ho.empty()) { fprintf(stderr, "FATAL: restore failed\n"); return 3; }
    G.d = (const design*)((const uhdm_handle*)hg[0])->object;
    O.d = (const design*)((const uhdm_handle*)ho[0])->object;
    loadRoles(G); loadRoles(O);

    auto keyOf = [&](const BaseClass* o) {
        std::string k = kindOf(o);
        const BaseClass* p = o->VpiParent();
        for (int i = 0; i < depth && p; i++, p = p->VpiParent()) k += "|" + node(p);
        char b[64];
        snprintf(b, sizeof b, "|%u:%u", o->VpiLineNo(), (unsigned)o->VpiColumnNo());
        return k + b;
    };
    // key -> multiset of payloads
    auto collect = [&](Side& S, std::map<std::string, std::map<std::string, int>>& out) {
        for (const auto& [obj, id] : S.s.AllObjects()) {
            const typespec* t = any_cast<const typespec*>((const any*)obj);
            if (!t) continue;
            const instance* in = t->Instance();
            std::string pay;
            if (in == nullptr) pay = "<null>";
            else if (kindOf(in) != "package") continue;   // only package targets
            else {
                const std::string pn(in->VpiName());
                if (!onlyPkg.empty() && pn != onlyPkg) continue;
                pay = pn + " " + (S.role.count(in) ? S.role[in] : std::string("(unlisted)"));
            }
            if (pay == "<null>") {
                // a NULL edge only matters when the other side has one; keep it
                if (!onlyPkg.empty()) { /* keep, joined below */ }
            }
            out[keyOf(obj)][pay]++;
        }
    };
    std::map<std::string, std::map<std::string, int>> g, o;
    collect(G, g); collect(O, o);
    printf("GOLDEN keys=%zu   OURS keys=%zu   (depth=%d pkg='%s')\n", g.size(), o.size(),
           depth, onlyPkg.c_str());

    std::map<std::string, int> tally;
    std::vector<std::string> gonly, oonly, rolediff;
    std::map<std::string, int> gonlyShape, rolediffShape;
    for (const auto& [k, gp] : g) {
        auto it = o.find(k);
        const std::map<std::string, int> empty;
        const std::map<std::string, int>& op = (it == o.end()) ? empty : it->second;
        // per-payload multiset difference
        for (const auto& [pay, n] : gp) {
            if (pay == "<null>") continue;
            int have = 0;
            auto j = op.find(pay);
            if (j != op.end()) have = j->second;
            int missing = n - have;
            if (missing > 0) {
                // is there an ours row on the same key with a DIFFERENT payload?
                bool other = false, nullSide = false;
                for (const auto& [p2, n2] : op) {
                    if (p2 == pay) continue;
                    if (p2 == "<null>") nullSide = true; else other = true;
                }
                if (other) { tally["ROLE-DIFF"] += missing; rolediffShape[k.substr(0, k.find('|', k.find('|') + 1))] += missing;
                             if (rolediff.size() < 40) rolediff.push_back(k + "   golden=" + pay); }
                else { tally[nullSide ? "GOLDEN-ONLY(ours null)" : "GOLDEN-ONLY(no ours key)"] += missing;
                       gonlyShape[k.substr(0, k.find('|', k.find('|') + 1))] += missing;
                       if (gonly.size() < 60) gonly.push_back(k + "   golden=" + pay +
                           (nullSide ? "   ours=<null>" : "   ours=<no key>")); }
            }
            tally["BOTH"] += (n - (missing > 0 ? missing : 0));
        }
    }
    for (const auto& [k, op] : o) {
        auto it = g.find(k);
        const std::map<std::string, int> empty;
        const std::map<std::string, int>& gp = (it == g.end()) ? empty : it->second;
        for (const auto& [pay, n] : op) {
            if (pay == "<null>") continue;
            int have = 0;
            auto j = gp.find(pay);
            if (j != gp.end()) have = j->second;
            if (n - have > 0) { tally["OURS-ONLY"] += n - have;
                                if (oonly.size() < 40) oonly.push_back(k + "   ours=" + pay); }
        }
    }
    printf("\n== TALLY\n");
    for (const auto& [k, n] : tally) printf("   %-28s %7d\n", k.c_str(), n);
    printf("\n== GOLDEN-ONLY by owner shape (typespec-kind|parent-kind:name)\n");
    for (const auto& [k, n] : gonlyShape) printf("   %-64s %6d\n", k.c_str(), n);
    printf("\n== ROLE-DIFF by owner shape\n");
    for (const auto& [k, n] : rolediffShape) printf("   %-64s %6d\n", k.c_str(), n);
    if (list) {
        printf("\n== GOLDEN-ONLY rows (first %zu)\n", gonly.size());
        for (const auto& r : gonly) printf("   %s\n", r.c_str());
        printf("\n== ROLE-DIFF rows (first %zu)\n", rolediff.size());
        for (const auto& r : rolediff) printf("   %s\n", r.c_str());
        printf("\n== OURS-ONLY rows (first %zu)\n", oonly.size());
        for (const auto& r : oonly) printf("   %s\n", r.c_str());
    }
    return 0;
}
