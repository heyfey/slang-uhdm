// r10buvm21 — THE FORMAL-REFERENCE BIND CENSUS.  MEASUREMENT ONLY; nothing
// here is an acceptance judge (uhdm-cmp and scripts/verify_golden.py are).
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// One row per REFERENCE (ref_obj / bit_select / ref_var / hier_path element)
// whose VpiName equals the name of an `io_decl` of the ENCLOSING subroutine.
// The row carries
//   * VIEW: DEFPKG / ELABPKG / DEFCLASS / TOPMOD / DEFMOD / ... decided by the
//     root ancestor's listing membership (buvm17's classifier).
//   * HOME: the enclosing function/task VpiFullName, its kind, whether it sits
//     under a class_defn, and whether that class listing is reached from the
//     package listing (in-body) or from AllClasses (def-class listing).
//   * SHAPE: the ancestor kind chain from the reference up to the enclosing
//     subroutine, with `operation` carrying its vpiOpType and the SLOT the
//     child occupies where the parent distinguishes slots (bit_select INDEX,
//     assignment LHS/RHS, ...).  This is the POSITION axis.
//   * DIR: the io_decl's vpiDirection.
//   * VALUE: the reference's Actual_group as kind(name), or BARE.
//
// Locations, not files: our expression nodes carry an EMPTY VpiFile
// (buvm16 § 4), so the key is subroutine-fullname + name + line:col.
//
// usage: r10buvm21cen <file.uhdm> [tag]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <iostream>
#include <map>
#include <set>
#include <string>
#include <vector>
using namespace UHDM;

static std::string nm(const any* t) { return t ? std::string(t->VpiName()) : "-"; }
static std::string kd(const any* t) { return t ? std::string(UhdmName(t->UhdmType())) : "NULL"; }
static std::string fnm(const any* t) {
    if (!t) return "-";
    if (t->UhdmType() == uhdmfunction) return std::string(((const function*)t)->VpiFullName());
    if (t->UhdmType() == uhdmtask) return std::string(((const task*)t)->VpiFullName());
    return std::string(t->VpiName());
}
static std::string loc(const any* o) {
    return o ? std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo()) : "-";
}
// the actual, as a Compare-visible payload
static const any* actualOf(const any* o) {
    if (!o) return nullptr;
    switch (o->UhdmType()) {
        case uhdmref_obj: return ((const ref_obj*)o)->Actual_group();
        case uhdmbit_select: return ((const bit_select*)o)->Actual_group();
        case uhdmref_var: return ((const ref_var*)o)->Actual_group();
        default: return nullptr;
    }
}
static bool isRefKind(const any* o) {
    if (!o) return false;
    UHDM_OBJECT_TYPE t = o->UhdmType();
    return t == uhdmref_obj || t == uhdmbit_select || t == uhdmref_var;
}
// which SLOT of `p` does `c` occupy?  Only slots that are semantically
// distinct are named; everything else is "-".
static std::string slotOf(const any* p, const any* c) {
    if (!p || !c) return "-";
    switch (p->UhdmType()) {
        case uhdmbit_select: {
            const bit_select* b = (const bit_select*)p;
            if (b->VpiIndex() == c) return "IDX";
            return "-";
        }
        case uhdmpart_select: {
            const part_select* b = (const part_select*)p;
            if (b->Left_range() == c) return "LR";
            if (b->Right_range() == c) return "RR";
            return "-";
        }
        case uhdmindexed_part_select: {
            const indexed_part_select* b = (const indexed_part_select*)p;
            if (b->Base_expr() == c) return "BASE";
            if (b->Width_expr() == c) return "W";
            return "-";
        }
        case uhdmassignment: {
            const assignment* a = (const assignment*)p;
            if (a->Lhs() == c) return "LHS";
            if (a->Rhs() == c) return "RHS";
            return "-";
        }
        case uhdmassign_stmt: {
            const assign_stmt* a = (const assign_stmt*)p;
            if (a->Lhs() == c) return "LHS";
            if (a->Rhs() == c) return "RHS";
            return "-";
        }
        case uhdmoperation: {
            const operation* op = (const operation*)p;
            if (auto* v = op->Operands())
                for (size_t i = 0; i < v->size(); i++)
                    if (v->at(i) == c) return "OP" + std::to_string(i);
            return "-";
        }
        case uhdmreturn_stmt: return "RET";
        case uhdmif_stmt: case uhdmif_else: return "COND";
        case uhdmfunc_call: case uhdmtask_call:
        case uhdmmethod_func_call: case uhdmmethod_task_call:
        case uhdmsys_func_call: case uhdmsys_task_call: return "ARG";
        default: return "-";
    }
}
static std::string kindWithOp(const any* p) {
    if (!p) return "NULL";
    std::string k = kd(p);
    if (p->UhdmType() == uhdmoperation)
        k += "#" + std::to_string(((const operation*)p)->VpiOpType());
    return k;
}
// the KIND of thing being indexed (assoc-by-enum / assoc-by-int / queue /
// dynamic / fixed / -), read off the bit_select's own Actual_group typespec.
static std::string arrayKindOf(const any* bs) {
    if (!bs || bs->UhdmType() != uhdmbit_select) return "-";
    const any* a = ((const bit_select*)bs)->Actual_group();
    if (!a) return "unbound";
    const ref_typespec* rt = nullptr;
    switch (a->UhdmType()) {
        case uhdmarray_var: rt = ((const array_var*)a)->Typespec(); break;
        case uhdmlogic_var: rt = ((const logic_var*)a)->Typespec(); break;
        case uhdmint_var: rt = ((const int_var*)a)->Typespec(); break;
        default: break;
    }
    const any* ts = rt ? rt->Actual_typespec() : nullptr;
    if (!ts) return kd(a) + "/notype";
    return kd(a) + "/" + kd(ts);
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: r10buvm21cen <file.uhdm> [tag]\n"; return 2; }
    std::string tag = argc > 2 ? argv[2] : "T";
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { std::cout << "RESTORE_FAIL " << tag << "\n"; return 3; }

    std::map<const any*, std::string> rootView;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o || o->UhdmType() != uhdmdesign) continue;
        const design* d = (const design*)o;
        if (auto* v = d->TopPackages()) for (auto* p : *v) rootView.emplace(p, "ELABPKG");
        if (auto* v = d->TopModules()) for (auto* p : *v) rootView.emplace(p, "TOPMOD");
        if (auto* v = d->AllPackages()) for (auto* p : *v) rootView.emplace(p, "DEFPKG");
        if (auto* v = d->AllModules()) for (auto* p : *v) rootView.emplace(p, "DEFMOD");
        if (auto* v = d->AllClasses()) for (auto* p : *v) rootView.emplace(p, "DEFCLASS");
        if (auto* v = d->AllPrograms()) for (auto* p : *v) rootView.emplace(p, "DEFPROG");
        if (auto* v = d->AllInterfaces()) for (auto* p : *v) rootView.emplace(p, "DEFIFACE");
    }

    long rows = 0;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!isRefKind(o)) continue;
        if (o->VpiName().empty()) continue;
        // walk up: shape, enclosing subroutine, view
        std::string shape;
        const any* c = o;
        const any* p = o->VpiParent();
        const any* sub = nullptr;
        const any* clsAnc = nullptr;
        const any* root = nullptr;
        int d = 0;
        bool orphan = (p == nullptr);
        while (p && d++ < 64) {
            UHDM_OBJECT_TYPE t = p->UhdmType();
            if (!sub && (t == uhdmfunction || t == uhdmtask)) sub = p;
            if (!sub) {
                std::string sl = slotOf(p, c);
                shape += (shape.empty() ? "" : "<") + kindWithOp(p) + (sl == "-" ? "" : ":" + sl);
            }
            if (!clsAnc && t == uhdmclass_defn) clsAnc = p;
            auto it = rootView.find(p);
            if (it != rootView.end()) { root = p; break; }
            if (t == uhdmdesign) break;
            c = p; p = p->VpiParent();
        }
        if (!sub) continue;                     // only subroutine bodies
        // is `o` a reference to a FORMAL of `sub`?
        const std::vector<io_decl*>* ios = nullptr;
        std::string dir = "-";
        if (sub->UhdmType() == uhdmfunction) ios = ((const function*)sub)->Io_decls();
        else ios = ((const task*)sub)->Io_decls();
        const io_decl* match = nullptr;
        if (ios) for (auto* io : *ios) if (io && io->VpiName() == o->VpiName()) { match = io; break; }
        // ALLREFS=1 widens the census from FORMAL references to EVERY named
        // reference inside a subroutine body (locals, class properties, ...) —
        // the axis the ++ bind law needs, since golden binds a body LOCAL there
        // too and leaves a class PROPERTY bare.
        static const bool allRefs = (getenv("ALLREFS") != nullptr);
        if (!match && !allRefs) continue;
        dir = match ? std::to_string(match->VpiDirection()) : std::string("-");
        std::string view = root ? rootView[root] : (orphan ? "ORPHAN" : "OTHER");
        // home classification
        std::string home = fnm(sub);
        std::string hk = kd(sub);
        std::string inCls = clsAnc ? "cls" : "nocls";
        // in-body vs OOB: golden lists an OOB method at its prototype's loc; we
        // record the subroutine's own parent kind instead (class_defn == listed
        // inside the class body).
        std::string subParent = kd(sub->VpiParent());
        const any* ag = actualOf(o);
        std::string val = ag ? kd(ag) + "(" + nm(ag) + ")" : "BARE";
        // arraykind: if this ref is the INDEX of a bit_select, what is indexed
        std::string ak = "-";
        if (o->VpiParent() && o->VpiParent()->UhdmType() == uhdmbit_select &&
            ((const bit_select*)o->VpiParent())->VpiIndex() == o)
            ak = arrayKindOf(o->VpiParent());
        std::cout << tag << "\t" << view << "\t" << home << "\t" << hk << "\t"
                  << inCls << "\t" << subParent << "\t" << kd(o) << "\t"
                  << nm(o) << "@" << loc(o) << "\t" << (shape.empty() ? "DIRECT" : shape)
                  << "\tdir=" << dir << "\tak=" << ak << "\t" << val << "\n";
        rows++;
    }
    std::cerr << "ROWS " << tag << " " << rows << "\n";
    return 0;
}
