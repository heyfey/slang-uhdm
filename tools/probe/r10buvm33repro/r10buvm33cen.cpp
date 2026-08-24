// r10buvm33 — THE SCOPED-DATA-REFERENCE CENSUS.  MEASUREMENT ONLY; nothing
// here is an acceptance judge (uhdm-cmp and scripts/verify_golden.py are).
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// TWO FAMILIES, both enumerated by the SAME rule on both sides so the join is
// symmetric and neither producer's vocabulary decides the key:
//
//  * `FEHDR` — one row per `foreach_stmt`, carrying the object under
//    `vpiVariables` (the ARRAY REFERENCE) and, through its `vpiTypespec`, the
//    ACTUAL typespec.  This is the face § foreachScopedArrayWrittenClassVar33
//    owns: Surelog reaches it through `compileVariable`
//    (CompileStmt.cpp:527 -> CompileType.cpp:554), not `compileExpression`.
//    SCOPED=Y when the array reference's VpiName carries a `::`.
//
//  * `SDREF` — every DATA reference object whose VpiName carries a `::`:
//    `ref_obj`, `ref_var`, any `variables` kind, `hier_path`, `bit_select`,
//    `part_select`, `indexed_part_select`, `var_select`.  Call objects are
//    DELIBERATELY excluded — that population is buvm32's `SCALL` census and
//    its law (§ classScopeCallWrittenQualifierIsLookupKey32) is already
//    landed.  POS (the vpiParent kind) splits the positions the brief asks
//    for: `foreach_stmt` = a foreach array ref, `assignment` = an Lhs/Rhs,
//    `bit_select`/`operation` = an indexed read, `func_call`/
//    `method_func_call`/`sys_func_call` = an argument or a receiver,
//    `begin`/`function` = a bare statement.
//
// COLUMNS.  The key is LOC + NAME + HOME; everything else is payload.
//   * LOC   — `line:col-endline:endcol`.  Our expression nodes carry an EMPTY
//             VpiFile (buvm16's trap), so no file enters the key.
//   * KIND  — the UHDM object kind.  THE column this pass is about.
//   * NAME  — VpiName: golden's is the WRITTEN two-segment scoped text, ours
//             (before this pass) the resolved leaf.
//   * TS    — the ACTUAL typespec's `<kind>'<name>'@<span>`; `-` when none.
//             `class_var::Compare` walks the typespec, so this is
//             judge-visible, not decoration.
//   * HOME  — nearest enclosing function / task / class_defn / package /
//             module_inst as `<kind>:<fullname>` — the out-of-body / in-body /
//             package-function / module split, read off the tree.
//   * POS   — the vpiParent's KIND (payload; no generated Compare reads
//             VpiParent).
//   * REACH — Y when the object is reachable from a design root (buvm23:
//             `Serializer::AllObjects` counts ORPHANS, invisible to the judge).
//
// usage: r10buvm33cen <file.uhdm> [tag]
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
static std::string span(const any* o) {
    if (!o) return "-";
    return std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo()) + "-" +
           std::to_string(o->VpiEndLineNo()) + ":" +
           std::to_string(o->VpiEndColumnNo());
}
static std::string fnm(const any* t) {
    if (!t) return "-";
    if (const scope* sc = any_cast<const scope*>(t))
        if (!sc->VpiFullName().empty()) return std::string(sc->VpiFullName());
    if (!t->VpiName().empty()) return std::string(t->VpiName());
    return "-";
}
// The ACTUAL typespec behind an object that carries a `vpiTypespec`, as
// `<kind>'<name>'@<span>`.  Read through `ref_typespec::Actual_typespec` —
// never the ref_typespec itself, which carries no kind of its own.
static std::string tsOf(const any* o) {
    const ref_typespec* rt = nullptr;
    if (const variables* v = any_cast<const variables*>(o)) rt = v->Typespec();
    if (!rt) return "-";
    const typespec* a = rt->Actual_typespec();
    if (!a) return "ref_typespec'<null>'@-";
    return kd(a) + "'" + esc(std::string(a->VpiName())) + "'@" + span(a);
}
static bool dataRefKind(UHDM_OBJECT_TYPE t) {
    switch (t) {
        case uhdmref_obj:
        case uhdmhier_path:
        case uhdmbit_select:
        case uhdmpart_select:
        case uhdmindexed_part_select:
        case uhdmvar_select:
            return true;
        default:
            break;
    }
    // every `variables` kind (ref_var, class_var, array_var, int_var, ...)
    return false;
}

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "usage: r10buvm33cen <file.uhdm> [tag]\n";
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
    auto ownerOf = [&](const any* o, bool& reach) -> const any* {
        const any* owner = nullptr;
        const any* p = o->VpiParent();
        int d = 0;
        reach = false;
        while (p && d++ < 300) {
            UHDM_OBJECT_TYPE pt = p->UhdmType();
            if (!owner && (pt == uhdmfunction || pt == uhdmtask ||
                           pt == uhdmclass_defn || pt == uhdmmodule_inst ||
                           pt == uhdmpackage))
                owner = p;
            if (roots.count(p)) { reach = true; break; }
            if (pt == uhdmdesign) { reach = true; break; }
            p = p->VpiParent();
        }
        return owner;
    };
    long nfe = 0, nsd = 0;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o) continue;
        UHDM_OBJECT_TYPE t = o->UhdmType();
        if (t == uhdmforeach_stmt) {
            const foreach_stmt* fs = (const foreach_stmt*)o;
            const any* av = fs->Variable();
            bool reach = false;
            const any* owner = ownerOf(o, reach);
            std::string nm = av ? std::string(av->VpiName()) : std::string("-");
            std::cout << tag << "\tFEHDR\t" << span(o) << "\t"
                      << (av ? kd(av) : std::string("<none>")) << "\t"
                      << esc(nm) << "\tvspan=" << span(av)
                      << "\tts=" << (av ? tsOf(av) : std::string("-"))
                      << "\tscoped="
                      << (nm.find("::") != std::string::npos ? "Y" : "N")
                      << "\thome=" << (owner ? kd(owner) : std::string("-"))
                      << ":" << esc(fnm(owner))
                      << "\treach=" << (reach ? "Y" : "N") << "\n";
            nfe++;
            continue;
        }
        bool isVar = any_cast<const variables*>(o) != nullptr;
        if (!isVar && !dataRefKind(t)) continue;
        std::string nm(o->VpiName());
        if (nm.find("::") == std::string::npos) continue;
        bool reach = false;
        const any* owner = ownerOf(o, reach);
        const any* p = o->VpiParent();
        std::cout << tag << "\tSDREF\t" << span(o) << "\t" << kd(o) << "\t"
                  << esc(nm) << "\tts=" << tsOf(o)
                  << "\thome=" << (owner ? kd(owner) : std::string("-")) << ":"
                  << esc(fnm(owner))
                  << "\tpos=" << (p ? kd(p) : std::string("-"))
                  << "\treach=" << (reach ? "Y" : "N") << "\n";
        nsd++;
    }
    std::cerr << "ROWS " << tag << " FEHDR " << nfe << " SDREF " << nsd << "\n";
    return 0;
}
