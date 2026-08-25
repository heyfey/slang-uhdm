// r10uvm143 — A-PRIORI PREDICTOR for § hpIdxClassBodyNeverLateBinds143.
//
// MEASUREMENT ONLY.  Run on the PRISTINE databases BEFORE the patched sweep:
// it names, cell by cell, every reference the law will strip of its
// `vpiActual`, so the byte-mover set can be predicted BY NAME.
//
// LHS is ALWAYS golden; this tool reads ONE database and says what WOULD move
// in it, so it is run on OURS to predict and on GOLDEN to calibrate (golden
// must report ZERO cells — that IS the law).
//
// The DB-side proxy for the emitter's `inBodyClassMethod88` is the one
// § pkgVarBindsOnlyThroughInstance88 already decoded: a method WRITTEN INSIDE
// a class body has a class_defn parent and a NULL `vpiInstance`, while an
// out-of-body (`extern`) definition compiled at package scope carries the
// package as its instance.
//
// build: g++ -O2 -std=c++17 pred143.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o pred143
// usage: pred143 <db.uhdm>          (prints one CELL line per reference + COUNT)
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
#include <vector>

using namespace UHDM;

static int cells = 0;
static std::string ident(const BaseClass* o) {
    char b[512];
    snprintf(b, sizeof b, "%s(%s)@%u:%u-%u:%u", UhdmName(o->UhdmType()).data(),
             std::string(o->VpiName()).c_str(), o->VpiLineNo(),
             (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo());
    return b;
}
// the same subtree the emitter's hpIdxClassNoBind143 walks
static void scan(const any* ix, const std::string& owner) {
    if (!ix) return;
    switch (ix->UhdmType()) {
        case uhdmref_obj: {
            const ref_obj* r = (const ref_obj*)ix;
            const any* a = r->Actual_group();
            // the emitter's own guard: the late binder never produces a
            // ref_var / ref_obj actual, so such a cell is out of the law
            if (a && (a->UhdmType() == uhdmref_var ||
                      a->UhdmType() == uhdmref_obj))
                break;
            if (a) {
                printf("CELL owner=%s ref=%s actual=%s\n", owner.c_str(),
                       ident(r).c_str(),
                       UhdmName(a->UhdmType()).data());
                cells++;
            }
            break;
        }
        case uhdmoperation:
            if (auto* ops = ((const operation*)ix)->Operands())
                for (auto* o : *ops) scan(o, owner);
            break;
        case uhdmbit_select:
            scan(((const bit_select*)ix)->VpiIndex(), owner);
            break;
        case uhdmvar_select:
            if (auto* ex = ((const var_select*)ix)->Exprs())
                for (auto* e : *ex) scan(e, owner);
            break;
        case uhdmpart_select:
            scan(((const part_select*)ix)->Left_range(), owner);
            scan(((const part_select*)ix)->Right_range(), owner);
            break;
        case uhdmindexed_part_select:
            scan(((const indexed_part_select*)ix)->Base_expr(), owner);
            scan(((const indexed_part_select*)ix)->Width_expr(), owner);
            break;
        case uhdmfunc_call:
        case uhdmsys_func_call:
        case uhdmmethod_func_call: {
            if (ix->UhdmType() == uhdmmethod_func_call)
                scan(((const method_func_call*)ix)->Prefix(), owner);
            if (auto* a = ((const tf_call*)ix)->Tf_call_args())
                for (auto* x : *a) scan(x, owner);
            break;
        }
        case uhdmhier_path:
            if (auto* el = ((const hier_path*)ix)->Path_elems())
                for (auto* e : *el) scan(e, owner);
            break;
        default: break;
    }
}
int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: pred143 <db.uhdm>\n"); return 2; }
    Serializer s;
    const std::vector<vpiHandle> h = s.Restore(std::string(argv[1]));
    if (h.empty()) { fprintf(stderr, "restore failed %s\n", argv[1]); return 3; }
    int paths = 0;
    for (const auto& [obj, id] : s.AllObjects()) {
        if (!obj || obj->UhdmType() != uhdmbit_select) continue;
        const any* hp = obj->VpiParent();
        if (!hp || hp->UhdmType() != uhdmhier_path) continue;
        // owner subroutine
        const any* p = hp->VpiParent();
        while (p && p->UhdmType() != uhdmtask && p->UhdmType() != uhdmfunction)
            p = p->VpiParent();
        if (!p) continue;
        const any* cd = p->VpiParent();
        if (!cd || cd->UhdmType() != uhdmclass_defn) continue;
        if (((const task_func*)p)->Instance()) continue;   // out-of-body
        paths++;
        scan(((const bit_select*)obj)->VpiIndex(),
             std::string(((const task_func*)p)->VpiFullName()));
    }
    printf("PATHS_IN_CLASS_BODY %d\nCELLS %d\n", paths, cells);
    return 0;
}
