// r10earl111 -- THE SELECT-BOUND CONSTANT TYPESPEC-EDGE CENSUS.
//
// MEASUREMENT ONLY.  The official uhdm-cmp is the sole acceptance judge.
// LHS is ALWAYS golden; RHS is ALWAYS ours.
//
// The head this pass owns is a `ref_typespec` hanging off a FOLDED select
// bound.  `expr::Compare` reads `Typespec()` before anything else a constant
// carries, so the census VALUE must be the whole COMPARE-VISIBLE payload of
// that edge and nothing else:
//
//   ref_typespec::Compare -> VpiName, VpiDefName, Actual_typespec
//   typespec::Compare     -> VpiName, Typedef_alias, Instance
//   int/logic/bit         -> + VpiSigned, Ranges (and int adds Cast_to_expr)
//
// earl60's attrv60.py lesson, applied: NO span and NO fullname in the VALUE --
// a span-carrying payload once hid an `Instance` flip inside STILL-WRONG.  The
// span is in the KEY only, where it exists purely to JOIN the two sides (the
// judge never reads one).  Our objects can carry an EMPTY VpiFile (RESUME.md
// section 9), so the file BASENAME is normalised and an empty one is spelled
// `-` rather than dropped, and the join is a MULTISET join (cen111.py), never
// a last-writer dict.
//
// SCOPE: every constant sitting in a SELECT-BOUND slot -- an
// indexed_part_select's Base_expr/Width_expr, a part_select's
// Left_range/Right_range, a bit_select's VpiIndex, a range's
// Left_expr/Right_expr -- which is the whole surface the folded-bound
// typespec family can reach, INCLUDING the four predecessor laws' own sites
// (part_select bounds, § psBoundPkgParamTs31) so an AWAY there cannot hide.
//
// build:
//   g++ -O2 -std=c++17 cen111.cpp -I ~/.local/include \
//       -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o cen111
// usage:
//   cen111 <db.uhdm> [tag]     -- TSV: key \t payload \t count
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : "-";
}

static std::string base(std::string f) {
    auto p = f.rfind('/');
    if (p != std::string::npos) f = f.substr(p + 1);
    return f.empty() ? std::string("-") : f;
}

// The join coordinate.  Measured, not assumed: OUR select-bound constants
// carry an EMPTY VpiFile in this design (all 20874 of them) while golden's
// carry the per-file basename, so a file in the key joins NOTHING (4 keys of
// 22829 on the first cut).  earl110's hier_path census made the same call for
// the same reason.  The file is therefore NOT in the key; it is printed as a
// separate trailing DIAGNOSTIC column that the scorer ignores.
static std::string spanOf(const BaseClass* o) {
    char b[128];
    snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(),
             (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo());
    return b;
}

// COMPARE-VISIBLE ONLY.  Nothing here is a span, a file or a fullname.
static std::string tsPayload(const typespec* t, int depth = 0) {
    if (!t) return "-";
    if (depth > 3) return "...";
    std::string s = kindOf(t);
    s += ",n='" + std::string(t->VpiName()) + "'";
    s += ",dn='" + std::string(t->VpiDefName()) + "'";
    s += ",alias=" + kindOf(t->Typedef_alias());
    s += ",inst=";
    s += t->Instance() ? std::string(t->Instance()->VpiName()) : std::string("-");
    if (auto* i = any_cast<const int_typespec*>(t)) {
        s += ",sg=" + std::to_string((int)i->VpiSigned());
        s += ",cast=" + kindOf(i->Cast_to_expr());
        s += ",rng=" + std::to_string(i->Ranges() ? i->Ranges()->size() : 0);
    }
    else if (auto* l = any_cast<const logic_typespec*>(t)) {
        s += ",sg=" + std::to_string((int)l->VpiSigned());
        s += ",rng=" + std::to_string(l->Ranges() ? l->Ranges()->size() : 0);
    }
    else if (auto* b = any_cast<const bit_typespec*>(t)) {
        s += ",sg=" + std::to_string((int)b->VpiSigned());
        s += ",rng=" + std::to_string(b->Ranges() ? b->Ranges()->size() : 0);
    }
    return s;
}

static std::string edgeOf(const constant* c) {
    const ref_typespec* rt = c->Typespec();
    if (!rt) return "BARE";
    std::string s = "TS[n='" + std::string(rt->VpiName()) + "'";
    s += ",dn='" + std::string(rt->VpiDefName()) + "'";
    s += "]->" + tsPayload(rt->Actual_typespec());
    return s;
}

static std::map<std::string, std::map<std::string, int>> rows;
static std::map<std::string, std::set<std::string>> files;

static void emit(const char* slot, const BaseClass* owner, const any* x) {
    if (!x || x->UhdmType() != uhdmconstant) return;
    auto* c = (const constant*)x;
    std::string key = std::string(slot) + "|" + spanOf(c) + "|" +
                      std::string(c->VpiDecompile()) + "|" +
                      std::to_string(c->VpiSize()) + "|ct" +
                      std::to_string(c->VpiConstType()) + "|own=" +
                      kindOf(owner);
    rows[key][edgeOf(c)]++;
    files[key].insert(base(std::string(c->VpiFile())));
}

int main(int argc, char** argv) {
    if (argc < 2) {
        fprintf(stderr, "usage: cen111 <db.uhdm> [tag]\n");
        printf("CENRC 2\n");
        return 2;
    }
    const char* tag = argc > 2 ? argv[2] : "";
    Serializer s;
    std::vector<vpiHandle> h = s.Restore(std::string(argv[1]));
    if (h.empty()) {
        fprintf(stderr, "FATAL: load failed\n");
        printf("CENRC 3\n");
        return 3;
    }
    std::set<const BaseClass*> seen;
    for (const auto& p : s.AllObjects()) {
        const BaseClass* o = p.first;
        if (!o || !seen.insert(o).second) continue;
        switch (o->UhdmType()) {
            case uhdmindexed_part_select: {
                auto* v = (const indexed_part_select*)o;
                emit("IPS.base", o, v->Base_expr());
                emit("IPS.width", o, v->Width_expr());
                break;
            }
            case uhdmpart_select: {
                auto* v = (const part_select*)o;
                emit("PS.left", o, v->Left_range());
                emit("PS.right", o, v->Right_range());
                break;
            }
            case uhdmbit_select: {
                auto* v = (const bit_select*)o;
                emit("BS.index", o, v->VpiIndex());
                break;
            }
            case uhdmrange: {
                auto* v = (const range*)o;
                emit("RNG.left", o, v->Left_expr());
                emit("RNG.right", o, v->Right_expr());
                break;
            }
            default:
                break;
        }
    }
    for (auto& kv : rows) {
        std::string fl;
        for (auto& f : files[kv.first]) fl += (fl.empty() ? "" : ",") + f;
        for (auto& pv : kv.second)
            printf("%s%s%s\t%s\t%d\t%s\n", tag, *tag ? "|" : "",
                   kv.first.c_str(), pv.first.c_str(), pv.second, fl.c_str());
    }
    printf("CENRC 0\n");
    return 0;
}
