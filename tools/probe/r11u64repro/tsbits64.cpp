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
// getValue of a bound with NO instance: a constant answers itself; anything
// else cannot be reduced without one and reads 0 (ExprEval::getValue of a
// non-constant).  `sym` records that the bound was not a constant.
static int64_t boundVal(const any* e, bool& sym) {
    if (!e) { sym = true; return 0; }
    if (e->UhdmType() == uhdmconstant) {
        std::string v(((const constant*)e)->VpiValue());
        auto c = v.find(':');
        if (c == std::string::npos) { sym = true; return 0; }
        return (int64_t)strtoll(v.c_str() + c + 1, nullptr, 10);
    }
    sym = true;
    return 0;
}
static int64_t nbits(const typespec* ts, bool& sym, bool& bail, int depth);
static int64_t applyRanges(const VectorOfrange* r, int64_t bits, bool& sym) {
    if (!r) return bits;
    for (auto* ran : *r) {
        int64_t lv = boundVal(ran->Left_expr(), sym);
        int64_t rv = boundVal(ran->Right_expr(), sym);
        bits = bits * ((lv > rv) ? (lv - rv + 1) : (rv - lv + 1));
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
            return applyRanges(t->Ranges(), b, sym);
        }
        case uhdmbit_typespec:
            return applyRanges(((const bit_typespec*)ts)->Ranges(), 1, sym);
        case uhdmint_typespec: {
            auto* t = (const int_typespec*)ts;
            auto* r = t->Ranges();
            int64_t b = (r && !r->empty()) ? 1 : 32;
            return applyRanges(r, b, sym);
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
            return applyRanges(t->Ranges(), b, sym);
        }
        case uhdmarray_typespec: {
            auto* t = (const array_typespec*)ts;
            auto* rt = t->Elem_typespec();
            if (!rt || !rt->Actual_typespec()) { bail = true; return 0; }
            int64_t b = nbits(rt->Actual_typespec(), sym, bail, depth + 1);
            return applyRanges(t->Ranges(), b, sym);
        }
        default: bail = true; return 0;
    }
}

int main(int argc, char** argv) {
    bool symOnly = false;
    std::vector<std::string> files;
    std::string tag;
    for (int i = 1; i < argc; i++) {
        std::string a(argv[i]);
        if (a == "--sym") symOnly = true;
        else if (a.rfind("--tag=", 0) == 0) tag = a.substr(6);
        else files.push_back(a);
    }
    Serializer s;
    auto h = s.Restore(std::filesystem::path(files[0]));
    (void)h;
    int nsym = 0;
    std::map<std::string, std::string> rows;
    for (auto& [obj, id] : s.AllObjects()) {
        if (!obj || obj->UhdmType() != uhdmtypespec_member) continue;
        auto* m = (const typespec_member*)obj;
        auto* rt = m->Typespec();
        const typespec* at = rt ? rt->Actual_typespec() : nullptr;
        bool sym = false, bail = false;
        int64_t b = nbits(at, sym, bail, 0);
        if (symOnly && !sym) continue;
        if (sym) nsym++;
        std::ostringstream k, v;
        const BaseClass* p = m->VpiParent();
        k << (p ? std::string(p->VpiName()) : std::string("<no-owner>")) << "."
          << m->VpiName() << " @" << m->VpiLineNo() << ":" << m->VpiColumnNo();
        v << kindName(at) << " nbits=" << b << (sym ? " SYM" : "")
          << (bail ? " BAIL" : "");
        std::string key = k.str();
        int n = 0;
        std::string uk = key;
        while (rows.count(uk)) uk = key + " #" + std::to_string(++n);
        rows[uk] = v.str();
    }
    for (auto& [k, v] : rows)
        std::cout << (tag.empty() ? "" : tag + " ") << "MEMBER " << k << "  ->  " << v
                  << "\n";
    std::cout << (tag.empty() ? "" : tag + " ") << "SYMMEMBERS " << nsym << "\n";
    return 0;
}
