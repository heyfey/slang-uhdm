// r10buvm16 — THE `new` CENSUS.  MEASUREMENT ONLY; nothing here is an
// acceptance judge (uhdm-cmp and scripts/verify_golden.py are).
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// Prints one row per `method_func_call` whose VpiName is "new" or "super.new"
// — i.e. every dynamic-array allocation `d = new[n]` / `d = new[n](src)`, every
// class construction `h = new(args)`, every `super.new(args)` chain-up and
// every shallow copy `h = new src` — with:
//   * the site (file|line:col), the file recovered from a LINE-CONTAINMENT
//     index because OUR expression nodes carry an EMPTY VpiFile (golden's
//     populateCoreMembers fills it) — keying on the raw VpiFile would make the
//     two sides join on nothing.
//   * `par=` the call's own VpiParent KIND (or NONE).  This is the DISCRIMINATOR
//     the whole pass turns on: Surelog's dynamic-array arm
//     (CompileHelper.cpp:4485) never parents its `fcall`, while the class-new
//     arm three dozen lines below does (`fcall->VpiParent(assign)`).
//   * the enclosing subroutine (name + kind + whether it carries a vpiInstance)
//     from the same containment index, RESTRICTED TO THE RESOLVED FILE — the
//     fcall is UNPARENTED in golden, so the ordinary VpiParent walk finds
//     NOTHING and an index is the only way.
//
// THE `builtin.sv` TRAP, paid for on the first run of this instrument: both
// sides carry the built-in class preamble (ours embedded from share/builtin.sv,
// Surelog's from Builtin::addBuiltinClasses()), its class spans OVERLAP the
// arm's line numbers, and "tightest span wins" then attributed 15 of the arm's
// own cells to `builtin.sv` on ONE side only — 15 phantom asymmetric keys out
// of 71.  Spans from `builtin.sv` are therefore excluded from the index on BOTH
// sides; no corpus source is named that.
//   * EVERY ref in the WHOLE argument subtree (buvm15's blind spot, closed
//     there and kept closed here) with its Actual_group kind+name or BARE.
//
// usage: r10buvm16cen <file.uhdm> [tag]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <algorithm>
#include <iostream>
#include <string>
#include <unordered_map>
#include <vector>
using namespace UHDM;

static std::string nm(const any* t) { return t ? std::string(t->VpiName()) : "-"; }
static std::string kd(const any* t) { return t ? std::string(UhdmName(t->UhdmType())) : "NULL"; }
static std::string base(std::string f) {
    auto s = f.rfind('/');
    return s == std::string::npos ? f : f.substr(s + 1);
}
static std::string loc(const any* o) {
    return o ? std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo()) : "-";
}

struct Span {
    std::string file, name, kind;
    uint32_t l0, l1;
    int inst;
};

// Collect every ref_obj under `o`, depth-limited.  A `new[...]` size can be a
// bare ref, an operation, a select, a nested call or a nested `new` — all of
// which hide refs the direct-argument reading would miss.
static void refsUnder(const any* o, std::vector<const any*>& out, int d = 0) {
    if (!o || d > 12) return;
    switch (o->UhdmType()) {
        case uhdmref_obj: out.push_back(o); return;
        case uhdmoperation:
            if (auto* ops = ((const operation*)o)->Operands())
                for (auto* x : *ops) refsUnder(x, out, d + 1);
            return;
        // A bit-select is BOTH a bindable node of its own (it carries an
        // Actual_group) and a container: `new[arr[i]]` hides `i` in VpiIndex,
        // and a census that stopped at the select would call a moved `i` no
        // move at all.
        case uhdmbit_select:
            out.push_back(o);
            refsUnder(((const bit_select*)o)->VpiIndex(), out, d + 1);
            return;
        case uhdmpart_select:
            refsUnder(((const part_select*)o)->Left_range(), out, d + 1);
            refsUnder(((const part_select*)o)->Right_range(), out, d + 1);
            return;
        case uhdmindexed_part_select:
            refsUnder(((const indexed_part_select*)o)->Base_expr(), out, d + 1);
            refsUnder(((const indexed_part_select*)o)->Width_expr(), out, d + 1);
            return;
        case uhdmvar_select:
            if (auto* xs = ((const var_select*)o)->Exprs())
                for (auto* x : *xs) refsUnder(x, out, d + 1);
            return;
        case uhdmsys_task_call:
            if (auto* as = ((const sys_task_call*)o)->Tf_call_args())
                for (auto* x : *as) refsUnder(x, out, d + 1);
            return;
        case uhdmmethod_task_call:
            if (auto* as = ((const method_task_call*)o)->Tf_call_args())
                for (auto* x : *as) refsUnder(x, out, d + 1);
            return;
        case uhdmtask_call:
            if (auto* as = ((const task_call*)o)->Tf_call_args())
                for (auto* x : *as) refsUnder(x, out, d + 1);
            return;
        case uhdmhier_path:
            if (auto* es = ((const hier_path*)o)->Path_elems())
                for (auto* x : *es) refsUnder(x, out, d + 1);
            return;
        case uhdmmethod_func_call:
            if (auto* as = ((const method_func_call*)o)->Tf_call_args())
                for (auto* x : *as) refsUnder(x, out, d + 1);
            return;
        case uhdmfunc_call:
            if (auto* as = ((const func_call*)o)->Tf_call_args())
                for (auto* x : *as) refsUnder(x, out, d + 1);
            return;
        case uhdmsys_func_call:
            if (auto* as = ((const sys_func_call*)o)->Tf_call_args())
                for (auto* x : *as) refsUnder(x, out, d + 1);
            return;
        default: return;
    }
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: r10buvm16cen <file.uhdm> [tag]\n"; return 2; }
    std::string tag = argc > 2 ? argv[2] : "T";
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { std::cout << "RESTORE_FAIL " << tag << "\n"; return 3; }

    // ---- the containment index.
    std::vector<Span> files, subs;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o) continue;
        uint32_t l0 = o->VpiLineNo(), l1 = o->VpiEndLineNo();
        std::string f(o->VpiFile());
        if (!f.empty() && l0 && l1 >= l0 && base(f) != "builtin.sv")
            files.push_back({base(f), nm(o), kd(o), l0, l1, 0});
        UHDM_OBJECT_TYPE t = o->UhdmType();
        if ((t == uhdmfunction || t == uhdmtask) && l0 && l1 >= l0 &&
            base(f) != "builtin.sv") {
            int inst = 0;
            if (t == uhdmfunction) inst = ((const function*)o)->Instance() ? 1 : 0;
            else inst = ((const task*)o)->Instance() ? 1 : 0;
            subs.push_back({base(f), nm(o), kd(o), l0, l1, inst});
        }
    }
    // `file` empty = any file; otherwise the span must be IN that file, which
    // is how the subroutine lookup is kept from naming a same-lined routine
    // from a different source.
    auto tightest = [](const std::vector<Span>& v, uint32_t l,
                       const std::string& file) -> const Span* {
        const Span* best = nullptr;
        for (auto& sp : v) {
            if (!file.empty() && sp.file != file) continue;
            if (sp.l0 <= l && l <= sp.l1)
                if (!best || (sp.l1 - sp.l0) < (best->l1 - best->l0)) best = &sp;
        }
        return best;
    };

    long n = 0;
    std::vector<std::string> rows;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o || o->UhdmType() != uhdmmethod_func_call) continue;
        std::string cn = nm(o);
        if (cn != "new" && cn != "super.new") continue;
        auto* mfc = (const method_func_call*)o;
        uint32_t l = o->VpiLineNo();
        const Span* fsp = tightest(files, l, std::string());
        const Span* ssp = fsp ? tightest(subs, l, fsp->file) : nullptr;
        // THE ROW IS SPLIT IN TWO, and the split is what makes the join sound.
        //   sh= the SHAPE: each argument's kind and name plus every nested
        //       ref's name and source position.  IDENTICAL on both sides for
        //       one and the same source site, so it belongs in the KEY.
        //   ac= the ACTUALS: `name@loc->kind(name)` or `->BARE`.  This is the
        //       ONLY thing this pass moves, so it is the VALUE.
        // Keying on `sh=` is what separates two different sites that share a
        // line:col in a multi-file design — the trap that made the file-keyed
        // join bucket 270 real bind rows as ARITY and the loc-keyed join
        // CONFLATE `uvm_reg_map.svh:1427` with another file's line 1427.
        std::string shape, acts;
        int na = 0, nref = 0;
        if (auto* as = mfc->Tf_call_args()) {
            for (auto* a : *as) {
                if (!shape.empty()) shape += ",";
                shape += std::to_string(na) + "=" + kd(a) + "(" + nm(a) + ")";
                na++;
                std::vector<const any*> rs;
                refsUnder(a, rs);
                std::vector<std::string> sp, ap;
                for (auto* r : rs) {
                    const any* ag = nullptr;
                    if (r->UhdmType() == uhdmref_obj) ag = ((const ref_obj*)r)->Actual_group();
                    else if (r->UhdmType() == uhdmbit_select) ag = ((const bit_select*)r)->Actual_group();
                    sp.push_back(nm(r) + "@" + loc(r));
                    ap.push_back(nm(r) + "@" + loc(r) + "->" +
                                 (ag ? kd(ag) + "(" + nm(ag) + ")" : "BARE"));
                    nref++;
                }
                std::sort(sp.begin(), sp.end());
                std::sort(ap.begin(), ap.end());
                for (auto& x : sp) shape += "[" + x + "]";
                for (auto& x : ap) { if (!acts.empty()) acts += ";"; acts += x; }
            }
        }
        // FIELD ORDER IS LOAD-BEARING.  Everything up to and including `a=`
        // is the COMPARED CELL; `sub=`/`sk=`/`si=` are DIAGNOSTICS printed
        // after it and cut off by grid16.sh, because OUR functions carry no
        // VpiFile and so resolve to `?` where golden names the routine — a
        // difference that says nothing about binding and would otherwise make
        // every cell read as a disagreement.
        rows.push_back("NEW " + tag + " key=" + (fsp ? fsp->file : "?") + "|" + loc(o) +
                       " nm=" + cn + " par=" + (o->VpiParent() ? kd(o->VpiParent()) : "NONE") +
                       " na=" + std::to_string(na) + " nref=" + std::to_string(nref) +
                       " sh=" + (shape.empty() ? "<none>" : shape) +
                       " a=" + (acts.empty() ? "<none>" : acts) +
                       " sub=" + (ssp ? ssp->name : "?") + " sk=" + (ssp ? ssp->kind : "?") +
                       " si=" + (ssp ? std::to_string(ssp->inst) : "?"));
        n++;
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) std::cout << r << "\n";
    std::cout << "SUMMARY " << tag << " newcalls=" << n << "\n";
    return 0;
}
