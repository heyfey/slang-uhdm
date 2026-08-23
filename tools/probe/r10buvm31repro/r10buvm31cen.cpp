// r10buvm31 — THE DECLARATION-INITIALIZER CENSUS.  MEASUREMENT ONLY; nothing
// here is an acceptance judge (uhdm-cmp and scripts/verify_golden.py are).
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// FAMILY `VAR` — one row per `variables` object, carrying
//   * LOC   — line:col of the variable's NAME span, the only key stable across
//             the two sides (our expression nodes carry an EMPTY VpiFile —
//             buvm16's trap — so no file enters the key).
//   * KIND  — the UHDM object kind of the variable (array_var / int_var / ...).
//   * ATYPE — vpiArrayType (0 = not an array_var; 1 static, 2 dynamic,
//             3 assoc, 4 queue), so the assoc / queue / dynamic / fixed split
//             is a COLUMN and never a guess.
//   * NAME  — VpiName (payload only; naming is context-dependent, RESUME §9).
//   * HOME  — nearest enclosing class_defn / package / module_inst /
//             function / task, as `<kind>:<fullname>`; payload only.
//   * EXPR  — the JUDGE-VISIBLE shape of `vpiExpr`, recursively:
//               `-`                    no vpiExpr at all
//               `C(ct=<n>,sz=<n>,dc=<decompile>)`     a constant
//               `OP<optype>(<child>,...)`             an operation
//               `TP[<tagkind>:<tagname>]{<pattern>}`  a tagged_pattern
//               `<kind>:<VpiName>`                    anything else
//             `variables::Compare` reads `Expr()`, `operation::Compare` reads
//             VpiOpType + Operands, `tagged_pattern::Compare` reads Typespec +
//             Pattern, and `constant::Compare` reads VpiDecompile / VpiSize /
//             VpiConstType (NOT VpiValue) — so every field printed here is one
//             the judge reads, and none that it does not.
//   * EPAR  — the NON-judge-visible companion: the vpiExpr's own vpiParent
//             KIND (array_var vs its vpiReg element), which is what makes the
//             "parented at the element" half of the shape visible without ever
//             entering a key.
//   * REACH — Y when the variable is reachable from a design root (buvm23's
//             verifier lesson: Serializer::AllObjects counts ORPHANS).
//
// usage: r10buvm31cen <file.uhdm> [tag]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <set>
#include <string>
using namespace UHDM;

static std::string kd(const any* t) {
    return t ? std::string(UhdmName(t->UhdmType())) : "NULL";
}
static std::string esc(std::string s) {
    for (auto& c : s)
        if (c == '\t' || c == '\n' || c == '|') c = ' ';
    return s;
}
static std::string loc(const any* o) {
    return o ? std::to_string(o->VpiLineNo()) + ":" +
                   std::to_string(o->VpiColumnNo())
             : "-";
}
static std::string fnm(const any* t) {
    if (!t) return "-";
    if (const scope* sc = any_cast<const scope*>(t))
        return std::string(sc->VpiFullName());
    return std::string(t->VpiName());
}

static std::string shape(const any* e, int d) {
    if (!e) return "-";
    if (d > 8) return "...";
    switch (e->UhdmType()) {
        case uhdmconstant: {
            const constant* c = (const constant*)e;
            return "C(ct=" + std::to_string(c->VpiConstType()) +
                   ",sz=" + std::to_string(c->VpiSize()) + ",dc=" +
                   esc(std::string(c->VpiDecompile())) + ")";
        }
        case uhdmoperation: {
            const operation* o = (const operation*)e;
            std::string r = "OP" + std::to_string(o->VpiOpType()) + "(";
            bool first = true;
            if (auto* ops = o->Operands())
                for (auto* a : *ops) {
                    if (!first) r += ",";
                    first = false;
                    r += shape(a, d + 1);
                }
            return r + ")";
        }
        case uhdmtagged_pattern: {
            const tagged_pattern* t = (const tagged_pattern*)e;
            const typespec* ts = t->Typespec() ? t->Typespec()->Actual_typespec()
                                               : nullptr;
            return "TP[" + kd(ts) + ":" +
                   (ts ? esc(std::string(ts->VpiName())) : std::string("-")) +
                   "@" + loc(ts) + "]{" + shape(t->Pattern(), d + 1) + "}";
        }
        default:
            return kd(e) + ":" + esc(std::string(e->VpiName()));
    }
}

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "usage: r10buvm31cen <file.uhdm> [tag]\n";
        return 2;
    }
    std::string tag = argc > 2 ? argv[2] : "T";
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) {
        std::cout << "RESTORE_FAIL " << tag << "\n";
        return 3;
    }
    std::set<const any*> roots;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o || o->UhdmType() != uhdmdesign) continue;
        const design* dd = (const design*)o;
        if (auto* v = dd->TopPackages())   for (auto* p : *v) roots.insert(p);
        if (auto* v = dd->TopModules())    for (auto* p : *v) roots.insert(p);
        if (auto* v = dd->AllPackages())   for (auto* p : *v) roots.insert(p);
        if (auto* v = dd->AllModules())    for (auto* p : *v) roots.insert(p);
        if (auto* v = dd->AllClasses())    for (auto* p : *v) roots.insert(p);
        if (auto* v = dd->AllPrograms())   for (auto* p : *v) roots.insert(p);
        if (auto* v = dd->AllInterfaces()) for (auto* p : *v) roots.insert(p);
    }
    long n = 0;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o) continue;
        const variables* v = any_cast<const variables*>(o);
        if (!v) continue;
        int atype = 0;
        if (o->UhdmType() == uhdmarray_var)
            atype = ((const array_var*)o)->VpiArrayType();
        const any* owner = nullptr;
        bool reach = false;
        const any* p = o->VpiParent();
        int dd = 0;
        while (p && dd++ < 300) {
            UHDM_OBJECT_TYPE t = p->UhdmType();
            if (!owner && (t == uhdmfunction || t == uhdmtask ||
                           t == uhdmclass_defn || t == uhdmmodule_inst ||
                           t == uhdmpackage))
                owner = p;
            if (roots.count(p)) { reach = true; break; }
            if (t == uhdmdesign) { reach = true; break; }
            p = p->VpiParent();
        }
        const any* ex = v->Expr();
        std::cout << tag << "\tVAR\t" << loc(o) << "\t" << kd(o)
                  << "\tat=" << atype << "\t" << esc(std::string(v->VpiName()))
                  << "\thome=" << (owner ? kd(owner) : std::string("-")) << ":"
                  << esc(fnm(owner)) << "\texpr=" << shape(ex, 0)
                  << "\tepar=" << (ex && ex->VpiParent() ? kd(ex->VpiParent())
                                                         : std::string("-"))
                  << "\treach=" << (reach ? "Y" : "N") << "\n";
        n++;
    }
    std::cerr << "ROWS " << tag << " VAR " << n << "\n";
    return 0;
}
