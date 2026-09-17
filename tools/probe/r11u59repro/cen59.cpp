// r11u59 — THE ASSIGNMENT-PATTERN ELEMENT CENSUS, both halves of the r11u58
// read.  MEASUREMENT ONLY; `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole
// acceptance judge.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// It reads ONE database and prints one line per assignment-pattern element of
// every `param_assign` in every package and module listing, plus one SHAPE line
// per pattern.  Two questions ride on it:
//
//   THE MASK HALF (R2).  `OVERWIDE` marks an element whose UINT value does NOT
//   fit the vpiSize the element carries — the exact cell the landed
//   § patElabUintResize arm masked and § patElabNoMask59 stops masking.  Run
//   GOLDEN-vs-GOLDEN first: an OVERWIDE count of zero across the corpus means
//   no corpus cell can move, and the positive control is the grid, whose golden
//   databases carry OVERWIDE cells by construction.
//
//   THE FLATTEN HALF (R0).  The SHAPE column is TAGGED (the operands are
//   `tagged_pattern`s) or FLAT (positional).  Surelog's
//   `expandPatternAssignment` returns the FLATTENED clone when its walk
//   COMPLETES and the ORIGINAL tagged tree when it bails, so a golden pattern
//   reading FLAT where ours reads TAGGED is one completed-walk cell of R0.
//
// Neither key carries an id, a span or a fullname: no generated `Compare`
// reads them.  The VIEW is in the key because the two listings are two
// distinct objects, and the producers label them the same way here (`design::
// AllPackages` = DEF, `TopPackages` = ELAB).
//
// build:
//   g++ -O2 -std=c++17 cen59.cpp -I ~/.local/include \
//       -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/cen59
// usage:
//   cen59 <db.uhdm> <rowtag>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstdlib>
#include <map>
#include <string>
#include <vector>

using namespace UHDM;

static std::string sv(std::string_view s) { return std::string(s); }

// The member tag of a tagged_pattern: its typespec's actual's VpiName.
static std::string tagOf(const tagged_pattern* tp) {
    if (const ref_typespec* rt = tp->Typespec())
        if (const typespec* at = rt->Actual_typespec()) return sv(at->VpiName());
    return "<untagged-ts>";
}

// "UINT:300" -> (true, 300).  Anything else -> (false, 0).
static bool uintOf(const std::string& v, unsigned long long& out) {
    if (v.compare(0, 5, "UINT:") != 0) return false;
    try {
        out = std::stoull(v.substr(5));
    } catch (...) {
        return false;
    }
    return true;
}

static void emit(const char* tag, const char* view, const std::string& owner,
                 const std::string& pname, const std::string& mtag,
                 const any* el, int idx) {
    std::string kind = el ? std::string(UhdmName(el->UhdmType())) : "<null>";
    long long size = -777;
    std::string val = "-", dec = "-";
    int ct = -1;
    if (el) {
        if (const expr* e = any_cast<const expr*>(el)) size = e->VpiSize();
        if (el->UhdmType() == uhdmconstant) {
            const constant* c = (const constant*)el;
            val = sv(c->VpiValue());
            dec = sv(c->VpiDecompile());
            ct = c->VpiConstType();
        }
    }
    unsigned long long uv = 0;
    const char* over = "";
    if (size > 0 && size < 64 && uintOf(val, uv) &&
        uv >= (1ULL << (unsigned)size))
        over = " OVERWIDE";
    printf("CELL %s %s %s %s %s idx=%d kind=%s size=%lld ct=%d val=%s dec=%s%s\n",
           tag, view, owner.c_str(), pname.c_str(), mtag.c_str(), idx, kind.c_str(),
           size, ct, val.c_str(), dec.c_str(), over);
}

static void doScope(const char* tag, const char* view, const std::string& owner,
                    const VectorOfparam_assign* pas) {
    if (!pas) return;
    for (const param_assign* pa : *pas) {
        const any* rhs = pa->Rhs();
        if (!rhs || rhs->UhdmType() != uhdmoperation) continue;
        const operation* op = (const operation*)rhs;
        if (op->VpiOpType() != vpiAssignmentPatternOp) continue;
        const VectorOfany* ops = op->Operands();
        if (!ops) continue;
        std::string pname = pa->Lhs() ? sv(pa->Lhs()->VpiName()) : "<noname>";
        int tagged = 0, n = 0, over = 0;
        std::vector<std::pair<std::string, const any*>> els;
        for (const any* o : *ops) {
            n++;
            if (o->UhdmType() == uhdmtagged_pattern) {
                tagged++;
                const tagged_pattern* tp = (const tagged_pattern*)o;
                els.emplace_back(tagOf(tp), tp->Pattern());
            } else {
                els.emplace_back("#" + std::to_string(n - 1), o);
            }
        }
        int idx = 0;
        for (auto& [mt, el] : els) {
            // count OVERWIDE for the SHAPE line too
            if (el && el->UhdmType() == uhdmconstant) {
                const constant* c = (const constant*)el;
                unsigned long long uv = 0;
                long long size = c->VpiSize();
                if (size > 0 && size < 64 && uintOf(sv(c->VpiValue()), uv) &&
                    uv >= (1ULL << (unsigned)size))
                    over++;
            }
            emit(tag, view, owner, pname, mt, el, idx++);
        }
        printf("SHAPE %s %s %s %s %s n=%d overwide=%d\n", tag, view,
               owner.c_str(), pname.c_str(), tagged ? "TAGGED" : "FLAT", n,
               over);
    }
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: cen59 <db.uhdm> <rowtag>\n");
        return 2;
    }
    const char* db = argv[1];
    const char* tag = argv[2];
    Serializer s;
    if (s.Restore(std::string(db)).empty()) {
        printf("RESTORE_FAIL %s %s\n", tag, db);
        return 3;
    }
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdmdesign) continue;
        const design* d = (const design*)o;
        if (d->AllPackages())
            for (const package* p : *d->AllPackages())
                doScope(tag, "defpkg", sv(p->VpiName()), p->Param_assigns());
        if (d->TopPackages())
            for (const package* p : *d->TopPackages())
                doScope(tag, "elabpkg", sv(p->VpiName()), p->Param_assigns());
        if (d->AllModules())
            for (const module_inst* m : *d->AllModules())
                doScope(tag, "defmod", sv(m->VpiDefName()), m->Param_assigns());
        if (d->TopModules())
            for (const module_inst* m : *d->TopModules())
                doScope(tag, "elabmod", sv(m->VpiName()), m->Param_assigns());
    }
    return 0;
}
