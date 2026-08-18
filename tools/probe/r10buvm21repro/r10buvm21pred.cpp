// r10buvm21 — THE A-PRIORI MOVER PREDICTOR, from the GOLDEN databases ONLY.
// MEASUREMENT ONLY; not an acceptance judge.
//
// Counts the cells § incDecStmtOperandBinds21 can move: a reference that golden
// BINDS (`Actual_group` set) sitting
//   * directly as the operand of an increment/decrement `operation`
//     (vpiPostIncOp 62 / vpiPreIncOp 63 / vpiPostDecOp 64 / vpiPreDecOp 65), or
//   * as the INDEX of a `bit_select` / `var_select` whose parent is one,
// where the chain from that operation up to the enclosing function/task passes
// only through BLOCK scopes (`begin` / `named_begin` / `fork`), AND the
// enclosing subroutine is one where our emitter is SILENT today — an IN-BODY
// method of a class (a `class_defn` ancestor with the subroutine listed inside
// it) or a `$unit`-scope subroutine (no package/module/class listing ancestor).
// Everywhere else our pristine binary already binds, so no other test can move.
//
// usage: r10buvm21pred <golden.uhdm> [tag]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <string>
using namespace UHDM;

static bool isIncDec(const any* o) {
    if (!o || o->UhdmType() != uhdmoperation) return false;
    int t = ((const operation*)o)->VpiOpType();
    return t == vpiPostIncOp || t == vpiPreIncOp || t == vpiPostDecOp ||
           t == vpiPreDecOp;
}
static const any* actualOf(const any* o) {
    if (!o) return nullptr;
    switch (o->UhdmType()) {
        case uhdmref_obj: return ((const ref_obj*)o)->Actual_group();
        case uhdmref_var: return ((const ref_var*)o)->Actual_group();
        default: return nullptr;
    }
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: r10buvm21pred <file.uhdm> [tag]\n"; return 2; }
    std::string tag = argc > 2 ? argv[2] : "T";
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { std::cout << "RESTORE_FAIL " << tag << "\n"; return 3; }
    long cells = 0;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o) continue;
        UHDM_OBJECT_TYPE ot = o->UhdmType();
        if (ot != uhdmref_obj && ot != uhdmref_var) continue;
        if (!actualOf(o)) continue;                    // golden must BIND it
        const any* p = o->VpiParent();
        if (!p) continue;
        // one optional select step, and only in the INDEX slot
        if (p->UhdmType() == uhdmbit_select) {
            if (((const bit_select*)p)->VpiIndex() != o) continue;
            p = p->VpiParent();
        } else if (p->UhdmType() == uhdmvar_select) {
            bool idx = false;
            if (auto* v = ((const var_select*)p)->Exprs())
                for (auto* e : *v) if (e == o) idx = true;
            if (!idx) continue;
            p = p->VpiParent();
        }
        if (!isIncDec(p)) continue;
        // block scopes only, up to the subroutine
        const any* q = p->VpiParent();
        int d = 0;
        bool ok = false;
        const any* sub = nullptr;
        while (q && d++ < 64) {
            UHDM_OBJECT_TYPE qt = q->UhdmType();
            if (qt == uhdmbegin || qt == uhdmnamed_begin || qt == uhdmfork_stmt) {
                q = q->VpiParent();
                continue;
            }
            if (qt == uhdmfunction || qt == uhdmtask) { ok = true; sub = q; }
            break;
        }
        if (!ok) continue;
        // the silent homes: an IN-BODY class method, or a $unit subroutine
        const any* h = sub->VpiParent();
        bool inBodyClass = h && h->UhdmType() == uhdmclass_defn;
        bool unitSub = (h == nullptr) || (h && h->UhdmType() == uhdmdesign);
        if (!inBodyClass && !unitSub) continue;
        cells++;
    }
    std::cout << "COUNT " << tag << " " << cells << "\n";
    return 0;
}
