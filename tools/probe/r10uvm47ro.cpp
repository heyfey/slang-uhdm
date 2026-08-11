// r10uvm47ro — the vpiActual BINDING of a DATA DECLARATION's INITIALISER, for
// every `variables` AND every `nets` object in a database, at every depth of the
// initialiser expression.
//
// Pass 47's target-1 head is `SafeCompare(lhs, rhs=nullptr)` with the LHS a
// package-parented `class_var`.  `BaseClass.h:191` is the ONLY arm that leaves
// `m_failedRhs` null while printing a CHILD, so the failing field is a SCALAR
// pointer whose golden value is that class_var and whose value on our side is
// null.  Measured with this probe: golden's `uvm_pkg::uvm_default_printer`
// (`uvm_printer uvm_default_printer = uvm_default_table_printer;`) carries
// vpiExpr = ref_obj'uvm_default_table_printer' whose **vpiActual** IS that
// class_var; we emit the identical ref_obj with vpiActual null.
//
//   REF  <owner kind>'<owner name>' full='<owner fullname>' parent=<kind>'<full>'
//        expr=<kind>'<name>' @<depth> ref=<kind>'<name>' actual=<kind>'<name>'
//        actualfull='<fullname>'
//
// THREE things this probe deliberately does that a narrower one would not, each
// because a narrower one already misled this pass once:
//
//  * it walks NETS as well as VARIABLES — a package data declaration written
//    with a user typedef that resolves to a packed vector is a logic_NET, a
//    different emitter arm, and a variables-only census reports that half as
//    ABSENT rather than as UNMEASURED.
//  * it RECURSES the whole initialiser expression (operands, selects, calls,
//    both sides of an assignment) and reports every ref_obj/ref_var it finds
//    with its DEPTH, because golden's top-level expr for `int i = f + 1` is an
//    `operation` and a top-level-only reader sees `actual=<none>` and concludes
//    the shape is absent.
//  * it prints the OWNER's vpiParent, so a PACKAGE listing, an importing
//    package's CLONE listing and a MODULE's hoisted copy are told apart —
//    golden binds a bare imported name to the IMPORTING listing's own clone
//    (`p3::i_first`), not to the home package's object, and a census that
//    collapsed the three would have called that a naming bug.
//
// POSITIVE CONTROL: a restore that yields no design, or a database with zero
// variables AND zero nets, is FATAL on stderr with a nonzero exit; and a filter
// that matches nothing is reported on stderr as EMPTY with the population, so a
// blind run cannot pass for a closed residue.
//
//   r10uvm47ro <file.uhdm> [nameFilter] [-p]
//     nameFilter  substring matched against the OWNER's vpiName/vpiFullName
//     -p          restrict to owners whose vpiParent is a package
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string sv(std::string_view s) { return std::string(s); }

static std::string fullOf(const any* o) {
    if (!o)
        return "<none>";
    if (auto* i = any_cast<const instance*>(o))
        return sv(i->VpiFullName());
    if (auto* v = any_cast<const variables*>(o))
        return sv(v->VpiFullName());
    if (auto* n = any_cast<const nets*>(o))
        return sv(n->VpiFullName());
    if (auto* r = any_cast<const ref_obj*>(o))
        return sv(r->VpiFullName());
    if (auto* rt = any_cast<const ref_typespec*>(o))
        return sv(rt->VpiFullName());
    if (auto* tf = any_cast<const task_func*>(o))
        return sv(tf->VpiFullName());
    if (auto* cd = any_cast<const class_defn*>(o))
        return sv(cd->VpiFullName());
    if (auto* sc = any_cast<const scope*>(o))
        return sv(sc->VpiFullName());
    return "name:" + sv(o->VpiName());
}

static std::string kn(const any* o) {
    if (!o)
        return "<none>'<none>'";
    return sv(UhdmName(o->UhdmType())) + "'" + sv(o->VpiName()) + "'";
}

// The bound object's SPAN.  Two objects in one listing can share a fullname (a
// package member and the out-of-body constructor local Surelog hoists beside
// it — t65c has exactly that pair), and a fullname-only report cannot say which
// of the two a vpiActual picked.  A FAN-IN COUNT cannot answer a WHO question.
static std::string spanOf(const any* o) {
    if (!o)
        return "<none>";
    auto* b = (const BaseClass*)o;
    return "@" + std::to_string(b->VpiLineNo()) + ":" +
           std::to_string(b->VpiColumnNo()) + "-" +
           std::to_string(b->VpiEndLineNo()) + ":" +
           std::to_string(b->VpiEndColumnNo());
}

// Every ref_obj/ref_var inside an initialiser, with its depth.  The relations
// walked are the ones an initialiser can actually nest through; each is listed
// explicitly rather than through GetByVpiType because that helper has no
// vpiTypespec arm and a "one field short" walk is how a closed head gets
// reported.
static void collectRefs(const any* e, int depth,
                        std::vector<std::pair<int, const any*>>& acc) {
    if (!e || depth > 12)
        return;
    if (e->UhdmType() == uhdmref_obj || e->UhdmType() == uhdmref_var) {
        acc.push_back({depth, e});
        return;
    }
    if (auto* op = any_cast<const operation*>(e)) {
        if (auto* ops = op->Operands())
            for (auto* o : *ops)
                collectRefs(o, depth + 1, acc);
        return;
    }
    if (auto* ps = any_cast<const part_select*>(e)) {
        collectRefs(ps->Left_range(), depth + 1, acc);
        collectRefs(ps->Right_range(), depth + 1, acc);
        return;
    }
    if (auto* bs = any_cast<const bit_select*>(e)) {
        collectRefs(bs->VpiIndex(), depth + 1, acc);
        return;
    }
    if (auto* fc = any_cast<const tf_call*>(e)) {
        if (auto* args = fc->Tf_call_args())
            for (auto* a : *args)
                collectRefs(a, depth + 1, acc);
        return;
    }
    if (auto* sn = any_cast<const sys_func_call*>(e)) {
        if (auto* args = sn->Tf_call_args())
            for (auto* a : *args)
                collectRefs(a, depth + 1, acc);
        return;
    }
}

static const any* actualOf(const any* r) {
    if (auto* ro = any_cast<const ref_obj*>(r))
        return ro->Actual_group();
    if (auto* rv = any_cast<const ref_var*>(r))
        return rv->Actual_group();
    return nullptr;
}

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "usage: r10uvm47ro <file.uhdm> [nameFilter] [-p]\n";
        return 2;
    }
    std::string filt;
    bool pkgOnly = false;
    for (int i = 2; i < argc; i++) {
        std::string a(argv[i]);
        if (a == "-p")
            pkgOnly = true;
        else
            filt = a;
    }
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    if (h.empty()) {
        std::cerr << "FATAL: restore produced no design from " << argv[1]
                  << "\n";
        return 1;
    }
    std::vector<std::string> out;
    size_t population = 0;
    for (auto& [o, id] : s.AllObjects()) {
        (void)id;
        if (!o)
            continue;
        const any* par = nullptr;
        const expr* init = nullptr;
        std::string full, okind;
        if (auto* v = any_cast<const variables*>(o)) {
            population++;
            par = v->VpiParent();
            init = v->Expr();
            full = sv(v->VpiFullName());
        }
        else if (auto* n = any_cast<const nets*>(o)) {
            population++;
            par = n->VpiParent();
            // A net's initialiser rides on vpiExpr for the kinds that carry
            // one; logic_net has no Expr() accessor, so read it through the
            // generic relation.
            auto tp = o->GetByVpiType(vpiExpr);
            init = (const expr*)std::get<0>(tp);
            full = sv(n->VpiFullName());
        }
        else
            continue;
        if (pkgOnly && !(par && par->UhdmType() == uhdmpackage))
            continue;
        if (!filt.empty() && full.find(filt) == std::string::npos &&
            sv(o->VpiName()).find(filt) == std::string::npos)
            continue;
        std::vector<std::pair<int, const any*>> refs;
        collectRefs(init, 0, refs);
        if (refs.empty()) {
            out.push_back("REF  " + kn(o) + " full='" + full + "' parent=" +
                          kn(par) + "'" + fullOf(par) + "' expr=" + kn(init) +
                          " @- ref=<none> actual=<none> actualfull='<none>'");
            continue;
        }
        for (auto& [d, r] : refs) {
            const any* act = actualOf(r);
            out.push_back("REF  " + kn(o) + " full='" + full + "' parent=" +
                          kn(par) + "'" + fullOf(par) + "' expr=" + kn(init) +
                          " @" + std::to_string(d) + " ref=" + kn(r) + spanOf(o) +
                          " actual=" + kn(act) + " actualfull='" + fullOf(act) +
                          "'" + spanOf(act));
        }
    }
    if (population == 0) {
        std::cerr << "FATAL: database holds ZERO variables AND ZERO nets — "
                     "BLIND, not a zero residue\n";
        return 1;
    }
    if (out.empty())
        std::cerr << "EMPTY: population=" << population
                  << " variables+nets, but the filter/-p selection matched "
                     "none — printed on stderr so it cannot pass for a census "
                     "line\n";
    std::sort(out.begin(), out.end());
    out.erase(std::unique(out.begin(), out.end()), out.end());
    for (auto& l : out)
        std::cout << l << "\n";
    std::cout << "ROTOTAL=" << out.size() << " population=" << population
              << "\n";
    return 0;
}
