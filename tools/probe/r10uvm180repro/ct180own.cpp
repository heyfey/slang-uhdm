// r10uvm180 — THE OWNER-FINDER + THE PER-LISTING **TYPESPEC** COPY MAP.
// MEASUREMENT ONLY; the official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the
// sole judge.  This tool links the SAME generated `Compare` and only reports.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// STEP 1  the head, both parent chains, both listings, and (when the head is a
//         typespec) EVERY referrer edge on both sides — r10uvm178's mirror scan
//         generalised to run from either side.
// STEP 2  THE TYPESPEC LISTING COPY MAP.  Every scope that carries a
//         `Typespecs` vector (the design, each package in `AllPackages` /
//         `TopPackages`, each module/interface def, each class_defn) listed
//         with its entries' (kind, VpiName, line:col) — the listing key is the
//         design-vector membership of the owning package plus that package
//         object's id, never a face and never an index alone.
// STEP 3  THE LISTING PAIRING.  For one named scope, golden's vector and ours
//         printed SIDE BY SIDE BY INDEX, so a count gap shows WHICH entries are
//         extra and where the index-wise pairing first diverges.
//
// build: g++ -O2 -std=c++17 ct180own.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct180own
// usage: ct180own <golden.uhdm> <ours.uhdm> [<typespec-name substring>] [<scope tag substring>]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static std::string ident(const BaseClass* o) {
    if (!o) return "<null>";
    char b[900];
    const std::string kind(UhdmName(o->UhdmType()));
    const std::string nm(o->VpiName());
    snprintf(b, sizeof b, "%s(%s)@%u:%u-%u:%u#%u", kind.c_str(), nm.c_str(),
             o->VpiLineNo(), (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo(), o->UhdmId());
    return b;
}
static const design* topDesign(Serializer& s) {
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign)
            return (const design*)kv.first;
    return nullptr;
}
static std::string parentPath(const BaseClass* o) {
    std::string s;
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
        s += "<";
        s += UhdmName(p->UhdmType());
        s += ":";
        s += p->VpiName();
        s += ":";
        s += std::to_string(p->VpiLineNo());
    }
    return s;
}
static bool sameFace(const BaseClass* a, const BaseClass* b) {
    return a->UhdmType() == b->UhdmType() &&
           std::string(a->VpiName()) == std::string(b->VpiName()) &&
           a->VpiLineNo() == b->VpiLineNo() &&
           a->VpiColumnNo() == b->VpiColumnNo() &&
           a->VpiEndLineNo() == b->VpiEndLineNo() &&
           a->VpiEndColumnNo() == b->VpiEndColumnNo();
}

// ---- THE LISTING KEY (r10uvm178's, verbatim) -------------------------------
struct Listings {
    std::map<const BaseClass*, std::string> pkgTag;
    void build(const design* d) {
        if (auto* v = d->AllPackages())
            for (size_t i = 0; i < v->size(); ++i)
                pkgTag[(const BaseClass*)v->at(i)] +=
                    (pkgTag.count((const BaseClass*)v->at(i)) ? "+" : "") +
                    ("ALL[" + std::to_string(i) + "]");
        if (auto* v = d->TopPackages())
            for (size_t i = 0; i < v->size(); ++i)
                pkgTag[(const BaseClass*)v->at(i)] +=
                    (pkgTag.count((const BaseClass*)v->at(i)) &&
                             !pkgTag[(const BaseClass*)v->at(i)].empty()
                         ? "+"
                         : "") +
                    ("TOP[" + std::to_string(i) + "]");
    }
    std::string of(const BaseClass* o) const {
        const BaseClass* pkg = nullptr;
        for (const BaseClass* p = o; p; p = p->VpiParent())
            if (p->UhdmType() == uhdmpackage) pkg = p;
        if (!pkg) return "<no-package-ancestor>";
        auto it = pkgTag.find(pkg);
        std::string tag = it == pkgTag.end() ? "UNLISTED" : it->second;
        return tag + " " + std::string(pkg->VpiName()) + "#" +
               std::to_string(pkg->UhdmId());
    }
};

// Every scope in a database that owns a Typespecs vector, with a STABLE,
// producer-independent tag: role + scope name (+ the owning package's design
// listing tag when there is one).  Ids are printed but never keyed on.
struct Scope {
    std::string tag;                          // the stable key
    const BaseClass* obj = nullptr;
    const VectorOftypespec* vec = nullptr;
};
static void collectScopes(const design* d, const Listings& L,
                          std::vector<Scope>& out) {
    auto add = [&](const std::string& role, const BaseClass* o,
                   const VectorOftypespec* v) {
        if (!o) return;
        Scope sc;
        sc.tag = role + "|" + std::string(o->VpiName());
        sc.obj = o;
        sc.vec = v;
        out.push_back(sc);
    };
    add("DESIGN", d, d->Typespecs());
    auto pkgs = [&](const VectorOfpackage* v, const char* role) {
        if (!v) return;
        for (size_t i = 0; i < v->size(); ++i) {
            const package* p = v->at(i);
            if (!p) continue;
            add(std::string(role) + "[" + std::to_string(i) + "]", p,
                p->Typespecs());
            if (p->Class_defns())
                for (auto* c : *p->Class_defns())
                    if (c)
                        add(std::string(role) + "[" + std::to_string(i) +
                                "]/" + std::string(p->VpiName()) + "/class",
                            c, c->Typespecs());
        }
    };
    pkgs(d->AllPackages(), "ALL");
    pkgs(d->TopPackages(), "TOP");
    auto mods = [&](const VectorOfmodule_inst* v, const char* role) {
        if (!v) return;
        for (size_t i = 0; i < v->size(); ++i) {
            const module_inst* m = v->at(i);
            if (!m) continue;
            add(std::string(role) + "|" + std::string(m->VpiDefName()), m,
                m->Typespecs());
        }
    };
    mods(d->AllModules(), "ALLMOD");
    mods(d->TopModules(), "TOPMOD");
    (void)L;
}

static std::string tsRow(const typespec* t) {
    if (!t) return "<null>";
    char b[700];
    snprintf(b, sizeof b, "%-22s %-58s %4u:%-3u #%u",
             UhdmName(t->UhdmType()).data(), std::string(t->VpiName()).c_str(),
             t->VpiLineNo(), (unsigned)t->VpiColumnNo(), t->UhdmId());
    return b;
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr,
                "usage: ct180own <golden> <ours> [tsname] [scopetag]\n");
        return 2;
    }
    const char* tsWant = argc > 3 ? argv[3] : nullptr;
    const char* scWant = argc > 4 ? argv[4] : nullptr;
    Serializer sg, so;
    if (sg.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL golden\n"); return 3; }
    if (so.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL ours\n"); return 3; }
    const design* dg = topDesign(sg);
    const design* dou = topDesign(so);
    if (!dg || !dou) { printf("NO_DESIGN\n"); return 3; }
    Listings lg, lo;
    lg.build(dg);
    lo.build(dou);

    CompareContext c;
    int r = dg->Compare(dou, &c);
    printf("design::Compare r=%d\n", r);
    printf("HEAD LHS(golden) = %s\n", ident(c.m_failedLhs).c_str());
    printf("HEAD RHS(ours)   = %s\n", ident(c.m_failedRhs).c_str());
    const BaseClass* HR = c.m_failedRhs;
    const BaseClass* HL = c.m_failedLhs;

    // ---- STEP 1 — the head in context, BOTH sides ------------------------
    for (int side = 0; side < 2; ++side) {
        const BaseClass* H = side ? HR : HL;
        if (!H) continue;
        const Listings& L = side ? lo : lg;
        printf("HEAD %s parent chain:\n", side ? "RHS(ours)" : "LHS(golden)");
        for (const BaseClass* p = H->VpiParent(); p; p = p->VpiParent())
            printf("    < %s\n", ident(p).c_str());
        printf("HEAD %s listing: %s\n", side ? "RHS" : "LHS", L.of(H).c_str());
    }
    // every referrer of the head, on its OWN side, with the scope it sits in
    for (int side = 0; side < 2; ++side) {
        const BaseClass* H = side ? HR : HL;
        if (!H) continue;
        Serializer& S = side ? so : sg;
        const Listings& L = side ? lo : lg;
        printf("REFERRERS of the %s head:\n", side ? "OURS" : "GOLDEN");
        for (auto& kv : S.AllObjects()) {
            const BaseClass* X = kv.first;
            if (!X) continue;
            for (int t = 1; t <= 2100; ++t) {
                auto tup = X->GetByVpiType(t);
                const BaseClass* one = std::get<0>(tup);
                const std::vector<const BaseClass*>* vec = std::get<2>(tup);
                int idx = -1;
                if (one == H) idx = -2;
                if (vec)
                    for (size_t i = 0; i < vec->size(); ++i)
                        if (vec->at(i) == H) idx = (int)i;
                if (idx == -1) continue;
                printf("  %s  [%s]  vpiType=%d %s%s\n", ident(X).c_str(),
                       L.of(X).c_str(), t,
                       idx == -2 ? "(singular)"
                                 : ("(vector[" + std::to_string(idx) + "] of " +
                                    std::to_string(vec->size()) + ")")
                                       .c_str(),
                       "");
            }
        }
    }
    // the counterpart of the head on the other side, by face+parentPath
    if (HL && HR) {
        printf("FACE COUNTERPARTS of the golden head, in ours:\n");
        for (auto& kv : so.AllObjects()) {
            const BaseClass* Y = kv.first;
            if (!Y || Y->UhdmType() != HL->UhdmType()) continue;
            if (Y->VpiLineNo() != HL->VpiLineNo() ||
                Y->VpiColumnNo() != HL->VpiColumnNo())
                continue;
            printf("  ours %s [%s]\n", ident(Y).c_str(), lo.of(Y).c_str());
        }
        printf("FACE COUNTERPARTS of our head, in golden:\n");
        for (auto& kv : sg.AllObjects()) {
            const BaseClass* Y = kv.first;
            if (!Y || Y->UhdmType() != HR->UhdmType()) continue;
            if (Y->VpiLineNo() != HR->VpiLineNo() ||
                Y->VpiColumnNo() != HR->VpiColumnNo())
                continue;
            printf("  golden %s [%s]\n", ident(Y).c_str(), lg.of(Y).c_str());
        }
        (void)sameFace;
        (void)parentPath;
    }

    // ---- STEP 2 — THE TYPESPEC LISTING COPY MAP --------------------------
    std::vector<Scope> scg, sco;
    collectScopes(dg, lg, scg);
    collectScopes(dou, lo, sco);
    if (tsWant) {
        printf("\nTYPESPEC COPY MAP for a name containing \"%s\"%s%s\n", tsWant,
               scWant ? ", scope tag containing " : "", scWant ? scWant : "");
        for (int side = 0; side < 2; ++side) {
            auto& scs = side ? sco : scg;
            printf("  ---- %s ----\n", side ? "OURS" : "GOLDEN");
            std::vector<std::string> rows;
            for (auto& sc : scs) {
                if (scWant && sc.tag.find(scWant) == std::string::npos) continue;
                if (!sc.vec) continue;
                for (size_t i = 0; i < sc.vec->size(); ++i) {
                    const typespec* t = sc.vec->at(i);
                    if (!t) continue;
                    std::string nm(t->VpiName());
                    if (nm.find(tsWant) == std::string::npos) continue;
                    char b[1400];
                    snprintf(b, sizeof b, "    %-34s [%3zu/%3zu] %s",
                             sc.tag.c_str(), i, sc.vec->size(),
                             tsRow(t).c_str());
                    rows.push_back(b);
                }
            }
            std::sort(rows.begin(), rows.end());
            for (auto& s : rows) printf("%s\n", s.c_str());
            printf("    (%zu listing slots)\n", rows.size());
        }
    }

    // ---- STEP 3 — THE LISTING PAIRING, SIDE BY SIDE BY INDEX -------------
    if (scWant) {
        printf("\nLISTING PAIRING for scope tags containing \"%s\"\n", scWant);
        std::map<std::string, const Scope*> byTagG, byTagO;
        for (auto& s : scg) byTagG.emplace(s.tag, &s);
        for (auto& s : sco) byTagO.emplace(s.tag, &s);
        std::set<std::string> tags;
        for (auto& [k, v] : byTagG)
            if (k.find(scWant) != std::string::npos) tags.insert(k);
        for (auto& [k, v] : byTagO)
            if (k.find(scWant) != std::string::npos) tags.insert(k);
        for (auto& tag : tags) {
            const Scope* G = byTagG.count(tag) ? byTagG[tag] : nullptr;
            const Scope* O = byTagO.count(tag) ? byTagO[tag] : nullptr;
            size_t ng = G && G->vec ? G->vec->size() : 0;
            size_t no = O && O->vec ? O->vec->size() : 0;
            printf("  SCOPE %s  golden=%zu ours=%zu %s\n", tag.c_str(), ng, no,
                   ng == no ? "" : "  <-- COUNT GAP");
            for (size_t i = 0; i < (ng > no ? ng : no); ++i) {
                const typespec* a = (G && G->vec && i < ng) ? G->vec->at(i) : nullptr;
                const typespec* b = (O && O->vec && i < no) ? O->vec->at(i) : nullptr;
                bool same = a && b && a->UhdmType() == b->UhdmType() &&
                            std::string(a->VpiName()) == std::string(b->VpiName());
                printf("    [%3zu] %-1s G %-92s | O %s\n", i, same ? " " : "*",
                       tsRow(a).c_str(), tsRow(b).c_str());
            }
        }
    }
    return 0;
}
