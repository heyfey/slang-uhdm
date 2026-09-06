// r10earl104 -- THE FOLDED-CONSTANT TYPESPEC CENSUS.
//
// MEASUREMENT ONLY.  The official ~/git-repos/UHDM/build/bin/uhdm-cmp is the
// sole acceptance judge; nothing here judges anything.
//
// THE POPULATION.  Every `param_assign` whose Rhs is a CONSTANT that carries a
// typespec, on either side, in either view.  The head of this pass lives there:
//
//   param_assign(pinmux.sv:53:56-54:59)  Rhs = constant 54:22-54:59
//     |vpiTypespec ref_typespec{work@top_earlgrey.u_pinmux}
//        |vpiActual  golden: int_typespec   LOCLESS, VpiValue "UINT:1", no range
//                    ours  : logic_typespec LOCLESS, range [31:0]
//
// KEY   (view, Lhs VpiFullName, param_assign line:col span).  The VIEW is part
//       of the key because the DEF listing (design::AllModules) and the ELAB
//       listing (design::TopModules) hold param_assigns at the SAME span for
//       the SAME parameter; merging them halves the census (earl55's lesson).
//       The span carries NO FILE on purpose: our param_assign objects have an
//       EMPTY VpiFile where golden's carry the path, and `param_assign::Compare`
//       never reads VpiFile (earl55's instrument correction).
//
// PAYLOAD  the typespec rendered as a STRING -- kind, loc-less-or-span, name,
//       VpiSigned, VpiValue VERBATIM, and every range rendered as its two bound
//       expressions' verbatim values.  uvm159's verifier lesson: score the
//       typespec STRING, not a count; a count is blind to a re-kind that keeps
//       the cardinality.  The Rhs constant's own encoding (const type / size /
//       value) rides along so a typespec move that drags the constant is visible.
//
// ORIGIN  the DEF-view listing keeps the UNFOLDED initializer, so the origin of
//       a folded ELAB constant is read off the DEF-view param_assign at the SAME
//       SPAN: `op<N>` for an operation (34 = vpiMultiConcatOp = a REPLICATION,
//       30 = vpiConcatOp, 91/92 = assignment patterns, ...), `const` for an
//       already-folded one, `ref`/`hier`/`call`/... otherwise.  Read from the
//       GOLDEN database so the origin key is not a function of our own emitter.
//
// build:
//   g++ -O2 -std=c++17 cen104.cpp -I ~/.local/include \
//       -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o cen104
// usage:
//   cen104 <golden.uhdm> <ours.uhdm> [--all]
//     TSV on stdout: one CELL row per paired key plus SUMMARY / FAMILY lines.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cctype>
#include <cstdio>
#include <cstring>
#include <map>
#include <set>
#include <string>
#include <unordered_map>
#include <unordered_set>
#include <variant>
#include <vector>

using namespace UHDM;

static std::string base(std::string_view p) {
    size_t i = p.find_last_of('/');
    return std::string(i == std::string_view::npos ? p : p.substr(i + 1));
}
static std::string spanOf(const BaseClass* o) {
    if (!o) return "<null>";
    char b[192];
    snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
             o->VpiEndLineNo(), (unsigned)o->VpiEndColumnNo());
    return b;
}
static std::string fullName(const BaseClass* o) {
    if (!o) return "";
    auto pv = o->GetVpiPropertyValue(vpiFullName);
    if (std::holds_alternative<const char*>(pv)) {
        const char* p = std::get<const char*>(pv);
        if (p && *p) return p;
    }
    return std::string(o->VpiName());
}
static bool locless(const BaseClass* o) {
    return o && o->VpiLineNo() == 0 && o->VpiColumnNo() == 0;
}
// The bound of a range, verbatim: a constant prints its value, anything else
// prints its kind (an unfolded bound is a DIFFERENT answer, not a missing one).
static std::string boundOf(const expr* e) {
    if (!e) return "-";
    if (auto* c = any_cast<const constant*>((const any*)e))
        return std::string(c->VpiValue());
    return std::string(UhdmName(e->UhdmType()));
}
static const VectorOfrange* rangesOf(const typespec* t) {
    const any* a = (const any*)t;
#define TRY(T) if (auto* x = any_cast<const T*>(a)) return x->Ranges();
    TRY(logic_typespec) TRY(int_typespec) TRY(bit_typespec)
    TRY(array_typespec) TRY(packed_array_typespec) TRY(unsupported_typespec)
#undef TRY
    return nullptr;
}
static bool signedOf(const typespec* t) {
    const any* a = (const any*)t;
#define TRY(T) if (auto* x = any_cast<const T*>(a)) return x->VpiSigned();
    TRY(logic_typespec) TRY(int_typespec) TRY(bit_typespec)
    TRY(integer_typespec) TRY(byte_typespec) TRY(short_int_typespec)
    TRY(long_int_typespec)
#undef TRY
    return false;
}
// THE TYPESPEC AS A STRING.  Every field int_typespec::Compare and
// logic_typespec::Compare read is in here (VpiType via the kind name, VpiName,
// VpiDefName, VpiSigned, Ranges), plus the two the judge does NOT read but the
// dump does (the span and VpiValue) -- kept because a law that re-kinds a
// typespec must also be scored on what it does to the location and the value.
static std::string tsString(const typespec* a) {
    if (!a) return "NONE";
    std::string d = UhdmName(a->UhdmType());
    d += locless(a) ? "@LOCLESS" : ("@" + base(a->VpiFile()) + ":" + spanOf(a));
    if (!a->VpiName().empty()) d += ",name=" + std::string(a->VpiName());
    if (!a->VpiDefName().empty()) d += ",def=" + std::string(a->VpiDefName());
    if (signedOf(a)) d += ",signed";
    if (auto* it = any_cast<const int_typespec*>((const any*)a))
        if (!it->VpiValue().empty()) d += ",val=" + std::string(it->VpiValue());
    if (const VectorOfrange* rs = rangesOf(a)) {
        d += ",ranges=[";
        for (size_t i = 0; i < rs->size(); i++) {
            if (i) d += ";";
            d += boundOf((*rs)[i]->Left_expr()) + ":" +
                 boundOf((*rs)[i]->Right_expr());
        }
        d += "]";
    }
    return d;
}
// The Rhs constant's own compare-visible encoding.
static std::string rhsString(const any* rhs) {
    if (!rhs) return "NO-RHS";
    std::string d = UhdmName(rhs->UhdmType());
    if (auto* c = any_cast<const constant*>(rhs)) {
        char b[64];
        snprintf(b, sizeof b, ",sz=%d,ct=%d,v=", c->VpiSize(), c->VpiConstType());
        d += b;
        d += std::string(c->VpiValue());
    } else if (auto* op = any_cast<const operation*>(rhs)) {
        char b[32];
        snprintf(b, sizeof b, ",op=%d", op->VpiOpType());
        d += b;
    }
    return d;
}
static const typespec* tsOf(const any* rhs) {
    if (!rhs) return nullptr;
    if (auto* e = any_cast<const expr*>(rhs))
        if (const ref_typespec* rt = e->Typespec()) return rt->Actual_typespec();
    return nullptr;
}
// The ORIGIN token of a DEF-view Rhs.
static std::string originOf(const any* rhs) {
    if (!rhs) return "none";
    if (auto* op = any_cast<const operation*>(rhs)) {
        char b[32];
        snprintf(b, sizeof b, "op%d", op->VpiOpType());
        return b;
    }
    return std::string(UhdmName(rhs->UhdmType()));
}

struct Cell {
    std::string view, name, span, rhs, ts, file;
};

static void collect(Serializer& s, std::map<std::string, Cell>& out,
                    std::map<std::string, std::string>& originBySpan, bool& ok) {
    std::vector<const BaseClass*> all;
    for (const auto& [obj, id] : s.AllObjects())
        if (obj) all.push_back(obj);
    std::sort(all.begin(), all.end(), [](const BaseClass* a, const BaseClass* b) {
        return a->UhdmId() != b->UhdmId() ? a->UhdmId() < b->UhdmId() : a < b;
    });
    const design* dz = nullptr;
    for (const BaseClass* o : all)
        if (o->UhdmType() == uhdmdesign) { dz = (const design*)o; break; }
    if (!dz) { ok = false; return; }
    std::unordered_set<const BaseClass*> defRoots, elabRoots;
    if (dz->AllModules()) for (auto* m : *dz->AllModules()) defRoots.insert(m);
    if (dz->TopModules()) for (auto* m : *dz->TopModules()) elabRoots.insert(m);
    for (const BaseClass* o : all) {
        if (o->UhdmType() != uhdmparam_assign) continue;
        auto* pa = (const param_assign*)o;
        const BaseClass* top = o;
        while (top->VpiParent() && top->VpiParent()->UhdmType() != uhdmdesign)
            top = top->VpiParent();
        const char* view = defRoots.count(top) ? "DEF"
                         : elabRoots.count(top) ? "ELAB" : "OTHER";
        Cell c;
        c.view = view;
        c.name = fullName(pa->Lhs());
        c.span = spanOf(pa);
        c.rhs = rhsString(pa->Rhs());
        c.ts = tsString(tsOf(pa->Rhs()));
        c.file = base(pa->VpiFile());
        if (c.file.empty() && pa->Lhs()) c.file = base(pa->Lhs()->VpiFile());
        std::string key = c.view + "|" + c.name + "|" + c.span;
        auto it = out.find(key);
        if (it != out.end() && (it->second.rhs != c.rhs || it->second.ts != c.ts))
            printf("DUPKEY\t%s\t%s/%s\tvs\t%s/%s\n", key.c_str(),
                   it->second.rhs.c_str(), it->second.ts.c_str(), c.rhs.c_str(),
                   c.ts.c_str());
        out[key] = c;
        // origin: the DEF view's unfolded Rhs, indexed by file:span so the ELAB
        // rows of every instance of the same declaration can find it.
        if (!strcmp(view, "DEF")) {
            std::string sk = c.file + ":" + c.span;
            std::string ov = originOf(pa->Rhs());
            auto oi = originBySpan.find(sk);
            if (oi == originBySpan.end())
                originBySpan[sk] = ov;
            else if (oi->second != ov)
                originBySpan[sk] = "AMBIG";
        }
    }
    ok = true;
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: cen104 <golden.uhdm> <ours.uhdm> [--all]\n");
        return 2;
    }
    bool all = false;
    for (int i = 3; i < argc; i++)
        if (!strcmp(argv[i], "--all")) all = true;
    Serializer sg, so;
    if (sg.Restore(std::string(argv[1])).empty()) {
        fprintf(stderr, "RESTORE_FAILED %s\n", argv[1]);
        return 3;
    }
    if (so.Restore(std::string(argv[2])).empty()) {
        fprintf(stderr, "RESTORE_FAILED %s\n", argv[2]);
        return 3;
    }
    std::map<std::string, Cell> G, O;
    std::map<std::string, std::string> originG, originO;
    bool okg = false, oko = false;
    collect(sg, G, originG, okg);
    collect(so, O, originO, oko);
    if (!okg || !oko) { fprintf(stderr, "NO_DESIGN\n"); return 4; }
    printf("#\tcen104\tgolden_cells=%zu\tours_cells=%zu\n", G.size(), O.size());
    int agree = 0, dis = 0, ug = 0, uo = 0;
    std::map<std::string, int> fam;
    for (auto& [k, g] : G) {
        auto it = O.find(k);
        std::string org = originG.count(g.file + ":" + g.span)
                              ? originG[g.file + ":" + g.span]
                              : "?";
        if (it == O.end()) {
            ug++;
            printf("ONLY-GOLDEN\t%s\t%s\t%s\t%s\t%s\n", k.c_str(), org.c_str(),
                   g.rhs.c_str(), g.ts.c_str(), g.file.c_str());
            continue;
        }
        const Cell& o = it->second;
        bool same = (g.rhs == o.rhs && g.ts == o.ts);
        if (same) agree++; else dis++;
        // only rows where a TYPESPEC exists on some side are the population
        bool inPop = (g.ts != "NONE" || o.ts != "NONE");
        if (all || (!same && inPop))
            printf("CELL\t%s\t%s\t%s\tG\t%s\t%s\tO\t%s\t%s\t%s\n",
                   same ? "SAME" : "DIFF", k.c_str(), org.c_str(), g.rhs.c_str(),
                   g.ts.c_str(), o.rhs.c_str(), o.ts.c_str(), g.file.c_str());
        if (!same && inPop) {
            std::string v = k.substr(0, k.find('|'));
            fam[v + "\t" + org + "\t" + g.rhs + " > " + o.rhs + "\tTS " + g.ts +
                " > " + o.ts]++;
        }
    }
    for (auto& [k, o] : O)
        if (!G.count(k)) {
            uo++;
            printf("ONLY-OURS\t%s\t%s\t%s\t%s\n", k.c_str(), o.rhs.c_str(),
                   o.ts.c_str(), o.file.c_str());
        }
    printf("SUMMARY\tagree=%d\tdisagree=%d\tonly_golden=%d\tonly_ours=%d\n",
           agree, dis, ug, uo);
    printf("== FAMILIES (view / origin / rhs / typespec)\n");
    for (auto& [f, c] : fam) printf("FAM\t%6d\t%s\n", c, f.c_str());
    return 0;
}
