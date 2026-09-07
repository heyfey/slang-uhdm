// r10v190 (VERIFIER) — DEEP typedef-clone range census.
// MEASUREMENT ONLY; the official uhdm-cmp is the judge.  LHS is ALWAYS golden.
//
// The implementer's ct190cen payload (`boundDesc`) prints, per bound node:
//   constant -> decompile,size,value,consttype
//   ref_obj  -> name, BOUND/BARE
//   operation-> optype, decompile, size, operands
// It is therefore BLIND to several fields the generated `Compare` DOES read:
//   expr::Compare        -> Typespec()  (a ref_typespec whose Compare reads
//                                        VpiName, VpiDefName, Actual_typespec)
//   simple_expr::Compare -> VpiUses()
//   ref_obj::Compare     -> VpiDefName, VpiGeneric, VpiStructMember
//   operation::Compare   -> VpiReordered, VpiFlattened, VpiOpStrong, Attributes
// This census prints EVERY one of them, so a field the pass's copier drops
// shows up as a changed cell instead of hiding under the slot.
//
// Sections:
//   TDCE — enum-base clones (the population this pass writes)
//   TDCX — every typespec carrying a Typedef_alias (all clone positions)
//   RNGA — EVERY bit/logic/array/packed_array typespec in the database with a
//          range, clone or not, so an over-wide law shows outside the clones.
// usage: ctv190cen <file.uhdm> <viewtag>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string g_tag = "-";

static std::string kd(const any* t) {
    return t ? std::string(UhdmName(t->UhdmType())) : "NULL";
}
static std::string esc(std::string_view v) {
    std::string o;
    for (char c : v) {
        if (c == '\t') o += "\\t";
        else if (c == '\n') o += "\\n";
        else o += c;
    }
    return o.empty() ? "-" : o;
}
static std::string span(const any* o) {
    if (!o) return "-";
    return std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo()) + "-" +
           std::to_string(o->VpiEndLineNo()) + ":" +
           std::to_string(o->VpiEndColumnNo());
}

// Everything ref_typespec::Compare reads, plus the actual typespec's identity.
static std::string tsRef(const ref_typespec* rt) {
    if (!rt) return "TS=NONE";
    const typespec* a = rt->Actual_typespec();
    return "TS{n=" + esc(rt->VpiName()) + ",dn=" + esc(rt->VpiDefName()) +
           ",act=" + kd(a) + ":" + (a ? esc(a->VpiName()) : std::string("-")) +
           "}";
}

// simple_expr::Compare reads VpiUses (a vector).
static std::string usesOf(const simple_expr* e) {
    if (!e) return "u=-";
    auto* v = e->VpiUses();
    if (!v) return "u=0";
    std::string s = "u=" + std::to_string(v->size()) + "[";
    for (size_t i = 0; i < v->size(); ++i)
        s += (i ? "|" : "") + kd(v->at(i));
    return s + "]";
}

static std::string node(const any* n) {
    if (!n) return "-";
    switch (n->UhdmType()) {
        case uhdmconstant: {
            auto* c = (const constant*)n;
            return "const(dec=" + esc(c->VpiDecompile()) +
                   ",sz=" + std::to_string(c->VpiSize()) +
                   ",val=" + esc(c->VpiValue()) +
                   ",ct=" + std::to_string(c->VpiConstType()) + "," +
                   tsRef(c->Typespec()) + ")";
        }
        case uhdmref_obj: {
            auto* r = (const ref_obj*)n;
            const any* a = r->Actual_group();
            return "ref(n=" + esc(r->VpiName()) + ",dn=" + esc(r->VpiDefName()) +
                   ",gen=" + std::to_string((int)r->VpiGeneric()) +
                   ",sm=" + std::to_string((int)r->VpiStructMember()) +
                   ",dec=" + esc(r->VpiDecompile()) +
                   ",sz=" + std::to_string(r->VpiSize()) + "," +
                   (a ? "BOUND:" + kd(a) + ":" + esc(a->VpiName())
                      : std::string("BARE")) +
                   "," + tsRef(r->Typespec()) + "," + usesOf(r) + ")";
        }
        case uhdmoperation: {
            auto* o = (const operation*)n;
            std::string s = "op(t=" + std::to_string(o->VpiOpType()) +
                            ",ro=" + std::to_string((int)o->VpiReordered()) +
                            ",fl=" + std::to_string((int)o->VpiFlattened()) +
                            ",st=" + std::to_string((int)o->VpiOpStrong()) +
                            ",dec=" + esc(o->VpiDecompile()) +
                            ",sz=" + std::to_string(o->VpiSize()) +
                            ",attr=" +
                            std::to_string(o->Attributes() ? o->Attributes()->size() : 0) +
                            "," + tsRef(o->Typespec()) + ",[";
            if (auto* ops = o->Operands())
                for (size_t i = 0; i < ops->size(); ++i)
                    s += (i ? "|" : "") + node(ops->at(i));
            return s + "])";
        }
        default: {
            std::string s = "other:" + kd(n);
            if (const expr* e = any_cast<const expr*>(n))
                s += "(dec=" + esc(e->VpiDecompile()) + ",sz=" +
                     std::to_string(e->VpiSize()) + "," + tsRef(e->Typespec()) + ")";
            return s;
        }
    }
}

static const VectorOfrange* rangesOf(const typespec* t) {
    switch (t->UhdmType()) {
        case uhdmbit_typespec: return ((const bit_typespec*)t)->Ranges();
        case uhdmlogic_typespec: return ((const logic_typespec*)t)->Ranges();
        case uhdmarray_typespec: return ((const array_typespec*)t)->Ranges();
        case uhdmpacked_array_typespec:
            return ((const packed_array_typespec*)t)->Ranges();
        default: return nullptr;
    }
}

static void row(const typespec* t, const char* sect) {
    const ref_typespec* al = t->Typedef_alias();
    const typespec* tgt = al ? al->Actual_typespec() : nullptr;
    std::string payload;
    const VectorOfrange* rv = rangesOf(t);
    if (!rv) payload = "RANGES=NONE";
    else {
        payload = "RANGES=" + std::to_string(rv->size());
        for (auto* r : *rv)
            payload += " {sz=" + std::to_string(r->VpiSize()) +
                       " L=" + node(r->Left_expr()) +
                       " R=" + node(r->Right_expr()) + "}";
    }
    std::cout << g_tag << "\t" << sect << "\t" << kd(t) << "\t"
              << esc(t->VpiName()) << "\t" << span(t) << "\t"
              << (al ? "ALIAS:" + kd(tgt) + ":" + esc(tgt ? tgt->VpiName() : "-")
                     : std::string("NOALIAS"))
              << "\t" << (tgt ? span(tgt) : std::string("-")) << "\t" << payload
              << "\n";
}

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "usage: ctv190cen <file.uhdm> [tag]\n";
        return 2;
    }
    Serializer s;
    std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
    if (restored.empty()) {
        std::cerr << "RESTORE-FAILED " << argv[1] << "\n";
        return 3;
    }
    if (argc > 2) g_tag = argv[2];

    long nEnum = 0, nAlias = 0, nRng = 0;
    for (auto& it : s.AllObjects()) {
        const BaseClass* o = it.first;
        if (!o) continue;
        if (o->UhdmType() == uhdmenum_typespec) {
            const ref_typespec* br = ((const enum_typespec*)o)->Base_typespec();
            const typespec* b = br ? br->Actual_typespec() : nullptr;
            if (b) { row(b, "TDCE"); ++nEnum; }
        }
        const typespec* t = any_cast<const typespec*>(o);
        if (t && t->Typedef_alias()) { row(t, "TDCX"); ++nAlias; }
        if (t && rangesOf(t)) { row(t, "RNGA"); ++nRng; }
    }
    std::cerr << "COUNTS tdce=" << nEnum << " tdcx=" << nAlias
              << " rnga=" << nRng << " " << argv[1] << "\n";
    return 0;
}
