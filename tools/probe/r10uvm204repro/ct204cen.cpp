// r10uvm204 — THE CENSUS.  One database in, keyed rows out, so golden and ours
// can be joined key-for-key (and golden-vs-golden calibrated FIRST).
//
// MEASUREMENT ONLY.  The official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the
// sole acceptance judge.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// Keys are PATH-FREE (our objects carry an EMPTY VpiFile — RESUME.md §9) and
// carry the whole owner chain by NAME, so a key means the same site in both
// databases and cannot collide across the ~500 for-loops of a UVM database.
//
// ROW FAMILIES
//   FI|  one row per for_stmt INIT statement: the init FORM (declaration vs
//        plain assignment vs no-init), the Lhs object kind, the Lhs typespec
//        kind + name, and the SITE CLASS.  This is the "for-loop init shapes
//        keyed by form x type kind x view" census.
//   AG|  one row per `Actual_group` carrier whose TARGET is (golden) or would
//        be (ours) a FOR-INIT LOOP VARIABLE, i.e. a `variables` parented at an
//        `assignment` parented at a `for_stmt`.  Value = BOUND/<null> plus the
//        target's site class.  This is where the head lives.
//   AGALL| the same for EVERY Actual_group carrier, bound or not — the WIDE
//        column that proves a fix moved nothing else.
//
// SITE CLASS (the "view" axis):
//   defview   — the chain reaches a class_defn (the class definition listing)
//   pkglist   — the subroutine's own name carries `::` and it hangs off a
//               package (the package-level listing of a class method, home or
//               clone; the package NAME is in the key so the two never merge)
//   modinst   — the chain reaches a module_inst (the elaborated view)
//   plain     — anything else
//
// build: g++ -O2 -std=c++17 ct204cen.cpp -I ~/.local/include \
//            -I ../r10ladder1repro -L ~/.local/lib64 -L ~/.local/lib \
//            -luhdm -lcapnp -lkj -o ct204cen
// usage: ct204cen <db.uhdm> <tag>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <map>
#include <string>
#include <vector>

using namespace UHDM;

enum FKind { F_TYPE = 0, F_PROP = 1, F_REL1 = 2, F_RELV = 3 };
struct Field { const char* name; int sel; FKind kind; };
static const std::map<std::string, std::vector<Field>> kFields = {
#include "ctfields.inc"
};

static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("<null>");
}
static std::string nameOf(const BaseClass* o) {
    if (!o) return "-";
    std::string n(o->VpiName());
    return n.empty() ? std::string("<unnamed>") : n;
}
static std::string lc(const BaseClass* o) {
    if (!o) return "-";
    char b[64];
    snprintf(b, sizeof b, "%u:%u", o->VpiLineNo(), (unsigned)o->VpiColumnNo());
    return b;
}
// PATH-FREE owner chain, by name — the census key's spine.
static std::string chainSig(const BaseClass* o) {
    std::string r;
    int g = 0;
    for (const BaseClass* p = o ? o->VpiParent() : nullptr; p && g < 32;
         p = p->VpiParent(), ++g) {
        const UHDM_OBJECT_TYPE t = p->UhdmType();
        if (t != uhdmpackage && t != uhdmclass_defn && t != uhdmmodule_inst &&
            t != uhdmfunction && t != uhdmtask && t != uhdmbegin &&
            t != uhdmnamed_begin && t != uhdmfor_stmt && t != uhdmassignment &&
            t != uhdmfork_stmt && t != uhdmnamed_fork)
            continue;
        r += "/";
        r += std::string(UhdmName(t));
        r += ":";
        r += std::string(p->VpiName());
    }
    return r;
}
static std::string siteClass(const BaseClass* o) {
    bool mod = false, cls = false, pkg = false;
    std::string sub, pkgname;
    for (const BaseClass* p = o; p; p = p->VpiParent()) {
        switch (p->UhdmType()) {
            case uhdmmodule_inst: mod = true; break;
            case uhdmclass_defn: cls = true; break;
            case uhdmpackage:
                pkg = true;
                if (pkgname.empty()) pkgname = std::string(p->VpiName());
                break;
            case uhdmfunction:
            case uhdmtask:
                if (sub.empty()) sub = std::string(p->VpiName());
                break;
            default: break;
        }
    }
    if (mod) return "modinst";
    if (cls) return "defview";
    if (pkg && sub.find("::") != std::string::npos) return "pkglist:" + pkgname;
    if (pkg) return "pkgplain:" + pkgname;
    return "plain";
}
static const BaseClass* rel1(const BaseClass* o, const char* fname) {
    auto it = kFields.find(kindOf(o));
    if (it == kFields.end()) return nullptr;
    for (const Field& f : it->second)
        if (f.kind == F_REL1 && !strcmp(f.name, fname) && f.sel)
            return std::get<0>(o->GetByVpiType(f.sel));
    return nullptr;
}
static bool hasRel1(const BaseClass* o, const char* fname) {
    auto it = kFields.find(kindOf(o));
    if (it == kFields.end()) return false;
    for (const Field& f : it->second)
        if (f.kind == F_REL1 && !strcmp(f.name, fname)) return true;
    return false;
}
// a FOR-INIT LOOP VARIABLE: a `variables` whose parent is an `assignment`
// whose parent is a `for_stmt` (Surelog CompileStmt.cpp compileForLoop, and
// our StmtEmit.cpp ForLoop arm, both build exactly this shape)
static bool isForInitVar(const BaseClass* o) {
    if (!o) return false;
    const BaseClass* p = o->VpiParent();
    if (!p || p->UhdmType() != uhdmassignment) return false;
    const BaseClass* q = p->VpiParent();
    return q && q->UhdmType() == uhdmfor_stmt;
}
// DECL (`for (T v = e; ...)`) vs ASSIGN (`for (v = e; ...)`).  BOTH writers
// give the plain-assignment form an Lhs variable with NO typespec at all
// (Surelog compiles it from the Hierarchical_identifier; our StmtEmit mints a
// bare ref_var), while every declaration form binds the written type.  The
// presence of a bound typespec is therefore the form, read the same way on
// both sides.
static const char* forInitForm(const BaseClass* o) {
    const BaseClass* rt = rel1(o, "Typespec");
    const typespec* a = rt ? ((const ref_typespec*)rt)->Actual_typespec() : nullptr;
    return a ? "DECL" : "ASSIGN";
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: ct204cen <db.uhdm> <tag>\n");
        return 2;
    }
    const std::string tag = argv[2];
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) {
        printf("RESTORE_FAIL %s\n", argv[1]);
        return 3;
    }
    std::vector<std::string> rows;
    char b[3000];

    // ---------------- FI| : for_stmt init shapes
    for (auto& kv : s.AllObjects()) {
        const BaseClass* X = (const BaseClass*)kv.first;
        if (!X || X->UhdmType() != uhdmfor_stmt) continue;
        const for_stmt* F = (const for_stmt*)X;
        std::vector<std::pair<std::string, const any*>> all;
        if (const any* one = F->VpiForInitStmt()) all.push_back({"SINGULAR", one});
        if (const VectorOfany* iv = F->VpiForInitStmts())
            for (size_t i = 0; i < iv->size(); i++)
                all.push_back({"VEC" + std::to_string(i), (*iv)[i]});
        const std::string site = siteClass(X);
        const std::string sig = chainSig(X);
        if (all.empty()) {
            snprintf(b, sizeof b, "FI|%s|%s|%s|%s|-\tNOINIT", tag.c_str(),
                     site.c_str(), lc(X).c_str(), sig.c_str());
            rows.push_back(b);
            continue;
        }
        for (size_t i = 0; i < all.size(); i++) {
            const any* st = all[i].second;
            std::string sk = kindOf(st), lk = "-", tk = "-", tn = "-", form = "-";
            std::string rk = "-";
            if (st && st->UhdmType() == uhdmassignment) {
                const assignment* A = (const assignment*)st;
                const expr* L = A->Lhs();
                if (!L) {
                    lk = "<null-Lhs>";
                } else {
                    lk = kindOf(L);
                    const BaseClass* rt = rel1(L, "Typespec");
                    const typespec* a =
                        rt ? ((const ref_typespec*)rt)->Actual_typespec() : nullptr;
                    tk = a ? kindOf(a) : (rt ? "<rt-null-actual>" : "<no-ref_typespec>");
                    tn = a ? nameOf(a) : "-";
                }
                rk = A->Rhs() ? kindOf(A->Rhs()) : "<null-Rhs>";
                // the FORM: a DECLARATION init spans from the written type, so
                // its Lhs variable's own line:col differs from the assignment's;
                // a PLAIN assignment init has no declared type at all.  The
                // robust discriminator that both writers honour is whether the
                // Lhs variable carries a bound typespec.
                form = (lk == "ref_var" && tk == "<no-ref_typespec>") ? "ASSIGN"
                       : (lk == "<null-Lhs>") ? "NOLHS" : "DECL";
            }
            snprintf(b, sizeof b, "FI|%s|%s|%s|%s|%s\t%s form=%s lhs=%s ts=%s tsname=%s rhs=%s",
                     tag.c_str(), site.c_str(), lc(X).c_str(), sig.c_str(),
                     all[i].first.c_str(), sk.c_str(), form.c_str(), lk.c_str(),
                     tk.c_str(), tn.c_str(), rk.c_str());
            rows.push_back(b);
        }
    }

    // ---------------- AG| / AGALL| : Actual_group binding state
    for (auto& kv : s.AllObjects()) {
        const BaseClass* X = (const BaseClass*)kv.first;
        if (!X || !hasRel1(X, "Actual_group")) continue;
        const BaseClass* A = rel1(X, "Actual_group");
        const std::string site = siteClass(X);
        const std::string sig = chainSig(X);
        const bool fi = isForInitVar(A);
        // The VALUE is JUDGE-RELEVANT only: bound-or-not, and the target's own
        // kind/name/span.  It deliberately does NOT carry the target's owner,
        // because SHARING vs COPYING an object is invisible to the judge (no
        // generated Compare reads VpiParent — RESUME.md §9), and golden SHARES
        // the home loop variable with every clone while we copy it.
        const std::string val =
            A ? ("BOUND " + kindOf(A) + " " + nameOf(A) + "@" + lc(A) +
                 (fi ? std::string(" FORINITVAR-") + forInitForm(A) : std::string()))
              : std::string("<null>");
        snprintf(b, sizeof b, "AGALL|%s|%s|%s|%s|%s\t%s", tag.c_str(),
                 site.c_str(), kindOf(X).c_str(), nameOf(X).c_str(),
                 (lc(X) + "|" + sig).c_str(), val.c_str());
        rows.push_back(b);
        if (!fi) continue;
        snprintf(b, sizeof b, "AG|%s|%s|%s|%s|%s\t%s", tag.c_str(),
                 site.c_str(), kindOf(X).c_str(), nameOf(X).c_str(),
                 (lc(X) + "|" + sig).c_str(), val.c_str());
        rows.push_back(b);
    }

    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) printf("%s\n", r.c_str());
    fprintf(stderr, "ROWS=%zu\n", rows.size());
    return 0;
}
