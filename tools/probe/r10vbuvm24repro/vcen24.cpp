// r10vbuvm24repro/vcen24.cpp — THE VERIFIER'S CALL-ARGUMENT CENSUS.
// MEASUREMENT ONLY; uhdm-cmp and scripts/verify_golden.py are the judges.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// Independent of r10buvm24cen.cpp in two ways that matter to a verifier:
//   * the argument payload RECURSES one level (an `operation`'s operands, a
//     `func_call`'s own arguments, a `ref_obj`'s Actual_group kind), so a
//     regression that swaps an operand while keeping the top kind cannot hide
//     behind a `<kind>:<name>` string;
//   * the row carries NARG separately from the payload, so the multiset
//     comparator can be keyed WITHOUT it (view-general, count-free) and the
//     count reported on its own.
//
// KEY (chosen by the comparator, not here): loc + kind + name.  No view label,
// no fullname, no VpiFile (our expression nodes carry an EMPTY VpiFile).
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <iostream>
#include <set>
#include <string>
using namespace UHDM;

static std::string kd(const any* t) { return t ? std::string(UhdmName(t->UhdmType())) : "NULL"; }
static std::string esc(std::string s) {
    for (auto& c : s) if (c=='\t'||c=='\n'||c=='|'||c=='\r') c = ' ';
    return s;
}
static std::string loc(const any* o) {
    return o ? std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo()) : "-";
}
static bool isCall(const any* o) {
    switch (o->UhdmType()) {
        case uhdmfunc_call: case uhdmtask_call:
        case uhdmmethod_func_call: case uhdmmethod_task_call:
        case uhdmsys_func_call: case uhdmsys_task_call: return true;
        default: return false;
    }
}
static std::string sig(const any* a, int depth);
static std::string kids(const any* a, int depth) {
    std::string r;
    if (const operation* op = any_cast<const operation*>(a)) {
        r += "op=" + std::to_string(op->VpiOpType()) + "(";
        if (auto* v = op->Operands()) { bool f=true; for (auto* x : *v){ if(!f) r+=","; f=false; r+=sig(x,depth-1);} }
        r += ")";
    } else if (const tf_call* tc = any_cast<const tf_call*>(a)) {
        r += "(";
        if (auto* v = tc->Tf_call_args()) { bool f=true; for (auto* x : *v){ if(!f) r+=","; f=false; r+=sig(x,depth-1);} }
        r += ")";
    } else if (const ref_obj* ro = any_cast<const ref_obj*>(a)) {
        r += "[act=" + kd(ro->Actual_group()) + "]";
    }
    return r;
}
static std::string sig(const any* a, int depth) {
    if (!a) return "NULL";
    if (a->UhdmType() == uhdmconstant) {
        const constant* c = (const constant*)a;
        return "C:ct=" + std::to_string(c->VpiConstType()) +
               ":sz=" + std::to_string(c->VpiSize()) +
               ":dc=" + esc(std::string(c->VpiDecompile())) +
               ":ts=" + (c->Typespec() ? kd(c->Typespec()) : std::string("-"));
    }
    std::string r = kd(a) + ":" + esc(std::string(a->VpiName()));
    if (depth > 0) r += kids(a, depth);
    return r;
}
static std::string xsig(const any* a) {
    if (!a) return "NULL";
    std::string v = "-";
    if (const expr* e = any_cast<const expr*>(a)) v = esc(std::string(e->VpiValue()));
    return "v=" + v + ":l=" + loc(a) + ":p=" + (a->VpiParent() ? kd(a->VpiParent()) : std::string("NONE"));
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: vcen24 <file.uhdm> [tag]\n"; return 2; }
    std::string tag = argc > 2 ? argv[2] : "T";
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { std::cout << "RESTORE_FAIL " << tag << "\n"; return 3; }
    long n = 0;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o || !isCall(o)) continue;
        const VectorOfany* av = nullptr;
        if (const sys_func_call* f = any_cast<const sys_func_call*>(o)) av = f->Tf_call_args();
        else if (const sys_task_call* t = any_cast<const sys_task_call*>(o)) av = t->Tf_call_args();
        else av = ((const tf_call*)o)->Tf_call_args();
        std::string p, x; int na = 0;
        if (av) for (auto* a : *av) { if (na++) { p += "|"; x += "|"; } p += sig(a, 1); x += xsig(a); }
        std::cout << tag << "\tCALL\t" << loc(o) << "\t" << kd(o) << "\t"
                  << esc(std::string(o->VpiName())) << "\t" << na << "\t"
                  << (p.empty() ? "-" : p) << "\t" << (x.empty() ? "-" : x) << "\n";
        n++;
    }
    std::cerr << "ROWS " << tag << " " << n << "\n";
    return 0;
}
