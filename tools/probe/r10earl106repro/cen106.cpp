// r10earl106 -- THE CONT-ASSIGN WHOLE-Rhs FOLD CENSUS.
//
// MEASUREMENT ONLY.  The official ~/git-repos/UHDM/build/bin/uhdm-cmp is the
// sole acceptance judge; nothing here judges anything.
//
// THE POPULATION.  Every NODE inside every `cont_assign`'s Rhs subtree, on
// either side, in either view -- r10earl105's cen106.cpp with THREE changes,
// each forced by the edge THIS pass moves:
//
//  1. THE NODE SPAN LEAVES THE KEY.  cen106 joined on the node's span because
//     a substituted constant and the ref_obj it replaced carried the SAME
//     span.  This pass's edge is the opposite: golden's folded constant is
//     LOCATION-LESS and ours is anchored at the cast operation's span, so a
//     span in the key would split every moving cell into ONLY-GOLDEN +
//     ONLY-OURS and score nothing.  The key is therefore
//     (view, home, cont_assign Lhs fullname, cont_assign span, node DEPTH,
//      occurrence index) -- depth-keyed identity, RESUME.md section 9.
//
//  2. THE SPAN IS STILL MEASURED, in its OWN column (`LOC=` / `LOCLESS`),
//     printed beside the payload and NEVER part of the judged payload.  This
//     is earl60's lesson read the other way round: a span-carrying payload
//     HID a flip, so the span is reported and not scored.
//
//  3. AN ORIGIN COLUMN.  Every cell carries the shape of the GOLDEN DEF-view
//     twin of its own cont_assign (`org=operation,op=67` for a cast, `op=33`
//     for a concat, `constant,...` for a literal, `NONE` when the def view has
//     no twin), so the corpus population can be counted PER FOLD ORIGIN, which
//     is what this pass's law is gated on.
//
// PAYLOAD  the node rendered as a STRING -- kind, and for a `constant` its
//        compare-visible encoding (VpiSize / VpiConstType / VpiValue /
//        VpiDecompile) plus its typespec, and for a `ref_obj` its VpiName and
//        the KIND of its Actual_group.  `constant::Compare` reads VpiDecompile
//        FIRST, then VpiSize, then Typespec, then (in constant::Compare
//        proper) VpiConstType, and reads NO location at all -- verified in
//        ~/git-repos/UHDM/build/generated/src/{expr,constant,BaseClass}.cpp.
//
// HOME  the cont_assign's own parent chain: `mod`, `genloop`, `genif`,
//        `iface`, `other`.
//
// build:
//   g++ -O2 -std=c++17 cen106.cpp -I ~/.local/include \
//       -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o cen106
// usage:
//   cen106 <golden.uhdm> <ours.uhdm> [--all] [--param]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cctype>
#include <cstdio>
#include <cstring>
#include <cstdlib>
#include <map>
#include <set>
#include <string>
#include <unordered_map>
#include <unordered_set>
#include <variant>
#include <vector>

using namespace UHDM;

[[maybe_unused]] static std::string base(std::string_view p) {
    size_t i = p.find_last_of('/');
    return std::string(i == std::string_view::npos ? p : p.substr(i + 1));
}
static std::string spanOf(const BaseClass* o) {
    if (!o) return "<null>";
    char b[192];
    snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
             o->VpiEndLineNo(), (unsigned)o->VpiEndColumnNo());
    return b;
}
static std::string fullName(const BaseClass* o) {
    if (!o) return "";
    auto pv = o->GetVpiPropertyValue(vpiFullName);
    if (std::holds_alternative<const char*>(pv)) {
        const char* p = std::get<const char*>(pv);
        if (p && *p) return p;
    }
    return std::string(o->VpiName());
}
static bool locless(const BaseClass* o) {
    return o && o->VpiLineNo() == 0 && o->VpiColumnNo() == 0;
}
static std::string boundOf(const expr* e) {
    if (!e) return "-";
    if (auto* c = any_cast<const constant*>((const any*)e))
        return std::string(c->VpiValue());
    return std::string(UhdmName(e->UhdmType()));
}
static const VectorOfrange* rangesOf(const typespec* t) {
    const any* a = (const any*)t;
#define TRY(T) if (auto* x = any_cast<const T*>(a)) return x->Ranges();
    TRY(logic_typespec) TRY(int_typespec) TRY(bit_typespec)
    TRY(array_typespec) TRY(packed_array_typespec) TRY(unsupported_typespec)
#undef TRY
    return nullptr;
}
static bool signedOf(const typespec* t) {
    const any* a = (const any*)t;
#define TRY(T) if (auto* x = any_cast<const T*>(a)) return x->VpiSigned();
    TRY(logic_typespec) TRY(int_typespec) TRY(bit_typespec)
    TRY(integer_typespec) TRY(byte_typespec) TRY(short_int_typespec)
    TRY(long_int_typespec)
#undef TRY
    return false;
}
// THE TYPESPEC AS A STRING -- r10earl104's renderer verbatim, so the two
// censuses speak the same language about the object this pass rides on.
static std::string tsString(const typespec* a) {
    if (!a) return "NONE";
    std::string d = UhdmName(a->UhdmType());
    // NO VpiFile: our typespecs carry an empty one where golden's carry the
    // path, and no generated Compare reads it (RESUME.md section 9).
    d += locless(a) ? "@LOCLESS" : ("@" + spanOf(a));
    if (!a->VpiName().empty()) d += ",name=" + std::string(a->VpiName());
    if (!a->VpiDefName().empty()) d += ",def=" + std::string(a->VpiDefName());
    if (signedOf(a)) d += ",signed";
    if (auto* it = any_cast<const int_typespec*>((const any*)a))
        if (!it->VpiValue().empty()) d += ",val=" + std::string(it->VpiValue());
    if (const VectorOfrange* rs = rangesOf(a)) {
        d += ",ranges=[";
        for (size_t i = 0; i < rs->size(); i++) {
            if (i) d += ";";
            d += boundOf((*rs)[i]->Left_expr()) + ":" +
                 boundOf((*rs)[i]->Right_expr());
        }
        d += "]";
    }
    return d;
}
static const typespec* tsOf(const any* n) {
    if (!n) return nullptr;
    if (auto* e = any_cast<const expr*>(n))
        if (const ref_typespec* rt = e->Typespec()) return rt->Actual_typespec();
    return nullptr;
}
// THE NODE AS A STRING.  Everything the judge reads on the two kinds this
// pass flips between, and nothing it does not (no VpiFullName, no span, no
// vpiParent -- RESUME.md section 9).
static std::string nodeString(const any* n) {
    if (!n) return "NONE";
    std::string d = UhdmName(n->UhdmType());
    if (auto* c = any_cast<const constant*>(n)) {
        char b[96];
        snprintf(b, sizeof b, ",sz=%d,ct=%d", c->VpiSize(), c->VpiConstType());
        d += b;
        d += ",v=" + std::string(c->VpiValue());
        d += ",dc=" + std::string(c->VpiDecompile());
        d += ",TS=" + tsString(tsOf(n));
    } else if (auto* r = any_cast<const ref_obj*>(n)) {
        d += ",name=" + std::string(r->VpiName());
        d += ",act=" +
             std::string(r->Actual_group() ? UhdmName(r->Actual_group()->UhdmType())
                                           : "<null>");
    } else if (auto* op = any_cast<const operation*>(n)) {
        char b[32];
        snprintf(b, sizeof b, ",op=%d", op->VpiOpType());
        d += b;
        d += ",TS=" + tsString(tsOf(n));
    } else if (auto* bs = any_cast<const bit_select*>(n)) {
        d += ",name=" + std::string(bs->VpiName());
    } else if (auto* ps = any_cast<const part_select*>(n)) {
        d += ",name=" + std::string(ps->VpiName());
    }
    return d;
}
// Is this node a PARAMETER READ, or the SUBSTITUTE for one?  A ref_obj whose
// Actual_group is a parameter, or a constant whose VpiParent is a param_assign
// (Surelog's substituted copy keeps the source constant's parent -- measured
// on h1/h2), or a constant carrying a ref_typespec at all (the use-site mint).
static bool paramish(const any* n) {
    if (!n) return false;
    if (auto* r = any_cast<const ref_obj*>(n))
        return r->Actual_group() &&
               r->Actual_group()->UhdmType() == uhdmparameter;
    if (auto* c = any_cast<const constant*>(n))
        return (c->VpiParent() &&
                c->VpiParent()->UhdmType() == uhdmparam_assign) ||
               c->Typespec() != nullptr;
    return false;
}

struct Cell {
    std::string view, home, ca, span, caSpan, payload, loc, origin;
    bool param = false;
};

// The cont_assign's HOME, from its own parent chain.
static std::string homeOf(const BaseClass* ca) {
    for (const BaseClass* p = ca->VpiParent(); p; p = p->VpiParent()) {
        switch (p->UhdmType()) {
            case uhdmgen_scope: {
                // A loop-generate body's gen_scope_array name carries `[i]`.
                const BaseClass* gp = p->VpiParent();
                std::string nm = gp ? std::string(gp->VpiName()) : std::string();
                return nm.find('[') != std::string::npos ? "genloop" : "genif";
            }
            case uhdmmodule_inst: return "mod";
            case uhdminterface_inst: return "iface";
            default: break;
        }
    }
    return "other";
}

static void walk(const any* n, int depth,
                 std::vector<std::pair<int, const any*>>& out) {
    if (!n || depth > 24) return;
    out.push_back({depth, n});
    if (auto* op = any_cast<const operation*>(n)) {
        if (op->Operands())
            for (auto* o : *op->Operands()) walk(o, depth + 1, out);
    } else if (auto* bs = any_cast<const bit_select*>(n)) {
        walk(bs->VpiIndex(), depth + 1, out);
    } else if (auto* ps = any_cast<const part_select*>(n)) {
        walk(ps->Left_range(), depth + 1, out);
        walk(ps->Right_range(), depth + 1, out);
    } else if (auto* ip = any_cast<const indexed_part_select*>(n)) {
        walk(ip->Base_expr(), depth + 1, out);
        walk(ip->Width_expr(), depth + 1, out);
    } else if (auto* vs = any_cast<const var_select*>(n)) {
        if (vs->Exprs())
            for (auto* o : *vs->Exprs()) walk(o, depth + 1, out);
    } else if (auto* hp = any_cast<const hier_path*>(n)) {
        if (hp->Path_elems())
            for (auto* o : *hp->Path_elems()) walk(o, depth + 1, out);
    } else if (auto* sc = any_cast<const sys_func_call*>(n)) {
        if (sc->Tf_call_args())
            for (auto* o : *sc->Tf_call_args()) walk(o, depth + 1, out);
    } else if (auto* fc = any_cast<const func_call*>(n)) {
        if (fc->Tf_call_args())
            for (auto* o : *fc->Tf_call_args()) walk(o, depth + 1, out);
    }
}

// THE ROOTED TRAVERSAL.  cen105 found its cont_assigns by scanning the whole
// arena and labelled the view by walking `VpiParent` to a root.  That is
// LAST-WRITER UNSAFE here: this corpus holds SEVERAL cont_assign objects with
// the SAME (view, home, Lhs fullname, span) -- the flatten/clone leftovers in
// the weakly-referenced tail among them -- and a map keyed without an ordinal
// silently merged a folded one with an unfolded one (measured on g1_home106:
// six phantom ONLY-OURS d1 rows).  RESUME.md section 9: "a last-writer dict
// drops rows".  So the walk descends the CONTAINMENT relations from the two
// design roots, in a deterministic order, and every cont_assign gets an
// ORDINAL among the ones sharing its key.  Objects reachable from NEITHER root
// are the weakly-referenced TAIL, which the judge cannot reach; they are
// counted and reported as TAIL and never scored.
static void caOf(const BaseClass* sc, std::vector<const cont_assign*>& out);
static void descend(const BaseClass* sc, std::vector<const cont_assign*>& out) {
    if (!sc) return;
    caOf(sc, out);
}
static void caOf(const BaseClass* sc, std::vector<const cont_assign*>& out) {
#define CAS(T)                                                          \
    if (auto* x = any_cast<const T*>((const any*)sc)) {                 \
        if (x->Cont_assigns())                                          \
            for (auto* c : *x->Cont_assigns()) out.push_back(c);        \
        if (x->Gen_scope_arrays())                                      \
            for (auto* g : *x->Gen_scope_arrays()) descend(g, out);     \
        if (x->Modules())                                               \
            for (auto* m : *x->Modules()) descend(m, out);              \
        if (x->Interfaces())                                            \
            for (auto* i : *x->Interfaces()) descend(i, out);           \
        if (x->Gen_stmts())                                             \
            for (auto* g : *x->Gen_stmts()) descend(g, out);            \
        return;                                                         \
    }
    CAS(module_inst)
#undef CAS
    if (auto* x = any_cast<const interface_inst*>((const any*)sc)) {
        if (x->Cont_assigns())
            for (auto* c : *x->Cont_assigns()) out.push_back(c);
        if (x->Gen_scope_arrays())
            for (auto* g : *x->Gen_scope_arrays()) descend(g, out);
        if (x->Interfaces())
            for (auto* i : *x->Interfaces()) descend(i, out);
        if (x->Gen_stmts())
            for (auto* g : *x->Gen_stmts()) descend(g, out);
        return;
    }
    if (auto* gs = any_cast<const gen_scope*>((const any*)sc)) {
        if (gs->Cont_assigns())
            for (auto* c : *gs->Cont_assigns()) out.push_back(c);
        if (gs->Gen_scope_arrays())
            for (auto* g : *gs->Gen_scope_arrays()) descend(g, out);
        if (gs->Modules())
            for (auto* m : *gs->Modules()) descend(m, out);
        if (gs->Interfaces())
            for (auto* i : *gs->Interfaces()) descend(i, out);
        return;
    }
    if (auto* ga = any_cast<const gen_scope_array*>((const any*)sc)) {
        if (ga->Gen_scopes())
            for (auto* g : *ga->Gen_scopes()) descend(g, out);
        return;
    }
    // THE DEF VIEW'S GENERATE TREE.  A module DEFINITION lists its generate
    // constructs under `Gen_stmts()`, and a taken/untaken branch's body is a
    // `named_begin` whose `Stmts()` holds the cont_assigns (uhdm-dump prints
    // them as vpiGenStmt > gen_if > named_begin > vpiStmt).  Without this the
    // DEF half of every gen-scope cell fell into the unreached TAIL.
    if (auto* gi = any_cast<const gen_if*>((const any*)sc)) {
        descend(gi->VpiStmt(), out);
        return;
    }
    if (auto* ge = any_cast<const gen_if_else*>((const any*)sc)) {
        descend(ge->VpiStmt(), out);
        descend(ge->VpiElseStmt(), out);
        return;
    }
    if (auto* gf = any_cast<const gen_for*>((const any*)sc)) {
        descend(gf->VpiStmt(), out);
        return;
    }
    if (auto* gr = any_cast<const gen_region*>((const any*)sc)) {
        descend(gr->VpiStmt(), out);
        return;
    }
    if (auto* nb = any_cast<const named_begin*>((const any*)sc)) {
        if (nb->Stmts())
            for (auto* st : *nb->Stmts()) {
                if (auto* c = any_cast<const cont_assign*>(st))
                    out.push_back(c);
                else
                    descend(st, out);
            }
        return;
    }
    if (auto* bg = any_cast<const begin*>((const any*)sc)) {
        if (bg->Stmts())
            for (auto* st : *bg->Stmts()) {
                if (auto* c = any_cast<const cont_assign*>(st))
                    out.push_back(c);
                else
                    descend(st, out);
            }
        return;
    }
}

static void emitCells(const cont_assign* ca, const char* view,
                      std::map<std::string, Cell>& out,
                      std::map<std::string, int>& caSeen) {
    std::string home = homeOf(ca);
    std::string caN = fullName(ca->Lhs());
    std::string caS = spanOf(ca);
    std::string ck = std::string(view) + "|" + home + "|" + caN + "|" + caS;
    int caIdx = caSeen[ck]++;
    char cb[24];
    snprintf(cb, sizeof cb, "|ca%d", caIdx);
    std::vector<std::pair<int, const any*>> nodes;
    walk(ca->Rhs(), 0, nodes);
    std::map<std::string, int> seen;
    for (auto& [d, n] : nodes) {
        char kb[64];
        snprintf(kb, sizeof kb, "|d%d", d);
        std::string k0 = ck + cb + kb;
        int idx = seen[k0]++;
        char ib[24];
        snprintf(ib, sizeof ib, "|#%d", idx);
        Cell c;
        c.view = view;
        c.home = home;
        c.ca = caN;
        c.span = spanOf(n);
        c.caSpan = caS;
        c.loc = locless(n) ? "LOCLESS" : ("LOC=" + spanOf(n));
        c.payload = nodeString(n);
        c.param = paramish(n);
        out[k0 + ib] = c;
    }
}

static void collect(Serializer& s, std::map<std::string, Cell>& out, bool& ok,
                    int& tailCas) {
    std::vector<const BaseClass*> all;
    for (const auto& [obj, id] : s.AllObjects())
        if (obj) all.push_back(obj);
    std::sort(all.begin(), all.end(), [](const BaseClass* a, const BaseClass* b) {
        return a->UhdmId() != b->UhdmId() ? a->UhdmId() < b->UhdmId() : a < b;
    });
    const design* dz = nullptr;
    for (const BaseClass* o : all)
        if (o->UhdmType() == uhdmdesign) { dz = (const design*)o; break; }
    if (!dz) { ok = false; return; }
    std::map<std::string, int> caSeen;
    std::unordered_set<const BaseClass*> reached;
    std::vector<const cont_assign*> defCas, elabCas;
    if (getenv("CEN106_DBG"))
        fprintf(stderr, "DBG allModules=%zu topModules=%zu\n",
                dz->AllModules() ? dz->AllModules()->size() : 0,
                dz->TopModules() ? dz->TopModules()->size() : 0);
    if (dz->AllModules())
        for (auto* m : *dz->AllModules()) descend(m, defCas);
    if (dz->TopModules())
        for (auto* m : *dz->TopModules()) descend(m, elabCas);
    if (getenv("CEN106_DBG")) fprintf(stderr, "DBG defCas=%zu elabCas=%zu\n", defCas.size(), elabCas.size());
    for (auto* c : defCas) { reached.insert(c); emitCells(c, "DEF", out, caSeen); }
    for (auto* c : elabCas) { reached.insert(c); emitCells(c, "ELAB", out, caSeen); }
    // THE ORIGIN COLUMN: the DEF-view twin of each cont_assign -- the shape
    // the fold STARTED from -- keyed on the Lhs fullname's TAIL (the def view
    // prefixes with the definition, the elab view with the instance path) and
    // the cont_assign span.
    std::map<std::string, std::string> defOrigin;
    for (auto& [k, c] : out) {
        if (c.view != std::string("DEF")) continue;
        if (k.find("|d0|") == std::string::npos) continue;
        std::string tail = c.ca;
        if (size_t p = tail.find_last_of('.'); p != std::string::npos)
            tail = tail.substr(p + 1);
        defOrigin.emplace(tail + "@" + c.caSpan, c.payload);
    }
    for (auto& [k, c] : out) {
        std::string tail = c.ca;
        if (size_t p = tail.find_last_of('.'); p != std::string::npos)
            tail = tail.substr(p + 1);
        auto it = defOrigin.find(tail + "@" + c.caSpan);
        c.origin = it == defOrigin.end() ? "NONE" : it->second;
    }
    tailCas = 0;
    for (const BaseClass* o : all)
        if (o->UhdmType() == uhdmcont_assign && !reached.count(o)) tailCas++;
    ok = true;
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: cen106 <golden.uhdm> <ours.uhdm> [--all] [--param]\n");
        return 2;
    }
    bool all = false, onlyParam = false;
    for (int i = 3; i < argc; i++) {
        if (!strcmp(argv[i], "--all")) all = true;
        if (!strcmp(argv[i], "--param")) onlyParam = true;
    }
    Serializer sg, so;
    if (sg.Restore(std::string(argv[1])).empty()) {
        fprintf(stderr, "RESTORE_FAILED %s\n", argv[1]);
        return 3;
    }
    if (so.Restore(std::string(argv[2])).empty()) {
        fprintf(stderr, "RESTORE_FAILED %s\n", argv[2]);
        return 3;
    }
    std::map<std::string, Cell> G, O;
    bool okg = false, oko = false;
    int tg = 0, to = 0;
    collect(sg, G, okg, tg);
    collect(so, O, oko, to);
    if (!okg || !oko) { fprintf(stderr, "NO_DESIGN\n"); return 4; }
    printf("#\tcen106\tgolden_cells=%zu\tours_cells=%zu\tTAILcas_g=%d"
           "\tTAILcas_o=%d\n", G.size(), O.size(), tg, to);
    int agree = 0, dis = 0, ug = 0, uo = 0, pagree = 0, pdis = 0;
    std::map<std::string, int> fam;
    for (auto& [k, g] : G) {
        auto it = O.find(k);
        if (it == O.end()) {
            ug++;
            if (!onlyParam || g.param)
                printf("ONLY-GOLDEN\t%s\tORG\t%s\t%s\t%s\n", k.c_str(),
                       g.origin.c_str(), g.payload.c_str(), g.loc.c_str());
            continue;
        }
        const Cell& o = it->second;
        bool same = (g.payload == o.payload);
        bool pop = g.param || o.param;
        if (same) agree++; else dis++;
        if (pop) { if (same) pagree++; else pdis++; }
        if ((all || !same) && (!onlyParam || pop))
            printf("CELL\t%s\t%s\tORG\t%s\tG\t%s\t%s\tO\t%s\t%s\n",
                   same ? "SAME" : "DIFF", k.c_str(), g.origin.c_str(),
                   g.payload.c_str(), g.loc.c_str(), o.payload.c_str(),
                   o.loc.c_str());
        if (!same)
            fam[g.view + "\t" + g.home + "\torg=" + g.origin + "\t" +
                g.payload + "  >  " + o.payload]++;
    }
    for (auto& [k, o] : O)
        if (!G.count(k)) {
            uo++;
            if (!onlyParam || o.param)
                printf("ONLY-OURS\t%s\tORG\t%s\t%s\t%s\n", k.c_str(),
                       o.origin.c_str(), o.payload.c_str(), o.loc.c_str());
        }
    printf("SUMMARY\tagree=%d\tdisagree=%d\tonly_golden=%d\tonly_ours=%d"
           "\tPARAM agree=%d\tdisagree=%d\n",
           agree, dis, ug, uo, pagree, pdis);
    printf("== FAMILIES (view / home / golden > ours)\n");
    for (auto& [f, c] : fam) printf("FAM\t%6d\t%s\n", c, f.c_str());
    return 0;
}
