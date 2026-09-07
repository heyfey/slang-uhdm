// r10earl112 -- THE GENVAR-BEARING hier_path CENSUS.
//
// MEASUREMENT ONLY.  The official uhdm-cmp is the sole acceptance judge.
// LHS is ALWAYS golden; RHS is ALWAYS ours.
//
// The head this pass owns is a `hier_path` whose `VpiName` spells a GENVAR
// where golden spells the genvar's per-instance VALUE.  `BaseClass::Compare`
// reads `VpiName` BEFORE any `expr` field, so the census PAYLOAD is the whole
// compare-visible surface of the object in the order the judge reads it:
//
//   BaseClass::Compare  -> VpiType, VpiName, VpiDefName
//   expr::Compare       -> VpiDecompile, VpiSize, Typespec
//   hier_path::Compare  -> Path_elems, Root_value, VpiName
//
// and, for every Path_elems entry, the fields ITS Compare reads
// (`bit_select` -> ref_obj(VpiName, Actual_group) + VpiIndex).
//
// earl60's attrv60.py lesson, applied: NO span and NO fullname in the PAYLOAD
// -- a span-carrying payload once hid an object flip inside STILL-WRONG.  The
// span is in the KEY only, where it exists purely to JOIN the two sides.  OUR
// hier_paths have an EMPTY VpiFile (RESUME.md section 9), so the file basename
// is a trailing DIAGNOSTIC column the scorer ignores, never a key part.
//
// The KEY also carries the RENDER CONTEXT and the GENERATE DEPTH, which is the
// matrix this pass measures:
//
//   ctx=  the ancestor chain, three levels, operations spelled with their
//         VpiOpType (75 = vpiAssignmentPatternOp, 74 = vpiConcatOp, ...) and
//         `tagged_pattern` kept, because that is the carrier golden's
//         `compileAssignmentPattern` flips `Reduce` on;
//   gd=   the number of `gen_scope_array` ancestors (earl110's depth axis);
//   idx=  the index FORM of the first component select -- ref_obj (a bare
//         identifier: a genvar or a variable), constant, operation
//         (arithmetic on one), or another select.
//
// build:
//   g++ -O2 -std=c++17 cen112.cpp -I ~/.local/include \
//       -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o cen112
// usage:
//   cen112 <db.uhdm> [tag]     -- TSV: key \t payload \t count \t files
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

static std::string spanOf(const BaseClass* o) {
    char b[128];
    snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(),
             (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo());
    return b;
}

// One ancestor, spelled with the discriminator its kind carries.
static std::string ancOf(const BaseClass* o) {
    if (!o) return "-";
    std::string s = kindOf(o);
    if (auto* op = any_cast<const operation*>(o))
        s += std::to_string(op->VpiOpType());
    return s;
}

// The index FORM -- the axis the law is gated on.
static std::string idxForm(const any* x) {
    if (!x) return "none";
    switch (x->UhdmType()) {
        case uhdmref_obj: return "ref";
        case uhdmconstant: return "const";
        case uhdmoperation: return "op";
        case uhdmbit_select: return "bitsel";
        case uhdmpart_select: return "partsel";
        case uhdmindexed_part_select: return "ips";
        case uhdmhier_path: return "hier";
        default: return kindOf(x);
    }
}

// COMPARE-VISIBLE ONLY -- the element WITHOUT its index (the HPR family).
static std::string elemPayload(const any* e) {
    std::string s = kindOf(e);
    if (!e) return s;
    s += ",n='" + std::string(e->VpiName()) + "'";
    if (auto* bs = any_cast<const bit_select*>(e))
        s += ",act=" + kindOf(bs->Actual_group());
    else if (auto* ro = any_cast<const ref_obj*>(e))
        s += ",act=" + kindOf(ro->Actual_group());
    return s;
}

// COMPARE-VISIBLE ONLY -- the component select's INDEX object (the HPN
// family), with the fields `bit_select::Compare` -> `SafeCompare(VpiIndex)`
// reaches: the kind, and for a constant its VpiDecompile / VpiValue / VpiSize
// / VpiConstType, for a ref_obj its VpiName.
static std::string idxPayload(const any* e) {
    auto* bs = any_cast<const bit_select*>(e);
    if (!bs) return {};
    const any* ix = bs->VpiIndex();
    std::string s = idxForm(ix);
    if (!ix) return s;
    s += "(n='" + std::string(ix->VpiName()) + "'";
    if (auto* ex = any_cast<const expr*>(ix)) {
        s += ",dec='" + std::string(ex->VpiDecompile()) + "'";
        s += ",val='" + std::string(ex->VpiValue()) + "'";
        s += ",sz=" + std::to_string(ex->VpiSize());
    }
    if (auto* c = any_cast<const constant*>(ix))
        s += ",ct=" + std::to_string(c->VpiConstType());
    s += ")";
    return s;
}

static std::map<std::string, std::map<std::string, int>> rows;
static std::map<std::string, std::set<std::string>> files;

int main(int argc, char** argv) {
    if (argc < 2) {
        fprintf(stderr, "usage: cen112 <db.uhdm> [tag]\n");
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
        if (o->UhdmType() != uhdmhier_path) continue;
        auto* hp = (const hier_path*)o;
        // SCOPE: every hier_path that carries at least one COMPONENT SELECT --
        // the only ones whose NAME can spell an index at all.  A dotted path
        // with no select cannot host the head and is not in the population.
        bool hasSel = false;
        std::string elems, idxPay;
        if (hp->Path_elems())
            for (auto* e : *hp->Path_elems()) {
                if (e && e->UhdmType() != uhdmref_obj) hasSel = true;
                elems += (elems.empty() ? "" : ";") + elemPayload(e);
                std::string ip = idxPayload(e);
                if (!ip.empty()) idxPay += (idxPay.empty() ? "" : ";") + ip;
            }
        if (!hasSel) continue;

        // The RENDER CONTEXT: three ancestor levels, and the generate depth.
        std::string ctx;
        int gd = 0;
        const BaseClass* a = hp->VpiParent();
        for (int d = 0; d < 3; d++) {
            ctx += (d ? "<" : "") + ancOf(a);
            a = a ? a->VpiParent() : nullptr;
        }
        for (const BaseClass* g = hp->VpiParent(); g; g = g->VpiParent())
            if (g->UhdmType() == uhdmgen_scope_array) gd++;
        // The index form of the FIRST component select.
        std::string ixf = "none";
        if (hp->Path_elems())
            for (auto* e : *hp->Path_elems())
                if (auto* bs = any_cast<const bit_select*>(e)) {
                    ixf = idxForm(bs->VpiIndex());
                    break;
                }

        // THE KEY IS THE JOIN COORDINATE AND NOTHING ELSE.  RESUME.md section
        // 9: keep the DEF/ELAB view OUT of the key (the two producers label it
        // differently -- golden's def-view generate body is a `named_begin`
        // where ours is a `gen_for`), and keep out anything the LAW CHANGES:
        // `ctx`, `gd` and `idx` all move when an index folds, so a key that
        // carried them would make every fixed cell ONE-SIDED on both sides
        // instead of scoring it.  They ride in the trailing DIAGNOSTIC column,
        // which the scorer ignores.
        // TWO ROW FAMILIES, so that the law's own surface is scored and the
        // REST of the object is PROVED UNMOVED rather than mixed in with it.
        // (earl111's census made the same split the other way round: the
        // typespec EDGE was the payload and the constant's other fields were
        // in the key.  Here the object carries FOUR compare-visible
        // differences at the head cell -- VpiName, VpiSize, Typespec and the
        // element Actual_groups -- of which this pass owns exactly ONE, so a
        // single full-payload row would score every fixed cell MOVEDWRONG and
        // tell the reader nothing.  Both families are printed; neither hides
        // the other.)
        //
        //   HPN  the LAW's surface: VpiName + every component select's INDEX
        //        object, with the fields `bit_select::Compare` reads.
        //   HPR  THE REST, compare-visible: Path_elems size, VpiDefName,
        //        VpiDecompile, VpiSize, Typespec edge, Root_value and every
        //        element's kind/name/Actual_group.  The law must leave this
        //        family with MOVEDWRONG 0 and AWAY 0.
        std::string key = "HPN|" + spanOf(hp);
        std::string pay = "n='" + std::string(hp->VpiName()) + "'";
        pay += ",IX[" + idxPay + "]";
        rows[key][pay]++;
        files[key].insert(base(std::string(hp->VpiFile())) + ";ctx=" + ctx +
                          ";gd=" + std::to_string(gd) + ";idx=" + ixf);
        std::string rkey = "HPR|" + spanOf(hp);
        std::string rpay = "ne=" +
                           std::to_string(hp->Path_elems()
                                              ? hp->Path_elems()->size()
                                              : 0);
        rpay += ",dn='" + std::string(hp->VpiDefName()) + "'";
        rpay += ",dec='" + std::string(hp->VpiDecompile()) + "'";
        rpay += ",sz=" + std::to_string(hp->VpiSize());
        rpay += ",ts=";
        if (auto* rt = hp->Typespec())
            rpay += kindOf(rt) + "->" + kindOf(rt->Actual_typespec());
        else
            rpay += "-";
        rpay += ",rv=" + kindOf(hp->Root_value());
        rpay += ",E[" + elems + "]";
        rows[rkey][rpay]++;
        files[rkey].insert(base(std::string(hp->VpiFile())) + ";ctx=" + ctx +
                           ";gd=" + std::to_string(gd) + ";idx=" + ixf);
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
