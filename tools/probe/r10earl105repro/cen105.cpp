// r10earl105 -- THE CONT-ASSIGN OPERAND SUBSTITUTION CENSUS.
//
// MEASUREMENT ONLY.  The official ~/git-repos/UHDM/build/bin/uhdm-cmp is the
// sole acceptance judge; nothing here judges anything.
//
// THE POPULATION.  Every NODE inside every `cont_assign`'s Rhs subtree, on
// either side, in either view.  The head of this pass lives there:
//
//   cont_assign(pinmux.sv:176) in gen_scope work@top_earlgrey.u_pinmux
//                                             .gen_mio_out[0]
//     Rhs operation op67 ($bits cast)
//       > operation op33 (the concat)
//         > golden: constant 176:43-176:64, BIN, parented at the parameter's
//                   own param_assign, ref_typespec named at the INSTANCE, its
//                   actual the loc-less int_typespec r10earl104 mints
//           ours  : ref_obj  176:43-176:64  -> the parameter
//
// KEY   (view, cont_assign Lhs VpiFullName, cont_assign span, node DEPTH,
//        node SPAN, occurrence index).  The VIEW is in the key because the DEF
//        listing (design::AllModules) and the ELAB listing (design::TopModules)
//        hold cont_assigns at the SAME span for the SAME assignment (earl55's
//        lesson).  The node SPAN is the join axis because a SUBSTITUTED
//        constant and the REF_OBJ it replaces carry the SAME span -- that is
//        precisely the edge this pass moves.  The occurrence index makes the
//        join a MULTISET join (RESUME.md section 9: a last-writer dict drops
//        rows).  No FILE anywhere in the key: our cont_assign objects carry an
//        EMPTY VpiFile and cont_assign::Compare never reads it.
//
// PAYLOAD  the node rendered as a STRING -- kind, and for a `constant` its
//        compare-visible encoding (VpiSize / VpiConstType / VpiValue /
//        VpiDecompile) plus its typespec rendered exactly as r10earl104's
//        census renders one, and for a `ref_obj` its VpiName and the KIND of
//        its Actual_group.  `ref_obj::Compare` DOES read Actual_group
//        (RESUME.md section 9) and `constant::Compare` DOES read VpiSize /
//        VpiConstType / VpiDecompile, so both halves of the flip are in the
//        payload.  uvm159's lesson: score the STRING, never a count.
//
// HOME  the cont_assign's own parent chain, rendered as a token so a law
//        gated on the read's home can be scored per home: `mod` (a module_inst
//        body), `genloop` (a gen_scope whose gen_scope_array name carries an
//        index -- a loop-generate body), `genif` (a gen_scope that does not),
//        `iface`, `other`.  Read from the GOLDEN database wherever the cell
//        exists there, so the home key is not a function of our own emitter.
//
// DEPTH is in the key rather than a path because a path is BLIND below the
// slot when one side folds a whole subtree (earl56's 107-cell regression);
// with depth in the key a fold shows up as ONLY-GOLDEN / ONLY-OURS rows, which
// this census prints and counts.
//
// build:
//   g++ -O2 -std=c++17 cen105.cpp -I ~/.local/include \
//       -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o cen105
// usage:
//   cen105 <golden.uhdm> <ours.uhdm> [--all] [--param]
//     TSV on stdout: one CELL row per paired key plus SUMMARY / FAMILY lines.
//     --param restricts the printed families to nodes that are a PARAMETER
//     read or a substitute for one on some side.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cctype>
#include <cstdio>
#include <cstring>
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
    std::string view, home, ca, span, payload;
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

static void collect(Serializer& s, std::map<std::string, Cell>& out, bool& ok) {
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
    std::unordered_set<const BaseClass*> defRoots, elabRoots;
    if (dz->AllModules()) for (auto* m : *dz->AllModules()) defRoots.insert(m);
    if (dz->TopModules()) for (auto* m : *dz->TopModules()) elabRoots.insert(m);
    for (const BaseClass* o : all) {
        if (o->UhdmType() != uhdmcont_assign) continue;
        auto* ca = (const cont_assign*)o;
        const BaseClass* top = o;
        while (top->VpiParent() && top->VpiParent()->UhdmType() != uhdmdesign)
            top = top->VpiParent();
        const char* view = defRoots.count(top) ? "DEF"
                         : elabRoots.count(top) ? "ELAB" : "OTHER";
        std::string home = homeOf(ca);
        std::string caN = fullName(ca->Lhs());
        std::string caS = spanOf(ca);
        std::vector<std::pair<int, const any*>> nodes;
        walk(ca->Rhs(), 0, nodes);
        std::map<std::string, int> seen;
        for (auto& [d, n] : nodes) {
            char kb[64];
            snprintf(kb, sizeof kb, "d%d", d);
            std::string k0 = std::string(view) + "|" + home + "|" + caN + "|" +
                             caS + "|" + kb + "|" + spanOf(n);
            int idx = seen[k0]++;
            char ib[24];
            snprintf(ib, sizeof ib, "|#%d", idx);
            Cell c;
            c.view = view;
            c.home = home;
            c.ca = caN;
            c.span = spanOf(n);
            c.payload = nodeString(n);
            c.param = paramish(n);
            out[k0 + ib] = c;
        }
    }
    ok = true;
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: cen105 <golden.uhdm> <ours.uhdm> [--all] [--param]\n");
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
    collect(sg, G, okg);
    collect(so, O, oko);
    if (!okg || !oko) { fprintf(stderr, "NO_DESIGN\n"); return 4; }
    printf("#\tcen105\tgolden_cells=%zu\tours_cells=%zu\n", G.size(), O.size());
    int agree = 0, dis = 0, ug = 0, uo = 0, pagree = 0, pdis = 0;
    std::map<std::string, int> fam;
    for (auto& [k, g] : G) {
        auto it = O.find(k);
        if (it == O.end()) {
            ug++;
            if (!onlyParam || g.param)
                printf("ONLY-GOLDEN\t%s\t%s\n", k.c_str(), g.payload.c_str());
            continue;
        }
        const Cell& o = it->second;
        bool same = (g.payload == o.payload);
        bool pop = g.param || o.param;
        if (same) agree++; else dis++;
        if (pop) { if (same) pagree++; else pdis++; }
        if ((all || !same) && (!onlyParam || pop))
            printf("CELL\t%s\t%s\tG\t%s\tO\t%s\n", same ? "SAME" : "DIFF",
                   k.c_str(), g.payload.c_str(), o.payload.c_str());
        if (!same && pop)
            fam[g.view + "\t" + g.home + "\t" + g.payload + "  >  " + o.payload]++;
    }
    for (auto& [k, o] : O)
        if (!G.count(k)) {
            uo++;
            if (!onlyParam || o.param)
                printf("ONLY-OURS\t%s\t%s\n", k.c_str(), o.payload.c_str());
        }
    printf("SUMMARY\tagree=%d\tdisagree=%d\tonly_golden=%d\tonly_ours=%d"
           "\tPARAM agree=%d\tdisagree=%d\n",
           agree, dis, ug, uo, pagree, pdis);
    printf("== FAMILIES (view / home / golden > ours)\n");
    for (auto& [f, c] : fam) printf("FAM\t%6d\t%s\n", c, f.c_str());
    return 0;
}
