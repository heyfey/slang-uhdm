// r10uvm149 — TYPESPEC_MEMBER CENSUS.  MEASUREMENT ONLY; the sole acceptance
// judge is ~/git-repos/UHDM/build/bin/uhdm-cmp.  LHS is ALWAYS golden
// (Surelog), RHS is ALWAYS ours, in every consumer of this output.
//
// One ROW per `typespec_member` object in a database, keyed on
//   <owner-aggregate-kind>|<owner-name>|<member-name>|<line>:<col>
// (the FILE is reported in a SEPARATE, un-joined column: our typespec_members
// carry an EMPTY VpiFile — a known, compare-invisible residue — so a file in
// the key would make every cell one-sided and manufacture phantoms.)
// (the DEF/ELAB VIEW is deliberately KEPT OUT of the key — the two producers
// label the view differently; identity is restored by the multiset join in
// cen149.py, which counts cells, never dedupes).
//
// The PAYLOAD is COMPARE-VISIBLE ONLY: every field a `typespec_member`,
// `array_typespec`, `packed_array_typespec`, `range` or `constant` Compare
// actually reads (UHDM generated typespec_member.cpp / array_typespec.cpp /
// range.cpp / constant.cpp), plus the element typespec's KIND and NAME.
// vpiFile / vpiLineNo / vpiParent / VpiFullName are NEVER in the payload.
//
// build: g++ -O2 -std=c++17 ct149cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct149cen
// usage: ct149cen <db.uhdm> <label>
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
#include <vector>
#include <algorithm>

using namespace UHDM;

static std::string base(std::string_view p) {
    size_t i = p.find_last_of('/');
    return std::string(i == std::string_view::npos ? p : p.substr(i + 1));
}
static const typespec* actual(const ref_typespec* rt) {
    return rt ? rt->Actual_typespec() : nullptr;
}
static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("<null>");
}
// A constant rendered by the fields constant::Compare reads:
// VpiDecompile / VpiSize / VpiConstType (VpiValue is NOT compared —
// generated expr.cpp) plus the typespec kind riding it (assoc index).
static std::string cst(const any* e) {
    if (!e) return "-";
    char b[400];
    if (e->UhdmType() == uhdmconstant) {
        const constant* c = (const constant*)e;
        std::string its = "-";
        if (c->Typespec() && c->Typespec()->Actual_typespec())
            its = kindOf(c->Typespec()->Actual_typespec());
        snprintf(b, sizeof b, "c{%s,sz%d,ct%d,idx=%s}",
                 std::string(c->VpiDecompile()).c_str(), (int)c->VpiSize(),
                 (int)c->VpiConstType(), its.c_str());
        return b;
    }
    if (e->UhdmType() == uhdmoperation) {
        const operation* op = (const operation*)e;
        std::string in;
        if (op->Operands())
            for (auto* o : *op->Operands()) in += "," + cst(o);
        snprintf(b, sizeof b, "op{%d%s}", (int)op->VpiOpType(), in.c_str());
        return b;
    }
    snprintf(b, sizeof b, "%s{%s}", kindOf(e).c_str(),
             std::string(e->VpiName()).c_str());
    return b;
}
static std::string ranges(const VectorOfrange* rs) {
    if (!rs) return "-";
    std::string out;
    for (auto* r : *rs) {
        char b[900];
        snprintf(b, sizeof b, "[sz%d %s:%s]", (int)r->VpiSize(),
                 cst(r->Left_expr()).c_str(), cst(r->Right_expr()).c_str());
        out += b;
    }
    return out.empty() ? "-" : out;
}
// The compare-visible shape of a member's typespec.  `depth` renders the
// ELEMENT typespec of an array one level down (its own kind, name, ranges and
// vpiInstance) -- typespec::Compare recurses into Elem_typespec, so an element
// that carries an Instance golden leaves null is a REAL cmp failure the top
// level cannot show.
static std::string shape(const typespec* ts, int depth = 1);
static std::string shape(const typespec* ts, int depth) {
    if (!ts) return "NONE";
    char b[2400];
    std::string k = kindOf(ts);
    std::string inst = ts->Instance() ? kindOf(ts->Instance()) : "-";
    std::string alias = ts->Typedef_alias()
                            ? kindOf(actual(ts->Typedef_alias()))
                            : "-";
    if (ts->UhdmType() == uhdmarray_typespec) {
        const array_typespec* a = (const array_typespec*)ts;
        std::string el = depth > 0 ? shape(actual(a->Elem_typespec()), depth - 1)
                                   : kindOf(actual(a->Elem_typespec()));
        std::string ix = kindOf(actual(a->Index_typespec()));
        snprintf(b, sizeof b,
                 "%s name=%s at=%d R=%s index=%s inst=%s alias=%s elem={%s}",
                 k.c_str(), std::string(a->VpiName()).c_str(),
                 (int)a->VpiArrayType(), ranges(a->Ranges()).c_str(),
                 ix.c_str(), inst.c_str(), alias.c_str(), el.c_str());
        return b;
    }
    if (ts->UhdmType() == uhdmpacked_array_typespec) {
        const packed_array_typespec* a = (const packed_array_typespec*)ts;
        std::string el = depth > 0 ? shape(actual(a->Elem_typespec()), depth - 1)
                                   : kindOf(actual(a->Elem_typespec()));
        snprintf(b, sizeof b, "%s name=%s R=%s inst=%s alias=%s elem={%s}",
                 k.c_str(), std::string(a->VpiName()).c_str(),
                 ranges(a->Ranges()).c_str(), inst.c_str(), alias.c_str(),
                 el.c_str());
        return b;
    }
    const VectorOfrange* rs = nullptr;
    if (ts->UhdmType() == uhdmlogic_typespec)
        rs = ((const logic_typespec*)ts)->Ranges();
    else if (ts->UhdmType() == uhdmbit_typespec)
        rs = ((const bit_typespec*)ts)->Ranges();
    snprintf(b, sizeof b, "%s name=%s R=%s inst=%s alias=%s", k.c_str(),
             std::string(ts->VpiName()).c_str(), ranges(rs).c_str(),
             inst.c_str(), alias.c_str());
    return b;
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct149cen <db.uhdm> <label>\n"); return 2; }
    const std::string label = argv[2];
    Serializer s;
    auto restored = s.Restore(std::string(argv[1]));
    if (restored.empty()) { printf("EMPTY\t%s\n", label.c_str()); return 3; }
    std::vector<std::string> rows;
    for (auto& kv : s.AllObjects()) {
        const any* a = (const any*)kv.first;
        if (!a || a->UhdmType() != uhdmtypespec_member) continue;
        const typespec_member* m = (const typespec_member*)a;
        const any* p = m->VpiParent();
        std::string ok = kindOf(p);
        std::string on = p ? std::string(p->VpiName()) : std::string();
        bool packed = false;
        if (p && p->UhdmType() == uhdmstruct_typespec)
            packed = ((const struct_typespec*)p)->VpiPacked();
        else if (p && p->UhdmType() == uhdmunion_typespec)
            packed = ((const union_typespec*)p)->VpiPacked();
        const typespec* ts = actual(m->Typespec());
        char b[4096];
        snprintf(b, sizeof b,
                 "M\t%s\t%s|%s|%s|%u:%u\tpacked=%d\t%s\tdflt=%s\tfile=%s",
                 label.c_str(), ok.c_str(), on.c_str(),
                 std::string(m->VpiName()).c_str(), m->VpiLineNo(),
                 (unsigned)m->VpiColumnNo(), packed ? 1 : 0,
                 shape(ts).c_str(),
                 m->Default_value() ? cst(m->Default_value()).c_str() : "-",
                 base(m->VpiFile()).c_str());
        rows.push_back(b);
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) printf("%s\n", r.c_str());
    printf("TOTAL\t%s\tmembers=%d\n", label.c_str(), (int)rows.size());
    return 0;
}
