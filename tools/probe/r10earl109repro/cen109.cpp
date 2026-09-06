// r10earl109 -- THE RANGE-BOUND CENSUS.
//
// MEASUREMENT ONLY.  The official ~/git-repos/UHDM/build/bin/uhdm-cmp is the
// sole acceptance judge.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// One ROW per RANGE BOUND of every typespec that a `ref_typespec` names, keyed
// by the CARRIER that holds the ref (its kind, its fullname, its span), the
// typespec kind, the dimension index and the side (L/R).  The payload is
// COMPARE-VISIBLE ONLY -- the fields the generated Compares actually read:
//   BaseClass::Compare  VpiType, VpiName, VpiDefName
//   expr::Compare       VpiDecompile, VpiSize, Typespec
//   constant::Compare   VpiConstType
//   ref_obj::Compare    Actual_group (its KIND; the pointer is not portable)
// and NEVER VpiFullName / VpiFile / line / col of the BOUND itself (RESUME
// section 9: no generated Compare reads them).  The carrier's fullname and span
// are in the KEY, not the payload, so a naming or parenting residue can never
// masquerade as a bound flip -- earl60's attrv60.py lesson.
//
// A typespec is SHARED between carriers, so the same bound object legitimately
// produces several rows; that is deliberate, because the JUDGE reaches it once
// per carrier.  Keys are emitted as a MULTISET (duplicates kept) and joined as
// one -- a last-writer dict silently drops rows (RESUME section 9).
//
// build:
//   g++ -O2 -std=c++17 cen109.cpp -I ~/.local/include \
//       -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o cen109
// usage:
//   cen109 <db.uhdm> <tag>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <map>
#include <string>
#include <variant>
#include <vector>

using namespace UHDM;

static std::string spanOf(const BaseClass* o) {
    if (!o) return "-";
    char b[96];
    snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
             o->VpiEndLineNo(), (unsigned)o->VpiEndColumnNo());
    return b;
}
static std::string fileOf(const BaseClass* o) {
    if (!o) return "-";
    std::string f(o->VpiFile());
    auto p = f.rfind('/');
    return p == std::string::npos ? f : f.substr(p + 1);
}
static std::string nameOf(const BaseClass* o) {
    if (!o) return "-";
    auto pv = o->GetVpiPropertyValue(vpiFullName);
    if (std::holds_alternative<const char*>(pv)) {
        const char* p = std::get<const char*>(pv);
        if (p && *p) return p;
    }
    std::string n(o->VpiName());
    return n.empty() ? "-" : n;
}
static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : "-";
}

// COMPARE-VISIBLE payload of a bound expression.
static std::string payload(const any* o) {
    if (!o) return "<null>";
    std::string r = kindOf(o);
    r += "|n=" + std::string(o->VpiName().empty() ? "-" : o->VpiName());
    if (auto* e = any_cast<const expr*>(o)) {
        r += "|dc=" + std::string(e->VpiDecompile());
        r += "|sz=" + std::to_string(e->VpiSize());
        r += "|v=" + std::string(e->VpiValue());
        const ref_typespec* rt = e->Typespec();
        const typespec* at = rt ? rt->Actual_typespec() : nullptr;
        if (!at)
            r += "|ts=NONE";
        else {
            r += "|ts=" + kindOf(at);
            if (auto* it = any_cast<const int_typespec*>((const any*)at))
                r += it->VpiSigned() ? "/S" : "/u";
        }
    }
    if (auto* c = any_cast<const constant*>(o))
        r += "|ct=" + std::to_string(c->VpiConstType());
    if (auto* ro = any_cast<const ref_obj*>(o))
        r += "|act=" + kindOf((const BaseClass*)ro->Actual_group());
    if (auto* op = any_cast<const operation*>(o)) {
        r += "|op=" + std::to_string(op->VpiOpType());
        r += "|nops=" +
             std::to_string(op->Operands() ? op->Operands()->size() : 0);
    }
    return r;
}

static const VectorOfrange* rangesOf(const BaseClass* o) {
    if (auto* t = any_cast<const logic_typespec*>((const any*)o)) return t->Ranges();
    if (auto* t = any_cast<const bit_typespec*>((const any*)o)) return t->Ranges();
    if (auto* t = any_cast<const array_typespec*>((const any*)o)) return t->Ranges();
    if (auto* t = any_cast<const packed_array_typespec*>((const any*)o)) return t->Ranges();
    if (auto* t = any_cast<const int_typespec*>((const any*)o)) return t->Ranges();
    return nullptr;
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: cen109 <db.uhdm> <tag>\n");
        return 2;
    }
    const char* tag = argv[2];
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) {
        fprintf(stderr, "RESTORE_FAILED %s\n", argv[1]);
        printf("CENRC 3\n");
        return 3;
    }
    std::vector<const BaseClass*> all;
    for (const auto& [o, id] : s.AllObjects())
        if (o) all.push_back(o);
    std::sort(all.begin(), all.end(), [](const BaseClass* a, const BaseClass* b) {
        return a->UhdmId() != b->UhdmId() ? a->UhdmId() < b->UhdmId() : a < b;
    });
    size_t nrefs = 0, nrows = 0;
    std::vector<std::string> rows;
    for (const BaseClass* o : all) {
        auto* rt = any_cast<const ref_typespec*>((const any*)o);
        if (!rt) continue;
        nrefs++;
        const typespec* at = rt->Actual_typespec();
        if (!at) continue;
        const VectorOfrange* rs = rangesOf((const BaseClass*)at);
        if (!rs || rs->empty()) continue;
        const BaseClass* carrier = rt->VpiParent();
        // The CARRIER identity: kind + fullname + file:span.  A shared typespec
        // is reached once per carrier and each reach is its own row, because
        // that is how the judge reaches it.
        // NO FILE in the key.  Our typespecs and some of our nets carry an
        // EMPTY VpiFile where golden carries the path (RESUME section 9), so a
        // file-bearing key joins NOTHING -- the calibration run caught it as
        // ONLY-GOLDEN 270 / ONLY-OURS 272 with BOTH-SAME 0.  The carrier's
        // FULLNAME is already instance-unique, and the span disambiguates the
        // rest.
        // The REF's own fullname is what separates the DEF-view carrier from
        // the ELAB one: a def port and its elaborated twin share VpiName and
        // span, and the port object itself often has no fullname, so a
        // carrier-name key MERGED the two views into one cell and hid the flip
        // behind a multiplicity difference.  The ref_typespec carries
        // `work@<def>.<name>` in the def view and
        // `work@<top>.<inst>...<name>` in the elab one.
        std::string ckey = kindOf(carrier) + "@" +
                           (nameOf(rt) != "-" ? nameOf(rt) : nameOf(carrier)) +
                           "@" + spanOf(carrier);
        for (size_t i = 0; i < rs->size(); i++) {
            const range* rg = (*rs)[i];
            if (!rg) continue;
            for (int side = 0; side < 2; side++) {
                const any* b = side ? (const any*)rg->Right_expr()
                                    : (const any*)rg->Left_expr();
                if (!b) continue;
                // The bound's OWN span goes in the key (it names WHICH written
                // bound this is) but never in the payload.
                rows.push_back(ckey + "\t" + kindOf((const BaseClass*)at) + "\t" +
                               std::to_string(i) + (side ? "R" : "L") + "\t" +
                               spanOf((const BaseClass*)b) + "\t" + payload(b));
                nrows++;
            }
        }
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) printf("ROW\t%s\t%s\n", tag, r.c_str());
    printf("SUMMARY %s objects=%zu ref_typespecs=%zu rows=%zu\n", tag,
           all.size(), nrefs, nrows);
    printf("CENRC 0\n");
    return 0;
}
