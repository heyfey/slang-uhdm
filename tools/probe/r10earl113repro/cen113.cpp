// r10earl113 -- THE ASSIGNMENT-PATTERN FIRST-OPERAND SIZE CENSUS.
//
// MEASUREMENT ONLY.  The official uhdm-cmp is the sole acceptance judge.
// LHS is ALWAYS golden; RHS is ALWAYS ours.
//
// The head this pass owns is the FIRST OPERAND of a gen-scope cont-assign
// assignment-pattern operation: golden leaves its `VpiSize` UNSET (0) where
// we stamp the member width.  `expr::Compare` reads
//
//   BaseClass::Compare  -> VpiType, VpiName, VpiDefName
//   expr::Compare       -> VpiDecompile, VpiSize, Typespec
//
// so `VpiSize` on operand 0 is a judged field of whatever kind that operand
// is (hier_path, ref_obj, constant, operation, ...).
//
// The census enumerates EVERY operation whose VpiOpType is a pattern op
// (75 vpiAssignmentPatternOp, 118 vpiMultiAssignmentPatternOp) -- BY POSITION,
// so a cell that changed KIND is still found under the same key -- in TWO
// families:
//
//   P0   the LAW's surface: operand 0's kind, VpiSize and VpiDecompile.
//   PR   THE REST, compare-visible: the operation's own VpiSize/typespec edge,
//        its operand COUNT, and every operand from index 1 up with its kind
//        and VpiSize.  The law must leave this family MOVEDWRONG 0 / AWAY 0.
//
// earl60's attrv60.py lesson: NO span and NO fullname in the PAYLOAD.  The
// span is in the KEY only, where it exists purely to JOIN the two sides.  The
// CARRIER / SCOPE / DEPTH matrix rides in the trailing DIAGNOSTIC column,
// which the scorer ignores -- it is exactly what the law changes nothing of,
// but a key that carried it would turn every cell one-sided if a parent ever
// re-kinded.
//
// build:
//   g++ -O2 -std=c++17 cen113.cpp -I ~/.local/include \
//       -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o cen113
// usage:
//   cen113 <db.uhdm> [tag]     -- TSV: key \t payload \t count \t diagnostics
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

static std::string ancOf(const BaseClass* o) {
    if (!o) return "-";
    std::string s = kindOf(o);
    if (auto* op = any_cast<const operation*>(o))
        s += std::to_string(op->VpiOpType());
    return s;
}

// One operand, spelled with exactly the fields `expr::Compare` reads on it
// plus its kind (BaseClass::Compare's VpiType).
static std::string opndPayload(const any* e) {
    std::string s = kindOf(e);
    if (!e) return s;
    if (auto* ex = any_cast<const expr*>(e)) {
        s += ",sz=" + std::to_string(ex->VpiSize());
        s += ",dec='" + std::string(ex->VpiDecompile()) + "'";
        s += ",val='" + std::string(ex->VpiValue()) + "'";
    }
    if (auto* c = any_cast<const constant*>(e))
        s += ",ct=" + std::to_string(c->VpiConstType());
    if (auto* op = any_cast<const operation*>(e))
        s += ",ot=" + std::to_string(op->VpiOpType());
    return s;
}

// A short operand form for the REST family (kind + size only): the point of
// that family is "nothing else moved", not a second full transcript.
static std::string opndShort(const any* e) {
    std::string s = kindOf(e);
    if (auto* ex = any_cast<const expr*>(e))
        s += ":" + std::to_string(ex->VpiSize());
    return s;
}

static std::map<std::string, std::map<std::string, int>> rows;
static std::map<std::string, std::set<std::string>> diags;

int main(int argc, char** argv) {
    if (argc < 2) {
        fprintf(stderr, "usage: cen113 <db.uhdm> [tag]\n");
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
        if (o->UhdmType() != uhdmoperation) continue;
        auto* op = (const operation*)o;
        int ot = op->VpiOpType();
        if (ot != vpiAssignmentPatternOp && ot != vpiMultiAssignmentPatternOp)
            continue;
        if (!op->Operands() || op->Operands()->empty()) continue;

        // THE MATRIX, diagnostics only: the ancestor chain (three levels, with
        // operations spelled by their op type and `tagged_pattern` kept), the
        // CARRIER (the nearest cont_assign / process / param_assign ancestor),
        // the SCOPE (module_inst vs gen_scope) and the GENERATE DEPTH.
        std::string ctx;
        const BaseClass* a = op->VpiParent();
        for (int d = 0; d < 3; d++) {
            ctx += (d ? "<" : "") + ancOf(a);
            a = a ? a->VpiParent() : nullptr;
        }
        int gd = 0;
        std::string carrier = "-";
        std::string scope = "-";
        // THE DECODE COLUMN: the carrying cont_assign's Lhs kind and its
        // typespec edge.  Surelog's `UhdmWriter::writeCont_assign`
        // (UhdmWriter.cpp:2178) takes the `expandPatternAssignment` branch --
        // the one that sizes operand 0 through `adjustOpSize` -- only when the
        // Lhs carries a resolvable typespec; without one it flattens ONLY.
        std::string lhsts = "-";
        for (const BaseClass* g = op->VpiParent(); g; g = g->VpiParent()) {
            UHDM_OBJECT_TYPE t = g->UhdmType();
            if (t == uhdmgen_scope_array) gd++;
            if (carrier == "-" &&
                (t == uhdmcont_assign || t == uhdmparam_assign ||
                 t == uhdminitial || t == uhdmalways || t == uhdmassignment ||
                 t == uhdmfunction || t == uhdmtask)) {
                carrier = kindOf(g);
                if (auto* ca = any_cast<const cont_assign*>(g)) {
                    lhsts = kindOf(ca->Lhs());
                    if (ca->Lhs()) {
                        if (auto* rt = ca->Lhs()->Typespec())
                            lhsts += "->" + kindOf(rt->Actual_typespec());
                        else
                            lhsts += "->NOTS";
                        // THE CLONE GATE: `cont_assign::DeepClone`
                        // (UHDM clone_tree.cpp:803-816) flattens the pattern
                        // -- and ONLY flattens it, never sizing an operand --
                        // when the Lhs is a ref_obj whose Actual_group is a
                        // STRUCT_VAR carrying a resolved typespec.  This
                        // column is that gate, read off the database.
                        // ...and WHERE THE TARGET IS DECLARED, which is the
                        // fence: `bindVariable` (CompileStmt.cpp:3089-3148) has
                        // no `gen_scope` case and recurses to the parent, so a
                        // MODULE-BODY target is found from inside a generate
                        // block (the writer's `tps` is filled and
                        // `expandPatternAssignment` sizes operand 0) while a
                        // GEN-LOCAL one is not.  The declaring scope is the
                        // bound object's own vpiParent, read off the database.
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
                 t == uhdmpackage || t == uhdminterface_inst))
                scope = kindOf(g);
        }

        const any* o0 = op->Operands()->at(0);

        std::string key = "P0|" + spanOf(op);
        rows[key][opndPayload(o0)]++;
        std::string diag = base(std::string(op->VpiFile())) + ";ctx=" + ctx +
                           ";car=" + carrier + ";sc=" + scope +
                           ";gd=" + std::to_string(gd) + ";lhs=" + lhsts;
        diags[key].insert(diag);

        // THE GRID FAMILY.  P0's key is the JOIN coordinate (span alone), so a
        // span that exists in both the DEF listing and the ELABORATED tree
        // collapses two different objects into one row and its diagnostic
        // column then carries BOTH classifications -- which is right for a
        // mover census and useless for reading the matrix.  PX keys the SAME
        // payload on span + the matrix (scope, generate depth, carrier, the
        // clone gate), none of which this law touches, so every cell of the
        // grid is separable.  PX is a READING instrument; P0/PR are the scored
        // families.
        // The operand-0 KIND rides in the KEY, not the payload: one span
        // legitimately holds SEVERAL operand-0 objects at once -- golden's
        // arena keeps the flattened operation AND the un-flattened
        // `tagged_pattern` original side by side -- so a key that did not
        // separate them could never reach equality and would score every fixed
        // cell MOVEDWRONG.  This law writes a SIZE and never a kind, so the
        // kind is a stable coordinate; a kind present on one side only lands
        // in the scorer's ONE-SIDED bucket where it belongs.
        std::string xkey = "PX|" + spanOf(op) + "|sc=" + scope +
                           "|gd=" + std::to_string(gd) + "|car=" + carrier +
                           "|lhs=" + lhsts + "|k=" + kindOf(o0);
        std::string xpay = "-";
        if (auto* ex = any_cast<const expr*>(o0)) {
            xpay = "sz=" + std::to_string(ex->VpiSize());
            xpay += ",dec='" + std::string(ex->VpiDecompile()) + "'";
            xpay += ",val='" + std::string(ex->VpiValue()) + "'";
            if (auto* c = any_cast<const constant*>(o0))
                xpay += ",ct=" + std::to_string(c->VpiConstType());
            if (auto* iop = any_cast<const operation*>(o0))
                xpay += ",ot=" + std::to_string(iop->VpiOpType());
        }
        rows[xkey][xpay]++;
        diags[xkey].insert(base(std::string(op->VpiFile())) + ";ctx=" + ctx);

        std::string rkey = "PR|" + spanOf(op);
        std::string rpay = "nop=" + std::to_string(op->Operands()->size());
        rpay += ",osz=" + std::to_string(op->VpiSize());
        rpay += ",ots=";
        if (auto* rt = op->Typespec())
            rpay += kindOf(rt) + "->" + kindOf(rt->Actual_typespec());
        else
            rpay += "-";
        rpay += ",R[";
        for (size_t i = 1; i < op->Operands()->size(); i++)
            rpay += (i > 1 ? ";" : "") + opndShort(op->Operands()->at(i));
        rpay += "]";
        rows[rkey][rpay]++;
        diags[rkey].insert(diag);
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
