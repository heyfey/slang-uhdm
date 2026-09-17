// r11u64 TYPESPEC SIZER / PREDICTOR — for every `typespec_member` in a
// database, print the member typespec's kind, its range bounds (kind + value
// when the bound IS a constant object), and the width UHDM's
// `ExprEval::size(ts, iv, /*inst=*/nullptr, exp, true, true)` answers: the
// width `flattenPatternAssignments` lends an UNSIZED pattern operand.
// `SYM` marks a member whose emitted typespec carries a range bound that is
// NOT a constant object — the only members on which the no-instance width can
// differ from the elaborated one.  Reads PRISTINE databases only; runs no
// binary and reads no source.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdlib>
#include <filesystem>
#include <iostream>
#include <map>
#include <sstream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string kindName(const BaseClass* b) {
    return b ? std::string(UhdmName(b->UhdmType())) : std::string("<none>");
}
// THE LAW'S OWN PREDICATE, transcribed byte-for-byte from
// src/ExprEmit.cpp § patFlatUnsizedMemberNoInstWidth64 so the prediction and the
// emitter cannot disagree: a bound tree of {constant, operation, ref_obj,
// hier_path} that CONTAINS a reference reads 0 and marks the member SYM; a bare
// constant answers itself; anything else DECLINES the whole member (BAIL).
static bool boundTreeKind(const any* e, bool& ref, int depth) {
    if (!e || depth > 16) return false;
    switch (e->UhdmType()) {
        case uhdmconstant: return true;
        case uhdmref_obj:
        case uhdmhier_path: ref = true; return true;
        case uhdmoperation: {
            auto* ops = ((const operation*)e)->Operands();
            if (!ops || ops->empty()) return false;
            for (auto* o : *ops)
                if (!boundTreeKind(o, ref, depth + 1)) return false;
            return true;
        }
        default: return false;
    }
}
static bool boundVal2(const any* e, int64_t& v, bool& sym) {
    if (!e) return false;
    if (e->UhdmType() == uhdmconstant) {
        std::string s2(((const constant*)e)->VpiValue());
        auto c = s2.find(':');
        if (c == std::string::npos) return false;
        std::string pfx = s2.substr(0, c), dig = s2.substr(c + 1);
        if (dig.empty()) return false;
        int base = 0;
        if (pfx == "UINT" || pfx == "INT" || pfx == "DEC") base = 10;
        else if (pfx == "BIN") base = 2;
        else if (pfx == "OCT") base = 8;
        else if (pfx == "HEX") base = 16;
        else return false;
        char* end = nullptr;
        long long r = strtoll(dig.c_str(), &end, base);
        if (!end || *end != '\0') return false;
        v = (int64_t)r;
        return true;
    }
    bool ref = false;
    if (!boundTreeKind(e, ref, 0) || !ref) return false;
    v = 0; sym = true; return true;
}
static int64_t nbits(const typespec* ts, bool& sym, bool& bail, int depth);
static int64_t applyRanges(const VectorOfrange* r, int64_t bits, bool& sym, bool& bail) {
    if (!r) return bits;
    for (auto* ran : *r) {
        int64_t lv = 0, rv = 0;
        if (!boundVal2(ran->Left_expr(), lv, sym) ||
            !boundVal2(ran->Right_expr(), rv, sym)) { bail = true; return 0; }
        bits = bits * ((lv > rv) ? (lv - rv + 1) : (rv - lv + 1));
        if (bits <= 0 || bits > 4096) { bail = true; return 0; }
    }
    return bits;
}
static int64_t nbits(const typespec* ts, bool& sym, bool& bail, int depth) {
    if (!ts || depth > 16) { bail = true; return 0; }
    switch (ts->UhdmType()) {
        case uhdmlogic_typespec: {
            auto* t = (const logic_typespec*)ts;
            int64_t b = 1;
            if (auto* rt = t->Elem_typespec())
                if (auto* at = rt->Actual_typespec()) {
                    bool sb = false;
                    int64_t e = nbits(at, sym, sb, depth + 1);
                    if (!sb) b = e;
                }
            return applyRanges(t->Ranges(), b, sym, bail);
        }
        case uhdmbit_typespec:
            return applyRanges(((const bit_typespec*)ts)->Ranges(), 1, sym, bail);
        case uhdmint_typespec: {
            auto* t = (const int_typespec*)ts;
            auto* r = t->Ranges();
            int64_t b = (r && !r->empty()) ? 1 : 32;
            return applyRanges(r, b, sym, bail);
        }
        case uhdmbyte_typespec: return 8;
        case uhdmshort_int_typespec: return 16;
        case uhdmlong_int_typespec: return 64;
        case uhdmshort_real_typespec:
        case uhdmreal_typespec: return 32;
        case uhdmenum_typespec: {
            auto* rt = ((const enum_typespec*)ts)->Base_typespec();
            if (!rt || !rt->Actual_typespec()) { bail = true; return 0; }
            return nbits(rt->Actual_typespec(), sym, bail, depth + 1);
        }
        case uhdmstruct_typespec: {
            int64_t sum = 0;
            auto* ms = ((const struct_typespec*)ts)->Members();
            if (!ms) { bail = true; return 0; }
            for (auto* m : *ms) {
                auto* rt = m->Typespec();
                if (!rt || !rt->Actual_typespec()) { bail = true; return 0; }
                sum += nbits(rt->Actual_typespec(), sym, bail, depth + 1);
            }
            return sum;
        }
        case uhdmunion_typespec: {
            int64_t mx = 0;
            auto* ms = ((const union_typespec*)ts)->Members();
            if (!ms) { bail = true; return 0; }
            for (auto* m : *ms) {
                auto* rt = m->Typespec();
                if (!rt || !rt->Actual_typespec()) { bail = true; return 0; }
                int64_t v = nbits(rt->Actual_typespec(), sym, bail, depth + 1);
                if (v > mx) mx = v;
            }
            return mx;
        }
        case uhdmpacked_array_typespec: {
            auto* t = (const packed_array_typespec*)ts;
            auto* rt = t->Elem_typespec();
            if (!rt || !rt->Actual_typespec()) { bail = true; return 0; }
            int64_t b = nbits(rt->Actual_typespec(), sym, bail, depth + 1);
            return applyRanges(t->Ranges(), b, sym, bail);
        }
        case uhdmarray_typespec: {
            auto* t = (const array_typespec*)ts;
            auto* rt = t->Elem_typespec();
            if (!rt || !rt->Actual_typespec()) { bail = true; return 0; }
            int64_t b = nbits(rt->Actual_typespec(), sym, bail, depth + 1);
            return applyRanges(t->Ranges(), b, sym, bail);
        }
        default: bail = true; return 0;
    }
}

int main(int argc, char** argv) {
    // ONE LINE PER DATABASE.  A database is a CANDIDATE when it holds BOTH
    //  (a) a `typespec_member` whose emitted typespec the law can re-size —
    //      unvaluable-without-an-instance and not bailed — and
    //  (b) an assignment-pattern operation (opType 75) carrying a `constant`
    //      operand, i.e. a pattern the flatten could have re-typed.
    // It is a SUPERSET three ways over the law, which additionally requires the
    // operand to come from an UNSIZED literal, the pattern to target THAT
    // struct, and the carrier to be the cont_assign (or a `default:` fill).
    // It cannot MISS: the law never re-sizes an operand whose member typespec
    // the pristine binary did not already emit, and that emission is
    // byte-identical in both binaries (the law touches no typespec).
    std::string tag;
    std::vector<std::string> files;
    bool verbose = false;
    for (int i = 1; i < argc; i++) {
        std::string a(argv[i]);
        if (a.rfind("--tag=", 0) == 0) tag = a.substr(6);
        else if (a == "-v") verbose = true;
        else files.push_back(a);
    }
    Serializer s;
    auto h = s.Restore(std::filesystem::path(files[0]));
    (void)h;
    int nsym = 0, npat = 0;
    std::vector<std::string> syms;
    for (auto& [obj, id] : s.AllObjects()) {
        if (!obj) continue;
        if (obj->UhdmType() == uhdmtypespec_member) {
            auto* m = (const typespec_member*)obj;
            auto* rt = m->Typespec();
            const typespec* at = rt ? rt->Actual_typespec() : nullptr;
            bool sym = false, bail = false;
            int64_t b = nbits(at, sym, bail, 0);
            if (sym && !bail && b > 0) {
                nsym++;
                const BaseClass* p = m->VpiParent();
                std::ostringstream o;
                o << (p ? std::string(p->VpiName()) : std::string("?")) << "."
                  << m->VpiName() << "@" << m->VpiLineNo() << " nbits=" << b;
                syms.push_back(o.str());
            }
        } else if (obj->UhdmType() == uhdmoperation) {
            auto* op = (const operation*)obj;
            if (op->VpiOpType() != vpiAssignmentPatternOp) continue;
            if (!op->Operands()) continue;
            for (auto* o : *op->Operands())
                if (o && o->UhdmType() == uhdmconstant) { npat++; break; }
        }
    }
    bool cand = (nsym > 0 && npat > 0);
    std::cout << (cand ? "CANDIDATE " : "no        ") << tag << " symMembers=" << nsym
              << " patternsWithConstOperand=" << npat << "\n";
    if (verbose)
        for (auto& x : syms) std::cout << "   SYM " << tag << " " << x << "\n";
    return 0;
}
