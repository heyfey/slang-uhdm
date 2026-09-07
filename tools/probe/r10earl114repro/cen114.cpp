// r10earl114 -- THE hier_path TYPESPEC-EDGE CENSUS.
//
// MEASUREMENT ONLY.  The official uhdm-cmp is the sole acceptance judge.
// LHS is ALWAYS golden; RHS is ALWAYS ours.
//
// The head this pass owns is the `expr::Typespec` edge of a `hier_path` that
// sits in an assignment-pattern operand of an elaborated generate-scope
// continuous assign: golden hangs a MINTED `ref_typespec` whose
// `Actual_typespec` is the ROOT object's own, and we hang NOTHING.
// `hier_path::Compare` reads
//
//   BaseClass::Compare  -> VpiType, VpiName, VpiDefName
//   expr::Compare       -> VpiDecompile, VpiSize, Typespec      <-- THIS PASS
//   hier_path::Compare  -> Path_elems, Root_value, VpiName
//
// and `ref_typespec::Compare` itself reads VpiName, VpiDefName and
// Actual_typespec -- so the payload below spells exactly those, and NOT
// VpiFullName (which no Compare reads and which `ref_typespec::VpiFullName()`
// computes from the parent chain anyway).
//
// THREE families, on r10earl113's precedent:
//
//   PX  the LAW's surface and the READING instrument: every hier_path whose
//       PARENT is an assignment-pattern operation, keyed on span + VpiName +
//       THE MATRIX (scope kind, generate depth, carrier, the carrying
//       cont_assign's Lhs clone gate, and the ROOT KIND -- the axis this pass
//       named as its over-fire risk).  Payload = the typespec edge alone.
//   P0  EVERY hier_path in the database, keyed on span + VpiName, payload =
//       the typespec edge: the coarse view, so nothing hides in the re-keying
//       and a hang landing OUTSIDE the pattern carrier is still counted.
//   PR  THE REST, compare-visible: every hier_path's OTHER judged fields --
//       VpiSize, VpiDecompile, VpiDefName, the Path_elems kinds with each
//       element's Actual_group kind, and the Root_value kind.  The law must
//       leave this family MOVEDWRONG 0 / AWAY 0.
//
// earl60's attrv60.py lesson: NO span and NO fullname in the PAYLOAD.  The span
// is in the KEY only, where it exists purely to JOIN the two sides.  The
// carrier / scope / depth matrix rides in the trailing DIAGNOSTIC column for
// P0 and PR (the scorer ignores it) and in the KEY for PX, where it is a
// reading coordinate this law never writes.
//
// build:
//   g++ -O2 -std=c++17 cen114.cpp -I ~/.local/include \
//       -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o cen114
// usage:
//   cen114 <db.uhdm> [tag]     -- TSV: key \t payload \t count \t diagnostics
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : "-";
}

static std::string base(std::string f) {
    auto p = f.rfind('/');
    if (p != std::string::npos) f = f.substr(p + 1);
    return f.empty() ? std::string("-") : f;
}

static std::string spanOf(const BaseClass* o) {
    char b[128];
    snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(),
             (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo());
    return b;
}

// THE PAYLOAD OF THIS LAW: the typespec edge spelled with exactly the fields
// `ref_typespec::Compare` reads, plus the ACTUAL's kind and name (which is
// what `typespec::Compare` then walks).  A `<none>` here is the pristine
// state of every cell this pass moves.
static std::string tsEdge(const expr* e) {
    if (!e) return "notanexpr";
    auto* rt = e->Typespec();
    if (!rt) return "ts=<none>";
    std::string s = "ts=ref_typespec(n='" + std::string(rt->VpiName()) +
                    "',dn='" + std::string(rt->VpiDefName()) + "')->";
    auto* a = rt->Actual_typespec();
    s += kindOf(a);
    if (a) s += "('" + std::string(a->VpiName()) + "')";
    return s;
}

// THE ROOT KIND -- the axis this pass names as the over-fire risk.  Read off
// the database (the bound Root_value's own kind), never inferred from source.
static std::string rootKind(const hier_path* hp) {
    auto* rv = hp->Root_value();
    if (!rv) return "rv=<none>";
    std::string s = "rv=" + kindOf(rv);
    // WHERE THE ROOT IS DECLARED -- the fence's own coordinate, read off the
    // database as the root object's own vpiParent (gen_scope vs module_inst).
    s += "/rdecl=" + kindOf(rv->VpiParent());
    if (auto* rx = any_cast<const expr*>(rv)) {
        auto* rt = rx->Typespec();
        s += "/rts=";
        if (rt && rt->Actual_typespec())
            s += kindOf(rt->Actual_typespec()) + "('" +
                 std::string(rt->Actual_typespec()->VpiName()) + "')";
        else
            s += "<none>";
    } else {
        s += "/rts=notanexpr";
    }
    return s;
}

static std::map<std::string, std::map<std::string, int>> rows;
static std::map<std::string, std::set<std::string>> diags;

int main(int argc, char** argv) {
    if (argc < 2) {
        fprintf(stderr, "usage: cen114 <db.uhdm> [tag]\n");
        printf("CENRC 2\n");
        return 2;
    }
    const char* tag = argc > 2 ? argv[2] : "";
    Serializer s;
    std::vector<vpiHandle> h = s.Restore(std::string(argv[1]));
    if (h.empty()) {
        fprintf(stderr, "FATAL: load failed\n");
        printf("CENRC 3\n");
        return 3;
    }
    std::set<const BaseClass*> seen;
    for (const auto& p : s.AllObjects()) {
        const BaseClass* o = p.first;
        if (!o || !seen.insert(o).second) continue;
        if (o->UhdmType() != uhdmhier_path) continue;
        auto* hp = (const hier_path*)o;
        auto* hx = (const expr*)hp;

        // THE MATRIX, read off the parent chain.
        int gd = 0;
        std::string carrier = "-";
        std::string scope = "-";
        std::string lhsts = "-";
        std::string par = kindOf(hp->VpiParent());
        bool inPat = false;
        if (auto* pop = any_cast<const operation*>(hp->VpiParent())) {
            par += std::to_string(pop->VpiOpType());
            inPat = pop->VpiOpType() == vpiAssignmentPatternOp ||
                    pop->VpiOpType() == vpiMultiAssignmentPatternOp;
        }
        for (const BaseClass* g = hp->VpiParent(); g; g = g->VpiParent()) {
            UHDM_OBJECT_TYPE t = g->UhdmType();
            if (t == uhdmgen_scope_array) gd++;
            if (carrier == "-" &&
                (t == uhdmcont_assign || t == uhdmparam_assign ||
                 t == uhdminitial || t == uhdmalways || t == uhdmassignment ||
                 t == uhdmfunction || t == uhdmtask)) {
                carrier = kindOf(g);
                if (auto* ca = any_cast<const cont_assign*>(g)) {
                    // The r10earl113 clone gate, read off the database: the
                    // Lhs kind, its typespec edge, its Actual_group and WHERE
                    // that group is declared.
                    lhsts = kindOf(ca->Lhs());
                    if (ca->Lhs()) {
                        if (auto* rt = ca->Lhs()->Typespec())
                            lhsts += "->" + kindOf(rt->Actual_typespec());
                        else
                            lhsts += "->NOTS";
                        if (auto* ro = any_cast<const ref_obj*>(ca->Lhs())) {
                            lhsts += "/act=" + kindOf(ro->Actual_group());
                            lhsts += "/decl=";
                            lhsts += ro->Actual_group()
                                         ? kindOf(ro->Actual_group()->VpiParent())
                                         : "-";
                        }
                    }
                }
            }
            if (scope == "-" &&
                (t == uhdmgen_scope || t == uhdmmodule_inst ||
                 t == uhdmpackage || t == uhdminterface_inst ||
                 t == uhdmfunction || t == uhdmtask))
                scope = kindOf(g);
        }

        std::string nm(hp->VpiName());
        std::string joinKey = spanOf(hp) + "|" + nm;
        std::string diag = base(std::string(hp->VpiFile())) + ";par=" + par +
                           ";car=" + carrier + ";sc=" + scope +
                           ";gd=" + std::to_string(gd) + ";lhs=" + lhsts;

        // ---- P0: EVERY hier_path, the typespec edge, keyed on the join ----
        std::string k0 = "P0|" + joinKey;
        rows[k0][tsEdge(hx)]++;
        diags[k0].insert(diag);

        // ---- PX: the LAW's surface, keyed on the whole matrix -------------
        // The ROOT KIND rides in the KEY: it is a coordinate this law reads
        // and never writes, and one span can legitimately hold objects with
        // different roots (a def copy and an elaborated one).
        if (inPat) {
            std::string kx = "PX|" + joinKey + "|sc=" + scope +
                             "|gd=" + std::to_string(gd) + "|car=" + carrier +
                             "|lhs=" + lhsts + "|" + rootKind(hp);
            rows[kx][tsEdge(hx)]++;
            diags[kx].insert(base(std::string(hp->VpiFile())) + ";par=" + par);
        }

        // ---- PR: THE REST, compare-visible ------------------------------
        std::string kr = "PR|" + joinKey;
        std::string rp = "sz=" + std::to_string(hx->VpiSize());
        rp += ",dec='" + std::string(hx->VpiDecompile()) + "'";
        rp += ",dn='" + std::string(hp->VpiDefName()) + "'";
        rp += ",root=" + kindOf(hp->Root_value());
        rp += ",elems[";
        if (hp->Path_elems()) {
            size_t i = 0;
            for (auto* e : *hp->Path_elems()) {
                rp += (i++ ? ";" : "");
                rp += kindOf(e) + ":'" + std::string(e->VpiName()) + "'";
                if (auto* ro = any_cast<const ref_obj*>(e))
                    rp += "/act=" + kindOf(ro->Actual_group());
                if (auto* bs = any_cast<const bit_select*>(e))
                    rp += "/ix=" + kindOf(bs->VpiIndex());
            }
        }
        rp += "]";
        rows[kr][rp]++;
        diags[kr].insert(diag);
    }
    for (auto& kv : rows) {
        std::string fl;
        for (auto& f : diags[kv.first]) fl += (fl.empty() ? "" : ",") + f;
        for (auto& pv : kv.second)
            printf("%s%s%s\t%s\t%d\t%s\n", tag, *tag ? "|" : "",
                   kv.first.c_str(), pv.first.c_str(), pv.second, fl.c_str());
    }
    printf("CENRC 0\n");
    return 0;
}
