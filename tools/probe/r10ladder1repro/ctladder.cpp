// r10ladder1 — THE MULTI-HEAD COMPARATOR ("the ladder").
//
// MEASUREMENT-ONLY.  THIS TOOL IS NOT AN ACCEPTANCE JUDGE.  The official
// `uhdm-cmp` binary (~/git-repos/UHDM/build/bin/uhdm-cmp) remains the SOLE
// authority for CMP_EQUAL / CMP_NOTEQUAL and for every gate in this campaign.
// ctladder answers a question uhdm-cmp cannot: uhdm-cmp stops at the FIRST
// disagreeing object, so the campaign has never seen how many more there are.
//
// ── HOW IT WORKS ─────────────────────────────────────────────────────────
// Every generated `<kind>::Compare` opens with
//     if (!context->m_visited.insert(this).second) return r;   // LHS-keyed
// so an LHS object that is ALREADY in `m_visited` compares EQUAL instantly.
// The ladder runs the OFFICIAL `design::Compare` unchanged, records the head
// (`m_failedLhs`, `m_failedRhs`), MASKS it by seeding `m_visited` in a FRESH
// context, and re-runs — to fixpoint (r == 0) or to an unmaskable shape.  No
// UHDM source is patched and no compare semantics are altered: the walk
// order, the field order and the failure points are the shipped ones.
//
// ── WHY THERE IS NO "FAST" INCREMENTAL MODE (a REFUTED design) ───────────
// The obvious optimisation — keep ONE CompareContext and just add the mask
// between rungs — is WRONG, and it fails silently in the direction that
// flatters the tool.  `design::Compare` inserts the DESIGN ITSELF into
// `m_visited` on entry, and so does every object on the path down to the
// failure.  A second call on the same context therefore returns 0 at the
// first line and the tool reports "FIXPOINT" for a database it never looked
// at.  Measured: SimpleUVM/default reports 1 rung reusing the context and
// hundreds with a fresh one.  Every rung here uses a FRESH context seeded
// with the accumulated mask only.
//
// ── THE THREE MASKING SHAPES (all measured, none assumed) ────────────────
//  (a) failure recorded ON the object    → seeding it works, MASK-LEVEL=0.
//  (b) `SafeCompare(lhs, rhs=nullptr)`   → m_failedLhs is set but its
//      `Compare` is NEVER CALLED, so seeding it is INERT.  Detected (head
//      unchanged) and escalated, MASK-LEVEL=1,2,…
//  (c) `SafeCompare(lhs=nullptr, rhs)`   → m_failedLhs is NULL; there is no
//      golden object to seed at all.
// For (b) and (c) the enclosing object is found by the REFERRER chain — who
// POINTS AT the failing object — because `VpiParent` is the tree parent and
// the object that was mid-`Compare` is very often a REFERRER instead (the
// YosysVerx head is a top module reached through a field of another object,
// not through `design::AllModules`).  Referrer chains are indexed on both
// sides; a cross-side hop uses a tree-position key join and is reported.
//
// ── CASCADE MASKING (read the ladder length with this in hand) ───────────
// The short-circuit is at the TOP of `Compare`, so masking an object skips
// its ENTIRE SUBTREE.  Ladder length is therefore the number of MAXIMAL
// disagreeing subtree roots on the walk — a LOWER BOUND on the defect count,
// never an upper one.  Each rung prints `masked=` (golden objects under the
// masked node, capped) so the suppressed volume is visible, and `vis=` (the
// golden objects proven equal up to that rung) so progress is visible too.
//
// ── THE FIRST DIFFERING FIELD ────────────────────────────────────────────
// Field order is NOT invented here: `ctfields.inc` is generated from UHDM's
// own `<kind>::Compare` bodies (see genfields.py), with the base class's
// fields spliced in where `basetype_t::Compare` is called, and each field
// carries the vpi selector that reads it back through the public
// `GetVpiPropertyValue` / `GetByVpiType` introspection.  The 24 fields UHDM
// exposes no selector for are read by hand-written fallbacks below — a
// dropped field would print "no differing field" for a pair that differs in
// exactly that field.
//
// ── GUARDS ───────────────────────────────────────────────────────────────
//   * `--calib` compares a database against ITSELF (two independent restores)
//     and MUST produce ZERO rungs; a detector that flags everything is a
//     broken detector.
//   * a rung whose field scan finds NOTHING is printed as FIELD=<none> with
//     the shape NO-FIELD-DIFF — never silently dropped.
//   * a mask that does not move the head is escalated and, if the whole
//     candidate chain is inert, the row STOPS with UNMASKABLE — never
//     skipped, never counted as agreement.
//   * the design ROOT is never masked: masking it returns 0 for the whole
//     comparison and would print FIXPOINT for "I stopped looking".
//   * file paths are reduced to BASENAMES: the dump paths embed the workdir
//     and would otherwise split families and rot the artifacts.
//   * every printed object carries its `#UhdmId`.  Without it `ident()` is NOT
//     INJECTIVE — `constant@:0:0-0:0` names hundreds of distinct objects — and
//     a reader cannot tell 26 defects from one defect repeated 26 times
//     (r10ladder1's Rggen row: 26 rungs that print the same L and the same R).
//   * every rung prints the TRUE volume its mask suppresses and the row prints
//     `suppressed=` — the union of every masked subtree.  A ladder is a LOWER
//     bound and `suppressed/golden_objs` is how loose that bound is; a rung
//     that hides >=1% of the golden database is marked `CASCADE`.
//
// ── vladder1 (adversarial verification) CHANGES ──────────────────────────
//   * BISECTION IS NOW CASCADE-AVERSE.  The named-candidate path already
//     preferred the smallest mask, but the BISECTION fallback had no volume
//     preference at all — and it is the path that masked golden's whole
//     `package(uvm_pkg)` at rung 9/89 of BuildUVMPkg, rung 13/47 of SimpleUVM,
//     rung 13/76 of Scoreboard and rung 39/59 of SeqDriver, i.e. exactly the
//     mask the file's own §1.2 says the tool avoids.  Bisection now runs first
//     over the pool with the mega-objects REMOVED and only falls back to the
//     full pool (marked CASCADE) when that finds nothing.
//
// build:
//   g++ -O2 -std=c++17 ctladder.cpp -I ~/.local/include
//       -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ctladder
// usage: ctladder <golden.uhdm> <ours.uhdm> [--calib] [--max=N]
//                 [--budget=SEC] [--head1] [--refute-fast]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/vpi_visitor.h>

#include <algorithm>
#include <chrono>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <filesystem>
#include <iostream>
#include <map>
#include <set>
#include <string>
#include <unordered_map>
#include <unordered_set>
#include <vector>

using namespace UHDM;

// ───────────────────────── field table ──────────────────────────────────
enum FKind { F_TYPE = 0, F_PROP = 1, F_REL1 = 2, F_RELV = 3 };
struct Field {
    const char* name;
    int sel;
    FKind kind;
};
static const std::map<std::string, std::vector<Field>> kFields = {
#include "ctfields.inc"
};

// ───────────────────────── small helpers ────────────────────────────────
static std::string base(std::string_view p) {
    size_t i = p.find_last_of('/');
    return std::string(i == std::string_view::npos ? p : p.substr(i + 1));
}
static std::string spanOf(const BaseClass* o) {
    char b[192];
    snprintf(b, sizeof b, "%s:%u:%u-%u:%u", base(o->VpiFile()).c_str(), o->VpiLineNo(),
             (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(), (unsigned)o->VpiEndColumnNo());
    return b;
}
static std::string ident(const BaseClass* o) {
    if (!o) return "<null>";
    std::string s = UhdmName(o->UhdmType());
    if (!o->VpiName().empty()) s += "(" + std::string(o->VpiName()) + ")";
    // `#UhdmId` is not decoration.  Without it this string is NOT injective:
    // an unnamed constant with no span prints as `constant@:0:0-0:0` for every
    // one of hundreds of distinct objects, and the artifact cannot distinguish
    // "26 separate defects" from "one defect reported 26 times".
    return s + "@" + spanOf(o) + "#" + std::to_string(o->UhdmId());
}
static std::string chainOf(const BaseClass* o, int n = 8) {
    std::string s;
    for (int i = 0; i < n && o; i++) {
        s += (i ? " < " : "") + ident(o);
        o = o->VpiParent();
    }
    return s;
}
// chain KEY: identity of a position in the tree, used to join an object to
// its twin on the other side.  Never used to invent a head — only to find the
// enclosing object to mask, and every use is trialled before it is believed.
static std::string chainKey(const BaseClass* o, int n = 10) {
    std::string s;
    for (int i = 0; i < n && o; i++) {
        s += (i ? "<" : "") + std::string(UhdmName(o->UhdmType())) + ":" +
             std::string(o->VpiName()) + ":" + spanOf(o);
        o = o->VpiParent();
    }
    return s;
}

// ─────────────────── field readers (selector + fallbacks) ───────────────
template <typename T>
static bool vecOf(const std::vector<T*>* v, bool& present, size_t& n) {
    present = v != nullptr;
    n = v ? v->size() : 0;
    return true;
}
// The 24 fields UHDM exposes no vpi selector for.  Hand-written so that a
// container disagreement on (e.g.) design::AllModules is REPORTED, not
// swallowed as "no differing field".
static bool fallbackVec(const BaseClass* o, const char* f, bool& present, size_t& n) {
    if (auto* d = any_cast<const design*>((const any*)o)) {
        if (!strcmp(f, "AllPackages")) return vecOf(d->AllPackages(), present, n);
        if (!strcmp(f, "TopPackages")) return vecOf(d->TopPackages(), present, n);
        if (!strcmp(f, "AllClasses")) return vecOf(d->AllClasses(), present, n);
        if (!strcmp(f, "AllInterfaces")) return vecOf(d->AllInterfaces(), present, n);
        if (!strcmp(f, "AllUdps")) return vecOf(d->AllUdps(), present, n);
        if (!strcmp(f, "AllPrograms")) return vecOf(d->AllPrograms(), present, n);
        if (!strcmp(f, "AllModules")) return vecOf(d->AllModules(), present, n);
        if (!strcmp(f, "TopModules")) return vecOf(d->TopModules(), present, n);
    }
    if (auto* i = any_cast<const instance*>((const any*)o))
        if (!strcmp(f, "Array_nets")) return vecOf(i->Array_nets(), present, n);
    if (auto* fs = any_cast<const for_stmt*>((const any*)o)) {
        if (!strcmp(f, "VpiForInitStmts")) return vecOf(fs->VpiForInitStmts(), present, n);
        if (!strcmp(f, "VpiForIncStmts")) return vecOf(fs->VpiForIncStmts(), present, n);
    }
    if (auto* m = any_cast<const module_inst*>((const any*)o))
        if (!strcmp(f, "Module_arrays")) return vecOf(m->Module_arrays(), present, n);
    if (auto* vb = any_cast<const var_bit*>((const any*)o))
        if (!strcmp(f, "Expr_indexes")) return vecOf(vb->Expr_indexes(), present, n);
    if (auto* vs = any_cast<const var_select*>((const any*)o))
        if (!strcmp(f, "Exprs")) return vecOf(vs->Exprs(), present, n);
    return false;
}
// NULL-PRESERVING on purpose: index identity is what lets a null ELEMENT be
// located, and an element-dropping copy silently renumbers every index.
static bool fallbackVecPtr(const BaseClass* o, const char* f,
                           std::vector<const BaseClass*>& out) {
    auto take = [&](auto* v) {
        if (v)
            for (auto* e : *v) out.push_back((const BaseClass*)e);
        return true;
    };
    if (auto* d = any_cast<const design*>((const any*)o)) {
        if (!strcmp(f, "AllPackages")) return take(d->AllPackages());
        if (!strcmp(f, "TopPackages")) return take(d->TopPackages());
        if (!strcmp(f, "AllClasses")) return take(d->AllClasses());
        if (!strcmp(f, "AllInterfaces")) return take(d->AllInterfaces());
        if (!strcmp(f, "AllUdps")) return take(d->AllUdps());
        if (!strcmp(f, "AllPrograms")) return take(d->AllPrograms());
        if (!strcmp(f, "AllModules")) return take(d->AllModules());
        if (!strcmp(f, "TopModules")) return take(d->TopModules());
    }
    if (auto* i = any_cast<const instance*>((const any*)o))
        if (!strcmp(f, "Array_nets")) return take(i->Array_nets());
    if (auto* fs = any_cast<const for_stmt*>((const any*)o)) {
        if (!strcmp(f, "VpiForInitStmts")) return take(fs->VpiForInitStmts());
        if (!strcmp(f, "VpiForIncStmts")) return take(fs->VpiForIncStmts());
    }
    if (auto* m = any_cast<const module_inst*>((const any*)o))
        if (!strcmp(f, "Module_arrays")) return take(m->Module_arrays());
    if (auto* vb = any_cast<const var_bit*>((const any*)o))
        if (!strcmp(f, "Expr_indexes")) return take(vb->Expr_indexes());
    if (auto* vs = any_cast<const var_select*>((const any*)o))
        if (!strcmp(f, "Exprs")) return take(vs->Exprs());
    return false;
}
static bool fallbackRel1(const BaseClass* o, const char* f, const BaseClass*& out) {
    if (auto* tm = any_cast<const typespec_member*>((const any*)o))
        if (!strcmp(f, "Default_value")) {
            out = tm->Default_value();
            return true;
        }
    return false;
}

// Every outgoing edge of an object, as (field-name, target).  Used for the
// referrer index and for masked-subtree sizing.
static void edgesOf(const BaseClass* o,
                    std::vector<std::pair<const char*, const BaseClass*>>& out) {
    auto it = kFields.find(UhdmName(o->UhdmType()));
    if (it == kFields.end()) return;
    for (const Field& f : it->second) {
        if (f.kind == F_REL1) {
            const BaseClass* t = nullptr;
            if (f.sel) t = std::get<0>(o->GetByVpiType(f.sel));
            else if (!fallbackRel1(o, f.name, t)) continue;
            if (t) out.push_back({f.name, t});
        } else if (f.kind == F_RELV) {
            if (f.sel) {
                if (auto* v = std::get<2>(o->GetByVpiType(f.sel)))
                    for (auto* e : *v)
                        if (e) out.push_back({f.name, e});
            } else {
                std::vector<const BaseClass*> tmp;
                if (fallbackVecPtr(o, f.name, tmp))
                    for (auto* e : tmp)
                        if (e) out.push_back({f.name, e});
            }
        }
    }
}

struct PropVal {
    bool isStr = false;
    int64_t i = 0;
    std::string s;
};
static PropVal readProp(const BaseClass* o, int sel) {
    PropVal v;
    auto pv = o->GetVpiPropertyValue(sel);
    if (std::holds_alternative<const char*>(pv)) {
        const char* p = std::get<const char*>(pv);
        v.isStr = true;
        v.s = p ? p : "";
    } else {
        v.i = std::get<int64_t>(pv);
    }
    return v;
}
static std::string showProp(const PropVal& v) {
    return v.isStr ? ("\"" + v.s + "\"") : std::to_string(v.i);
}

// ───────────────────────── value-shape normalisation ────────────────────
// The family key must survive renaming and re-numbering, so string values are
// reduced to a SHAPE.  Digit runs collapse to '#', and the campaign's common
// shapes — one side empty, one side a prefix/suffix of the other — are named
// outright so a cluster is not split by its instance names.
static std::string digitFold(const std::string& s) {
    std::string o;
    bool ind = false;
    for (char c : s) {
        if (isdigit((unsigned char)c)) {
            if (!ind) o += '#';
            ind = true;
        } else {
            ind = false;
            o += c;
        }
    }
    return o;
}
static std::string clip(const std::string& s, size_t n = 44) {
    return s.size() <= n ? s : s.substr(0, n) + "…";
}
static std::string strShape(const std::string& g, const std::string& o) {
    if (g.empty() && !o.empty()) return "G-EMPTY";
    if (!g.empty() && o.empty()) return "O-EMPTY";
    if (g.size() > o.size() && g.compare(g.size() - o.size(), o.size(), o) == 0)
        return "G-EXTRA-PREFIX(" + clip(digitFold(g.substr(0, g.size() - o.size()))) + ")";
    if (o.size() > g.size() && o.compare(o.size() - g.size(), g.size(), g) == 0)
        return "O-EXTRA-PREFIX(" + clip(digitFold(o.substr(0, o.size() - g.size()))) + ")";
    if (g.size() > o.size() && g.compare(0, o.size(), o) == 0)
        return "G-EXTRA-SUFFIX(" + clip(digitFold(g.substr(o.size()))) + ")";
    if (o.size() > g.size() && o.compare(0, g.size(), g) == 0)
        return "O-EXTRA-SUFFIX(" + clip(digitFold(o.substr(g.size()))) + ")";
    if (digitFold(g) == digitFold(o)) return "DIGITS-ONLY";
    return "TEXT:" + clip(digitFold(g)) + "|" + clip(digitFold(o));
}

struct Diff {
    std::string field, shape, gval, oval;
    bool found = false;
};
static Diff firstDiff(const BaseClass* L, const BaseClass* R) {
    Diff d;
    if (!L || !R) {
        d.field = L ? "<rhs-null>" : "<lhs-null>";
        d.shape = L ? "MISSING-OURS" : "EXTRA-OURS";
        d.found = true;
        return d;
    }
    if (L->UhdmType() != R->UhdmType()) {
        d.field = "VpiType";
        d.shape = "KIND:" + UhdmName(L->UhdmType()) + ">" + UhdmName(R->UhdmType());
        d.gval = UhdmName(L->UhdmType());
        d.oval = UhdmName(R->UhdmType());
        d.found = true;
        return d;
    }
    auto it = kFields.find(UhdmName(L->UhdmType()));
    if (it == kFields.end()) return d;
    for (const Field& f : it->second) {
        if (f.kind == F_TYPE) continue;
        if (f.kind == F_PROP) {
            if (!f.sel) continue;
            PropVal g = readProp(L, f.sel), o = readProp(R, f.sel);
            if (g.isStr == o.isStr && (g.isStr ? g.s == o.s : g.i == o.i)) continue;
            d.field = f.name;
            d.gval = showProp(g);
            d.oval = showProp(o);
            d.shape = (g.isStr || o.isStr)
                          ? strShape(g.isStr ? g.s : "", o.isStr ? o.s : "")
                          : (g.i > o.i ? "INT:G>O" : "INT:G<O");
            d.found = true;
            return d;
        }
        if (f.kind == F_REL1) {
            const BaseClass *g = nullptr, *o = nullptr;
            bool ok = false;
            if (f.sel) {
                g = std::get<0>(L->GetByVpiType(f.sel));
                o = std::get<0>(R->GetByVpiType(f.sel));
                ok = true;
            } else
                ok = fallbackRel1(L, f.name, g) && fallbackRel1(R, f.name, o);
            if (!ok) continue;
            if ((g == nullptr) == (o == nullptr)) continue;  // both present → a LATER rung
            d.field = f.name;
            d.shape = g ? "REL1:MISSING-OURS" : "REL1:EXTRA-OURS";
            d.gval = g ? ident(g) : "<null>";
            d.oval = o ? ident(o) : "<null>";
            d.found = true;
            return d;
        }
        // F_RELV — only a SIZE/presence disagreement is diagnosable here; an
        // element-wise disagreement is the business of a later rung.
        bool gp = false, op = false;
        size_t gn = 0, on = 0;
        if (f.sel) {
            auto* gv = std::get<2>(L->GetByVpiType(f.sel));
            auto* ov = std::get<2>(R->GetByVpiType(f.sel));
            gp = gv != nullptr;
            op = ov != nullptr;
            gn = gv ? gv->size() : 0;
            on = ov ? ov->size() : 0;
        } else if (!(fallbackVec(L, f.name, gp, gn) && fallbackVec(R, f.name, op, on)))
            continue;
        if (gn != on) {
            d.field = f.name;
            d.shape = gn > on ? "VEC:G>O" : "VEC:G<O";
            d.gval = (gp ? "" : "null/") + std::to_string(gn);
            d.oval = (op ? "" : "null/") + std::to_string(on);
            d.found = true;
            return d;
        }
        // EQUAL SIZES still hide a diagnosable failure: `SafeCompare(lhs->at(i),
        // rhs->at(i))` fires on a NULL ELEMENT on one side.  Skipping this case
        // is what made the YosysVerx head report "no differing field" while a
        // one-object mask cleared it.  Only null-vs-non-null is claimed here;
        // two non-null elements that disagree are a LATER rung's head.
        if (f.sel && gn) {
            auto* gv = std::get<2>(L->GetByVpiType(f.sel));
            auto* ov = std::get<2>(R->GetByVpiType(f.sel));
            if (gv && ov)
                for (size_t i = 0; i < gn; i++)
                    if (((*gv)[i] == nullptr) != ((*ov)[i] == nullptr)) {
                        d.field = std::string(f.name) + "[" + std::to_string(i) + "]";
                        d.shape = (*gv)[i] ? "VECELEM:MISSING-OURS" : "VECELEM:EXTRA-OURS";
                        d.gval = (*gv)[i] ? ident((*gv)[i]) : "<null>";
                        d.oval = (*ov)[i] ? ident((*ov)[i]) : "<null>";
                        d.found = true;
                        return d;
                    }
        } else if (!f.sel && gn) {
            std::vector<const BaseClass*> gvv, ovv;
            if (fallbackVecPtr(L, f.name, gvv) && fallbackVecPtr(R, f.name, ovv) &&
                gvv.size() == ovv.size())
                for (size_t i = 0; i < gvv.size(); i++)
                    if ((gvv[i] == nullptr) != (ovv[i] == nullptr)) {
                        d.field = std::string(f.name) + "[" + std::to_string(i) + "]";
                        d.shape = gvv[i] ? "VECELEM:MISSING-OURS" : "VECELEM:EXTRA-OURS";
                        d.gval = gvv[i] ? ident(gvv[i]) : "<null>";
                        d.oval = ovv[i] ? ident(ovv[i]) : "<null>";
                        d.found = true;
                        return d;
                    }
        }
        continue;
    }
    return d;
}

// ───────────────────────── masked subtree volume ────────────────────────
// The UNION of every masked subtree — the golden objects the row has stopped
// looking at.  `maxvis` says how deep the walk got; this says how much of the
// walk was bought by refusing to look, and `suppressed/golden_objs` is exactly
// how loose the "ladder length is a lower bound" caveat is in practice.
static void collectSubtree(const BaseClass* o, std::unordered_set<const BaseClass*>& out) {
    if (!o) return;
    std::vector<const BaseClass*> st{o};
    std::vector<std::pair<const char*, const BaseClass*>> e;
    while (!st.empty()) {
        const BaseClass* c = st.back();
        st.pop_back();
        if (!out.insert(c).second) continue;
        e.clear();
        edgesOf(c, e);
        for (auto& [f, t] : e)
            if (t) st.push_back(t);
    }
}

static size_t subtreeSize(const BaseClass* o, size_t cap) {
    if (!o) return 0;
    std::unordered_set<const BaseClass*> seen;
    std::vector<const BaseClass*> st{o};
    std::vector<std::pair<const char*, const BaseClass*>> e;
    while (!st.empty() && seen.size() < cap) {
        const BaseClass* c = st.back();
        st.pop_back();
        if (!seen.insert(c).second) continue;
        e.clear();
        edgesOf(c, e);
        for (auto& [f, t] : e) st.push_back(t);
    }
    return seen.size();
}


// ─────────────────── the PRECISE null edge ──────────────────────────────
// Shapes (b) and (c) are `SafeCompare` calls where ONE SIDE IS NULL, and the
// object that differs is the one HOLDING that null — the referrer.  Naming
// "some field of some referrer that happens to differ" would be a guess, so
// this locator only reports a referrer whose field REALLY points at the
// failing object on one side and is REALLY null on the other.  It returns the
// pair to diff, the field, and the object to MASK; a miss returns false and
// the caller falls back to the generic scan and says so.
struct NullEdge {
    const BaseClass* gx = nullptr;  // golden holder
    const BaseClass* ox = nullptr;  // ours holder
    std::string field, shape, gval, oval;
    bool found = false;
};
static bool fieldTargets(const BaseClass* o, const Field& f, const BaseClass*& one,
                         const std::vector<const BaseClass*>*& vec,
                         std::vector<const BaseClass*>& buf) {
    one = nullptr;
    vec = nullptr;
    if (f.kind == F_REL1) {
        if (f.sel) one = std::get<0>(o->GetByVpiType(f.sel));
        else if (!fallbackRel1(o, f.name, one)) return false;
        return true;
    }
    if (f.kind == F_RELV) {
        if (f.sel) {
            vec = std::get<2>(o->GetByVpiType(f.sel));
            return true;
        }
        // the selector-less vectors (design::AllPackages and friends) are
        // exactly where a package-shaped head lives, so they are NOT skipped
        buf.clear();
        if (!fallbackVecPtr(o, f.name, buf)) return false;
        vec = &buf;
        return true;
    }
    return false;
}
static NullEdge nullEdge(const BaseClass* holderA, const BaseClass* holderB,
                         const BaseClass* target, bool aIsGolden) {
    NullEdge e;
    if (!holderA || !holderB || !target) return e;
    if (holderA->UhdmType() != holderB->UhdmType()) return e;
    auto it = kFields.find(UhdmName(holderA->UhdmType()));
    if (it == kFields.end()) return e;
    for (const Field& f : it->second) {
        const BaseClass *a1 = nullptr, *b1 = nullptr;
        const std::vector<const BaseClass*>*av = nullptr;
        const std::vector<const BaseClass*>*bv = nullptr;
        std::vector<const BaseClass*> abuf, bbuf;
        if (!fieldTargets(holderA, f, a1, av, abuf)) continue;
        if (!fieldTargets(holderB, f, b1, bv, bbuf)) continue;
        if (f.kind == F_REL1) {
            if (a1 == target && b1 == nullptr) {
                e.field = f.name;
                e.shape = aIsGolden ? "REL1:MISSING-OURS" : "REL1:EXTRA-OURS";
                e.gval = aIsGolden ? ident(target) : "<null>";
                e.oval = aIsGolden ? "<null>" : ident(target);
                e.found = true;
                break;
            }
            continue;
        }
        if (!av || !bv || av->size() != bv->size()) continue;
        for (size_t i = 0; i < av->size(); i++)
            if ((*av)[i] == target && (*bv)[i] == nullptr) {
                e.field = std::string(f.name) + "[" + std::to_string(i) + "]";
                e.shape = aIsGolden ? "VECELEM:MISSING-OURS" : "VECELEM:EXTRA-OURS";
                e.gval = aIsGolden ? ident(target) : "<null>";
                e.oval = aIsGolden ? "<null>" : ident(target);
                e.found = true;
                break;
            }
        if (e.found) break;
    }
    if (e.found) {
        e.gx = aIsGolden ? holderA : holderB;
        e.ox = aIsGolden ? holderB : holderA;
    }
    return e;
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr,
                "usage: ctladder <golden.uhdm> <ours.uhdm> [--calib] [--max=N] "
                "[--budget=SEC] [--head1] [--refute-fast]\n");
        return 2;
    }
    bool calib = false, head1 = false, refute = false;
    size_t maxRungs = 20000;
    double budget = 1200.0;
    for (int i = 3; i < argc; i++) {
        std::string s = argv[i];
        if (s == "--calib") calib = true;
        else if (s == "--head1") head1 = true;
        else if (s == "--refute-fast") refute = true;
        else if (s.rfind("--max=", 0) == 0) maxRungs = strtoul(s.c_str() + 6, nullptr, 10);
        else if (s.rfind("--budget=", 0) == 0) budget = strtod(s.c_str() + 9, nullptr);
        else { fprintf(stderr, "FATAL: unknown arg %s\n", s.c_str()); return 2; }
    }
    // CALIBRATION compares golden with golden through two INDEPENDENT restores
    // of the same file, so the pointers differ and the walk is real work rather
    // than an identity short-circuit.
    const char* fg = argv[1];
    const char* fo = calib ? argv[1] : argv[2];

    Serializer sg, so;
    auto hg = sg.Restore(std::filesystem::path(fg));
    auto ho = so.Restore(std::filesystem::path(fo));
    if (hg.empty() || ho.empty()) {
        fprintf(stderr, "RESTORE FAILED\n");
        return 3;
    }
    const design* dg = (const design*)((const uhdm_handle*)hg[0])->object;
    const design* dobj = (const design*)((const uhdm_handle*)ho[0])->object;
    const size_t gObjs = sg.AllObjects().size();

    printf("# ctladder MEASUREMENT-ONLY — uhdm-cmp remains the sole judge\n");
    printf("# GOLDEN(LHS) %s\n# OURS  (RHS) %s\n", fg, fo);
    printf("# %s max=%zu budget=%.0fs  golden_objs=%zu ours_objs=%zu\n",
           calib ? "calib" : "ladder", maxRungs, budget, gObjs, so.AllObjects().size());

    if (head1) {  // reproduce uhdm-cmp's own output byte-for-byte on stderr
        CompareContext c;
        if (dg->Compare(dobj, &c) != 0) {
            if (c.m_failedLhs) {
                std::cerr << "LHS:" << std::endl;
                std::cerr << UHDM::decompile(c.m_failedLhs);
            } else
                std::cerr << "LHS: <null>" << std::endl;
            if (c.m_failedRhs) {
                std::cerr << "RHS:" << std::endl;
                std::cerr << UHDM::decompile(c.m_failedRhs);
            } else
                std::cerr << "RHS: <null>" << std::endl;
            return -1;
        }
        return 0;
    }

    if (refute) {  // the REFUTATION of the incremental design, kept runnable
        CompareContext c;
        int r1 = dg->Compare(dobj, &c);
        bool rootVisited = c.m_visited.count(dg) != 0;
        c.m_failedLhs = c.m_failedRhs = nullptr;
        int r2 = dg->Compare(dobj, &c);
        printf("[S] REFUTE-FAST r1=%d r2=%d design_in_visited=%d visited=%zu — "
               "reusing one context makes the SECOND call return %d without "
               "comparing anything\n",
               r1, r2, (int)rootVisited, c.m_visited.size(), r2);
        return 0;
    }

    // ── indices, all built lazily and only when a rung needs them ────────
    std::unordered_multimap<std::string, const BaseClass*> gIndex, oIndex;
    // REFERRERS are a MULTI-map on purpose: keeping only the first one made
    // the design (which lists every module) shadow the real referrer and the
    // YosysVerx head came out ROOT-BLOCKED when a one-level mask cleared it.
    std::unordered_multimap<const BaseClass*, std::pair<const BaseClass*, const char*>>
        gRef, oRef;
    bool gIx = false, oIx = false, gRx = false, oRx = false;
    // `Serializer::AllObjects()` is `std::map<const BaseClass*, uint32_t>` —
    // ORDERED BY ADDRESS.  Iterating it directly makes the INSERTION ORDER of
    // these indices address-dependent, which makes `equal_range` order
    // address-dependent, which makes the CANDIDATE order — and therefore the
    // whole ladder — address-dependent.  The campaign's standing law is that
    // address order must never reach a result, so every index is built in
    // UhdmId order instead.
    auto byId = [](Serializer& s) {
        std::vector<const BaseClass*> v;
        for (const auto& [obj, id] : s.AllObjects())
            if (obj) v.push_back(obj);
        std::sort(v.begin(), v.end(), [](const BaseClass* a, const BaseClass* b) {
            return a->UhdmId() != b->UhdmId() ? a->UhdmId() < b->UhdmId() : a < b;
        });
        return v;
    };
    auto build = [&](Serializer& s, std::unordered_multimap<std::string, const BaseClass*>& ix,
                     bool& done) {
        if (done) return;
        done = true;
        for (const BaseClass* obj : byId(s)) ix.emplace(chainKey(obj), obj);
    };
    auto buildRef = [&](Serializer& s,
                        std::unordered_multimap<const BaseClass*,
                                                std::pair<const BaseClass*, const char*>>& rx,
                        bool& done) {
        if (done) return;
        done = true;
        std::vector<std::pair<const char*, const BaseClass*>> e;
        for (const BaseClass* obj : byId(s)) {
            e.clear();
            edgesOf(obj, e);
            for (auto& [f, t] : e) rx.emplace(t, std::make_pair(obj, f));
        }
    };
    auto twin = [&](std::unordered_multimap<std::string, const BaseClass*>& ix,
                    const BaseClass* o) -> const BaseClass* {
        if (!o) return nullptr;
        auto rg = ix.equal_range(chainKey(o));
        return std::distance(rg.first, rg.second) == 1 ? rg.first->second : nullptr;
    };

    std::unordered_set<const BaseClass*> mask;
    // The context is handed back to the caller because `m_visited` is the ONLY
    // evidence of which golden objects the walk was actually inside when it
    // failed.  A referrer that is NOT in it cannot be the enclosing Compare, and
    // filtering by it turns "thousands of objects point at uvm_pkg" into the
    // handful that were on the path.
    auto runFresh = [&](CompareContext& c) {
        for (const BaseClass* m : mask) c.m_visited.insert(m);
        int r = dg->Compare(dobj, &c);
        return r;
    };

    // ── BISECTION: find the blocking object by MEASUREMENT ──────────────
    // Masking can only turn a sub-result from FAIL to EQUAL, never the other
    // way, so the first failure can only move LATER as the mask grows: the
    // predicate "this mask moves the head" is MONOTONE in the mask, and a
    // binary search over the objects the walk actually entered is therefore
    // sound.  This is the answer to the shapes the heuristic cannot name — a
    // `SafeCompare` whose holder no key join can find — and it costs
    // ~log2(|visited|) whole-design compares instead of a guess.
    // The pool is ordered by UhdmId, NOT by address: address order is not
    // stable across runs and the ladder must be.
    auto poolMoved = [&](const std::vector<const BaseClass*>& extra, const BaseClass* L,
                         const BaseClass* R, size_t n) {
        CompareContext c;
        for (const BaseClass* m : mask) c.m_visited.insert(m);
        for (size_t i = 0; i < n; i++) c.m_visited.insert(extra[i]);
        int r = dg->Compare(dobj, &c);
        return r == 0 || c.m_failedLhs != L || c.m_failedRhs != R;
    };

    auto t0 = std::chrono::steady_clock::now();
    auto secs = [&] {
        return std::chrono::duration<double>(std::chrono::steady_clock::now() - t0).count();
    };

    size_t rung = 0, nofield = 0, escalated = 0, joins = 0, maxVis = 0, cascades = 0;
    std::unordered_set<const BaseClass*> suppressed;
    std::string stop = "FIXPOINT";
    const BaseClass *pL = nullptr, *pR = nullptr;

    while (true) {
        CompareContext ctx;
        int r = runFresh(ctx);
        const BaseClass* L = ctx.m_failedLhs;
        const BaseClass* R = ctx.m_failedRhs;
        size_t vis = ctx.m_visited.size();
        auto onWalk = [&](const BaseClass* g) { return g && ctx.m_visited.count(g) != 0; };
        if (r == 0) { stop = "FIXPOINT"; break; }
        if (rung && L == pL && R == pR) { stop = "UNMASKABLE-REPEAT"; break; }
        pL = L;
        pR = R;
        rung++;
        if (vis > maxVis) maxVis = vis;

        // ── name the differing field ────────────────────────────────────
        // A head with a NULL side names no field of its own: the field that
        // differs belongs to the object that POINTS AT it.  That object is the
        // REFERRER, not the tree parent — so the referrer is looked up on the
        // side that has an object, its twin is joined on the other side, and
        // the pair is diffed there.  The field is marked '^' to say the
        // diagnosis was made one hop up, and left as the bare null-shape when
        // the referrer or the join is missing.
        Diff d = firstDiff(L, R);
        const BaseClass* refG = nullptr;
        const BaseClass* refO = nullptr;
        const BaseClass* precise = nullptr;  // minimal mask found by nullEdge()
        if (!L || !R) {
            build(sg, gIndex, gIx);
            build(so, oIndex, oIx);
            buildRef(sg, gRef, gRx);
            buildRef(so, oRef, oRx);
            // EVERY referrer is tried, not the first: the enclosing pair is the
            // one whose fields actually disagree, and the design lists every
            // module so it would otherwise always win the lookup.
            // PASS 1 — the PRECISE null edge: a referrer that really holds the
            // target on one side and really holds null on the other.  This is
            // also the MINIMAL mask, which matters enormously: masking the
            // failing object instead can only work by cascade (masking golden's
            // uvm_pkg hides the entire UVM library and costs the ladder every
            // defect inside it).
            // PASS 2 — any referrer pair with a diagnosable difference, marked
            // '~' to say it is a WEAKER claim than the precise edge.
            auto scan = [&](auto& rx, const BaseClass* key, bool keyIsOurs, bool precisePass) {
                for (auto [it, end] = rx.equal_range(key); it != end; ++it) {
                    const BaseClass* x = it->second.first;
                    const BaseClass* y = twin(keyIsOurs ? gIndex : oIndex, x);
                    if (!y) continue;
                    const BaseClass* gx = keyIsOurs ? y : x;
                    const BaseClass* ox = keyIsOurs ? x : y;
                    if (!onWalk(gx)) continue;  // never entered → cannot be the failure
                    if (precisePass) {
                        NullEdge e = nullEdge(gx, ox, keyIsOurs ? R : L, true);
                        if (!e.found) e = nullEdge(ox, gx, keyIsOurs ? R : L, false);
                        if (!e.found) continue;
                        d.field = "^" + e.field;
                        d.shape = e.shape;
                        d.gval = e.gval;
                        d.oval = e.oval;
                        d.found = true;
                        refG = gx;
                        refO = ox;
                        precise = gx;
                        joins++;
                        return true;
                    }
                    Diff pd = firstDiff(gx, ox);
                    if (!pd.found) continue;
                    pd.field = "~" + pd.field;
                    d = pd;
                    refG = gx;
                    refO = ox;
                    joins++;
                    return true;
                }
                return false;
            };
            const bool oursKey = (R && !L);
            auto& rx = oursKey ? oRef : gRef;
            const BaseClass* key = oursKey ? R : L;
            if (!scan(rx, key, oursKey, true)) scan(rx, key, oursKey, false);
        }
        if (!d.found) {
            nofield++;
            d.field = "<none>";
            d.shape = "NO-FIELD-DIFF";
        }

        const BaseClass* anchor = L ? L : R;
        std::string kindL = L ? UhdmName(L->UhdmType()) : "<null>";
        std::string kindR = R ? UhdmName(R->UhdmType()) : "<null>";
        std::string kindP = anchor && anchor->VpiParent()
                                ? UhdmName(anchor->VpiParent()->UhdmType())
                                : "<root>";
        // RAW keys.  The tool emits KINDL / KINDR / FIELD / SHAPE as separate
        // facts and joins them here without interpretation; the CLUSTERER owns
        // the refinement (a head with no golden object is re-keyed on OURS'
        // kind, because keying those on the literal "<null>" collapses every
        // extra-object defect in the corpus into one meaningless family).
        // Keeping the policy in one place stops the artifacts and the report
        // from disagreeing whenever the policy is tuned.
        std::string fam = kindL + "|" + d.field + "|" + d.shape;
        std::string fam2 = kindL + "|" + d.field;

        // ── choose the mask ─────────────────────────────────────────────
        // Candidates in escalation order: the failing golden object itself,
        // then the golden referrer chain (who was mid-Compare), then the
        // golden tree-parent chain.  The DESIGN ROOT is never a candidate —
        // masking it returns 0 for the whole comparison and would print a
        // FIXPOINT that means "I stopped looking".
        std::vector<const BaseClass*> cand;
        std::unordered_set<const BaseClass*> candSeen;  // O(1) dedup: the linear
        // scan cost 16M comparisons a rung once the referrer BFS ran wide.
        bool hitRoot = false;
        const size_t kCandCap = 64;
        auto push = [&](const BaseClass* c) {
            if (!c || cand.size() >= kCandCap) return false;
            if (c == (const BaseClass*)dg) { hitRoot = true; return false; }
            if (!candSeen.insert(c).second) return false;
            cand.push_back(c);
            return true;
        };
        build(sg, gIndex, gIx);
        buildRef(sg, gRef, gRx);
        build(so, oIndex, oIx);
        buildRef(so, oRef, oRx);
        if (precise) push(precise);              // MINIMAL mask, least cascade
        if (L && R) push(L);                     // shape (a): the object itself
        if (refG) push(refG);
        if (!L && R) push(twin(gIndex, R));
        // ON-WALK referrers next: only an object whose Compare was ENTERED can
        // be the one that held the failing SafeCompare.
        if (L)
            for (auto [it, end] = gRef.equal_range(L); it != end; ++it)
                if (onWalk(it->second.first)) push(it->second.first);
        if (!L && R)
            for (auto [it, end] = oRef.equal_range(R); it != end; ++it) {
                const BaseClass* g = twin(gIndex, it->second.first);
                if (onWalk(g)) push(g);
            }
        if (L && !R) push(L);                    // shape (b): inert but cheap to try
        // LAST RESORT: golden twins of OUR referrers and of OUR tree ancestors
        // even when the walk never entered them.  Without this a head like
        // "ours has an extra string_var in a package" produced ZERO candidates.
        if (!L && R) {
            for (auto [it, end] = oRef.equal_range(R); it != end; ++it)
                push(twin(gIndex, it->second.first));
            for (const BaseClass* p = R->VpiParent(); p; p = p->VpiParent())
                push(twin(gIndex, p));
        }
        for (size_t i = 0; i < cand.size() && cand.size() < kCandCap; i++)
            for (auto [it, end] = gRef.equal_range(cand[i]); it != end; ++it)
                push(it->second.first);
        for (const BaseClass* p = L ? L->VpiParent() : nullptr; p; p = p->VpiParent()) push(p);

        // SMALLEST MASK WINS.  Any candidate that moves the head is "correct",
        // but they are not equally good: masking golden's `uvm_pkg` moves the
        // head and ALSO hides the entire UVM library, which cost the ladder
        // every defect inside it (16 rungs, coverage 8.9%).  So everything after
        // the fixed prefix is ordered by ASCENDING subtree volume and the
        // cheapest mask that works is the one that is kept.
        {
            size_t fixed = 0;
            if (precise) fixed++;
            if (L && R && cand.size() > fixed && cand[fixed] == L) fixed++;
            std::vector<std::pair<size_t, const BaseClass*>> tail;
            for (size_t i = fixed; i < cand.size(); i++)
                tail.push_back({subtreeSize(cand[i], 512), cand[i]});
            std::stable_sort(tail.begin(), tail.end(),
                             [](auto& a, auto& b) { return a.first < b.first; });
            cand.resize(fixed);
            for (auto& [n, c] : tail) cand.push_back(c);
        }

        int level = -1;
        for (size_t i = 0; i < cand.size(); i++) {
            if (!mask.insert(cand[i]).second) continue;
            CompareContext c2;
            int r2 = runFresh(c2);
            if (r2 == 0 || c2.m_failedLhs != L || c2.m_failedRhs != R) {
                level = (int)i;
                break;
            }
            mask.erase(cand[i]);
        }
        const BaseClass* chosen = level >= 0 ? cand[level] : nullptr;
        size_t bisectRuns = 0, bisectSet = 0;
        bool cascadePool = false;
        if (!chosen) {
            // the heuristic named nothing that works — MEASURE the blocker.
            //
            // CASCADE-AVERSE POOL (vladder1).  The pool used to be every
            // visited object, and bisection has no volume preference, so it
            // happily returned golden's whole `package(uvm_pkg)`: one mask
            // that makes the entire UVM library compare equal for the rest of
            // the row.  Objects whose subtree is >= kMegaFrac of the golden
            // database are therefore held back for a SECOND attempt and the
            // rung is marked CASCADE when they turn out to be necessary.
            // Masking is monotone, so restricting the pool cannot produce a
            // wrong mask — only fewer of them.
            std::vector<const BaseClass*> pool, mega;
            const size_t megaCut = gObjs / 100 ? gObjs / 100 : 1;
            for (const BaseClass* o : ctx.m_visited)
                if (o != (const BaseClass*)dg && !mask.count(o)) {
                    if (subtreeSize(o, megaCut) >= megaCut)
                        mega.push_back(o);
                    else
                        pool.push_back(o);
                }
            auto byid = [](const BaseClass* a, const BaseClass* b) {
                return a->UhdmId() != b->UhdmId() ? a->UhdmId() < b->UhdmId() : a < b;
            };
            std::sort(pool.begin(), pool.end(), byid);
            std::sort(mega.begin(), mega.end(), byid);
            bool ok = false;
            if (!pool.empty()) {
                bisectRuns++;
                ok = poolMoved(pool, L, R, pool.size());
            }
            if (!ok && !mega.empty()) {
                // the small objects alone cannot move it — re-admit the
                // mega-objects and SAY SO.
                cascadePool = true;
                pool.insert(pool.end(), mega.begin(), mega.end());
                std::sort(pool.begin(), pool.end(), byid);
                bisectRuns++;
                ok = poolMoved(pool, L, R, pool.size());
            }
            if (ok) {
                std::vector<const BaseClass*> cur = pool;
                for (int guard = 0; cur.size() > 1 && guard < 64; guard++) {
                    size_t h = cur.size() / 2;
                    std::vector<const BaseClass*> A(cur.begin(), cur.begin() + h);
                    std::vector<const BaseClass*> B(cur.begin() + h, cur.end());
                    bisectRuns++;
                    if (poolMoved(A, L, R, A.size())) { cur = A; continue; }
                    bisectRuns++;
                    if (poolMoved(B, L, R, B.size())) { cur = B; continue; }
                    break;  // the halves only work together — stop narrowing
                }
                // The narrowing invariant is that masking `cur` moves the head,
                // so `cur` is accepted whether it narrowed to one object or
                // stalled on a pair of halves that only work TOGETHER (two
                // referrers producing the same head is an ordinary shape, and
                // insisting on a single blocker stopped SimpleUVM 100+ rungs
                // early).  A stalled set is minimised greedily when it is small
                // enough to afford, and its SIZE is reported.
                if (!cur.empty() && cur.size() <= 4096) {
                    if (cur.size() > 1 && cur.size() <= 24)
                        for (size_t i = 0; i < cur.size() && cur.size() > 1; i++) {
                            std::vector<const BaseClass*> t;
                            for (size_t j = 0; j < cur.size(); j++)
                                if (j != i) t.push_back(cur[j]);
                            bisectRuns++;
                            if (poolMoved(t, L, R, t.size())) { cur = t; i = (size_t)-1; }
                        }
                    std::vector<const BaseClass*> added;
                    for (const BaseClass* c : cur)
                        if (mask.insert(c).second) added.push_back(c);
                    bisectRuns++;
                    CompareContext c3;
                    int r3 = runFresh(c3);
                    if (r3 == 0 || c3.m_failedLhs != L || c3.m_failedRhs != R) {
                        chosen = cur[0];
                        bisectSet = cur.size();
                        level = 1000;  // marker: found by bisection, not by name
                    } else
                        for (const BaseClass* c : added) mask.erase(c);
                }
            }
        }
        if (level > 0) escalated++;
        // TRUE volume, not the old cap of 4000: the cap made a mask that hides
        // 4 000 golden objects and one that hides 180 000 print the SAME
        // number, which is the difference between a local mask and masking the
        // whole UVM library.  The union over the row is `suppressed=` below.
        size_t masked = 0;
        if (chosen) {
            masked = subtreeSize(chosen, (size_t)-1);
            collectSubtree(chosen, suppressed);
        }
        const bool cascade = chosen && masked * 100 >= gObjs;

        printf(
            "RUNG\t%zu\tr=%d\tvis=%zu\tmasklvl=%d\tmasked=%zu\tcands=%zu\tKINDL=%s\t"
            "KINDR=%s\tKINDP=%s\tFIELD=%s\tSHAPE=%s\tFAM=%s\tFAM2=%s%s\n",
            rung, r, vis, level, masked, cand.size(), kindL.c_str(), kindR.c_str(),
            kindP.c_str(), d.field.c_str(), d.shape.c_str(), fam.c_str(), fam2.c_str(),
            cascade ? (cascadePool ? "\tCASCADE=forced" : "\tCASCADE=1") : "");
        if (bisectRuns) printf("   BI %zu compares, mask set = %zu object(s)\n", bisectRuns, bisectSet);
        printf("   L  %s\n", ident(L).c_str());
        printf("   R  %s\n", ident(R).c_str());
        printf("   G= %s   O= %s\n", d.gval.empty() ? "-" : d.gval.c_str(),
               d.oval.empty() ? "-" : d.oval.c_str());
        printf("   PL %s\n", L ? chainOf(L).c_str() : "-");
        printf("   PR %s\n", R ? chainOf(R).c_str() : "-");
        if (refG || refO)
            printf("   RF G:%s  O:%s\n", ident(refG).c_str(), ident(refO).c_str());
        if (!chosen) {
            printf("   !! %s\n",
                   hitRoot ? "ROOT-BLOCKED: the only maskable owner is the design root — "
                             "subtree masking cannot see past a design-level field"
                           : "UNMASKABLE: no candidate moved the head");
            stop = hitRoot ? "ROOT-BLOCKED" : "UNMASKABLE-CHAIN";
            break;
        }
        if (cascade) cascades++;
        printf("   MK %s%s%s\n", chosen ? ident(chosen).c_str() : "-",
               level == 1000 ? "  [bisected]" : "",
               cascade ? "  [CASCADE: this mask hides >=1% of the golden database"
                         " for every later rung]"
                       : "");

        if (rung >= maxRungs) { stop = "MAX-RUNGS"; break; }
        if (secs() > budget) { stop = "BUDGET"; break; }
    }

    // COVERAGE, the honest "how far are we" number: `m_visited` holds the
    // GOLDEN objects the walk proved equal, so the DEEPEST walk reached is the
    // fraction of the golden database this row has actually cleared.  Reported
    // as the maximum over rungs because the final walk skips masked subtrees.
    printf("[S] rungs=%zu stop=%s escalated=%zu ref_joins=%zu nofield=%zu "
           "maxvis=%zu/%zu masks=%zu cascades=%zu suppressed=%zu/%zu secs=%.1f\n",
           rung, stop.c_str(), escalated, joins, nofield, maxVis, gObjs, mask.size(),
           cascades, suppressed.size(), gObjs, secs());
    if (calib && rung != 0) {
        fprintf(stderr, "CALIBRATION FAILED: golden-vs-golden produced %zu rungs\n", rung);
        return 5;
    }
    return 0;
}
