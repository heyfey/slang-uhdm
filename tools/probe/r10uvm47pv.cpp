// r10uvm47pv — the PACKAGE-SCOPE VARIABLE census, plus a generic WHO-POINTS-AT-IT
// path finder.
//
// Pass 47's target 1 is a uhdm-cmp head whose LHS is a package-parented
// `class_var` and whose RHS is `<null>`.  `SafeCompare` sets `m_failedRhs` to
// nullptr in exactly two cases (BaseClass.h:191 and the element arm of the
// vector overload at :215), and in BOTH the printed LHS is the CHILD, not the
// container — so the head does NOT say which FIELD of which OWNER was being
// compared, and it does NOT say whether we hold the object elsewhere.  A
// KIND:NAME census cannot answer that either.  Two halves, therefore:
//
//   OBJ  <kind> '<name>' full='<fullname>' <file>:<l>:<c>-<el>:<ec>
//        autom=<0/1> vis=<n> const=<0/1> ts=<kind>'<name>'@<l>:<c>-<el>:<ec>
//        refts='<fullname>' expr=<kind>'<name>' parent=<kind>'<fullname>'
//   PATH <fullname> <- <kind>'<name>' <- <kind>'<name>' ...
//
// The OBJ half is emitted for every `variables` object whose vpiParent is a
// package (that is the shape the head shows); `-a` widens it to EVERY
// `variables` in the database whose name matches the filter, which is what
// answers "do we hold it somewhere else instead".  The PATH half walks the
// design with UhdmListener (which follows every generated relation, not a
// hand-picked list) and prints the callstack to each matching object, which is
// how the OWNER of the failing scalar field is named rather than guessed.
//
// POSITIVE CONTROL, mandatory in this campaign: a database that yields no
// design, or a filter that matches NOTHING while the database holds a nonzero
// population of `variables`, is reported as FATAL/EMPTY on stderr with a
// nonzero exit — never as a quiet zero.  A driver that cannot see its subject
// must not be able to report perfection.
//
//   r10uvm47pv <file.uhdm> [nameFilter] [-a] [-P]
//     nameFilter  substring matched against VpiName and VpiFullName
//     -a          all `variables`, not just package-parented ones
//     -P          also print the PATH half (design walk; slower on uvm_pkg)
#include <uhdm/Serializer.h>
#include <uhdm/UhdmListener.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string sv(std::string_view s) { return std::string(s); }

static std::string spanOf(const any* o) {
    if (!o)
        return "<none>";
    auto* b = (const BaseClass*)o;
    return std::to_string(b->VpiLineNo()) + ":" +
           std::to_string(b->VpiColumnNo()) + "-" +
           std::to_string(b->VpiEndLineNo()) + ":" +
           std::to_string(b->VpiEndColumnNo());
}

static std::string leaf(std::string_view f) {
    std::string s(f);
    auto p = s.find_last_of('/');
    return p == std::string::npos ? s : s.substr(p + 1);
}

// vpiFullName is NOT on BaseClass — it is declared per group, so a bare cast
// cannot read it.  Try the groups that actually carry it and fall back to
// vpiName, which is on BaseClass.  (Silently printing vpiName as if it were the
// fullname would be the same class of defect as a census that cannot see its
// subject, so the caller is told which it got.)
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
    if (auto* t = any_cast<const typespec*>(o))
        return sv(t->VpiName());
    if (auto* sc = any_cast<const scope*>(o))
        return sv(sc->VpiFullName());
    return "name:" + sv(o->VpiName());
}

static std::string kindName(const any* o) {
    if (!o)
        return "<none>'<none>'";
    return sv(UhdmName(o->UhdmType())) + "'" + sv(o->VpiName()) + "'";
}

namespace {
class PathFinder : public UhdmListener {
  public:
    std::string filt;
    std::vector<std::string>* out = nullptr;
    void enterAny(const any* const object) override {
        if (!object)
            return;
        const BaseClass* b = (const BaseClass*)object;
        std::string n(b->VpiName()), f(fullOf(object));
        if (filt.empty() ||
            (n.find(filt) == std::string::npos &&
             f.find(filt) == std::string::npos))
            return;
        if (object->UhdmType() != uhdmclass_var &&
            object->UhdmType() != uhdmlogic_var &&
            object->UhdmType() != uhdmint_var &&
            object->UhdmType() != uhdmstring_var &&
            object->UhdmType() != uhdmenum_var &&
            object->UhdmType() != uhdmarray_var)
            return;
        std::string l = "PATH " + kindName(object) + " id:" +
                        std::to_string(b->UhdmId()) + " full='" + f + "'";
        const auto& cs = getCallstack();
        // Innermost first, skipping the object itself (it is on the stack).
        for (auto it = cs.crbegin(); it != cs.crend(); ++it) {
            if (*it == object)
                continue;
            l += " <- " + kindName(*it);
        }
        out->push_back(l);
    }
};
}  // namespace

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "usage: r10uvm47pv <file.uhdm> [nameFilter] [-a] [-P]\n";
        return 2;
    }
    std::string filt;
    bool all = false, paths = false;
    for (int i = 2; i < argc; i++) {
        std::string a(argv[i]);
        if (a == "-a")
            all = true;
        else if (a == "-P")
            paths = true;
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
        {
            if (!o)
                continue;
            auto* v = any_cast<const variables*>(o);
            if (!v)
                continue;
            population++;
            const any* par = v->VpiParent();
            bool pkgScope = par && par->UhdmType() == uhdmpackage;
            if (!all && !pkgScope)
                continue;
            std::string n(v->VpiName()), f(v->VpiFullName());
            if (!filt.empty() && n.find(filt) == std::string::npos &&
                f.find(filt) == std::string::npos)
                continue;
            const typespec* ts = nullptr;
            std::string refts = "<none>";
            if (auto* rt = v->Typespec()) {
                refts = "'" + sv(rt->VpiFullName()) + "'";
                ts = rt->Actual_typespec();
            }
            std::string l =
                "OBJ  " + kindName(v) + " full='" + f + "' " +
                leaf(v->VpiFile()) + ":" + spanOf(v) +
                " autom=" + std::to_string(v->VpiAutomatic() ? 1 : 0) +
                " vis=" + std::to_string(v->VpiVisibility()) +
                " const=" + std::to_string(v->VpiConstantVariable() ? 1 : 0) +
                " ts=" + kindName(ts) + "@" + (ts ? spanOf(ts) : "<none>") +
                " refts=" + refts + " expr=" + kindName(v->Expr()) +
                " parent=" +
                (par ? sv(UhdmName(par->UhdmType())) + "'" + fullOf(par) + "'"
                     : std::string("<none>"));
            out.push_back(l);
        }
    }
    if (population == 0) {
        std::cerr << "FATAL: database holds ZERO `variables` objects — this is "
                     "a BLIND measurement, not a zero residue\n";
        return 1;
    }
    if (out.empty() && !filt.empty()) {
        std::cerr << "EMPTY: population=" << population
                  << " variables objects, but filter '" << filt
                  << "' matched none (this is a real zero for the filter, "
                     "printed on stderr so it cannot pass for a census line)\n";
    }
    if (paths) {
        PathFinder pf;
        pf.filt = filt;
        pf.out = &out;
        for (auto hh : h)
            pf.listenAny((const any*)((const uhdm_handle*)hh)->object);
    }
    std::sort(out.begin(), out.end());
    out.erase(std::unique(out.begin(), out.end()), out.end());
    for (auto& l : out)
        std::cout << l << "\n";
    std::cout << "PVTOTAL=" << out.size() << " population=" << population
              << "\n";
    return 0;
}
