// r10buvm20 — THE SUBROUTINE-SITE TYPESPEC CENSUS (return type / formal /
// local variable / class property).
// MEASUREMENT ONLY; nothing here is an acceptance judge (uhdm-cmp and
// scripts/verify_golden.py are).
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// One row per typespec SITE, carrying
//   * the KEY: view | owner full name | site tag | line:col of the SITE
//     object.  Locations, not files: OUR expression nodes carry an EMPTY
//     VpiFile (buvm16 § 4).
//   * the VIEW: ELABPKG / DEFPKG / TOPMOD / DEFMOD / DEFCLASS / ... decided by
//     the ROOT ancestor one step below `uhdmdesign` (buvm17 trap 1).
//   * the VALUE: the ACTUAL typespec's kind + VpiName, whether it carries a
//     `Typedef_alias` and that alias' target kind+name, the packed range
//     bound ENCODING (folded constant vs symbolic operation), VpiSigned, and
//     the vpiInstance name.  Every one of those (bar the instance NAME, which
//     stands in for the object) is a field the generated `Compare` reads.
//
// usage: r10buvm20cen <file.uhdm> [tag]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <iostream>
#include <map>
#include <string>
#include <vector>
using namespace UHDM;

static std::string nm(const any* t) { return t ? std::string(t->VpiName()) : "-"; }
static std::string kd(const any* t) { return t ? std::string(UhdmName(t->UhdmType())) : "NULL"; }
static std::string loc(const any* o) {
    return o ? std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo()) : "-";
}
static std::string fn(const any* t) {
    if (!t) return "-";
    if (t->UhdmType() == uhdmfunction) return std::string(((const function*)t)->VpiFullName());
    if (t->UhdmType() == uhdmtask) return std::string(((const task*)t)->VpiFullName());
    if (t->UhdmType() == uhdmclass_defn) return std::string(((const class_defn*)t)->VpiFullName());
    return std::string(t->VpiName());
}

// The bound ENCODING: a folded constant prints its value, a symbolic tree
// prints its kind.  This is the § pkgTdRangeViewFold18 axis.
static std::string bnd(const expr* e) {
    if (!e) return "-";
    if (e->UhdmType() == uhdmconstant) {
        const constant* c = (const constant*)e;
        return "C" + std::string(c->VpiDecompile());
    }
    return "S" + kd(e);
}

static std::string rng(const typespec* t) {
    const VectorOfrange* rs = nullptr;
    switch (t->UhdmType()) {
        case uhdmlogic_typespec: rs = ((const logic_typespec*)t)->Ranges(); break;
        case uhdmbit_typespec: rs = ((const bit_typespec*)t)->Ranges(); break;
        case uhdmarray_typespec: rs = ((const array_typespec*)t)->Ranges(); break;
        case uhdmpacked_array_typespec: rs = ((const packed_array_typespec*)t)->Ranges(); break;
        default: break;
    }
    if (!rs) return "rg=-";
    std::string o = "rg=" + std::to_string(rs->size());
    for (auto* r : *rs) o += "[" + bnd(r->Left_expr()) + ":" + bnd(r->Right_expr()) + "]";
    return o;
}

static std::string sgn(const typespec* t) {
    switch (t->UhdmType()) {
        case uhdmlogic_typespec: return ((const logic_typespec*)t)->VpiSigned() ? "sg=1" : "sg=0";
        case uhdmbit_typespec: return ((const bit_typespec*)t)->VpiSigned() ? "sg=1" : "sg=0";
        case uhdmint_typespec: return ((const int_typespec*)t)->VpiSigned() ? "sg=1" : "sg=0";
        default: return "sg=-";
    }
}

static std::string val(const ref_typespec* rt) {
    if (!rt) return "NOREF";
    const typespec* a = rt->Actual_typespec();
    if (!a) return "REFNULL";
    std::string o = kd(a) + "(" + nm(a) + ")";
    if (const ref_typespec* al = a->Typedef_alias()) {
        const typespec* at = al->Actual_typespec();
        o += "[alias->" + (at ? kd(at) + "(" + nm(at) + ")" : std::string("<null>")) + "]";
    } else {
        o += "[noalias]";
    }
    o += " " + rng(a) + " " + sgn(a);
    const instance* in = a->Instance();
    o += " inst=" + (in ? kd(in) + "(" + nm(in) + ")" : std::string("-"));
    return o;
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: r10buvm20cen <file.uhdm> [tag]\n"; return 2; }
    std::string tag = argc > 2 ? argv[2] : "T";
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { std::cout << "RESTORE_FAIL " << tag << "\n"; return 3; }

    std::map<const any*, std::string> rootView;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o || o->UhdmType() != uhdmdesign) continue;
        const design* d = (const design*)o;
        if (auto* v = d->TopPackages()) for (auto* p : *v) rootView.emplace(p, "ELABPKG");
        if (auto* v = d->TopModules()) for (auto* p : *v) rootView.emplace(p, "TOPMOD");
        if (auto* v = d->AllPackages()) for (auto* p : *v) rootView.emplace(p, "DEFPKG");
        if (auto* v = d->AllModules()) for (auto* p : *v) rootView.emplace(p, "DEFMOD");
        if (auto* v = d->AllClasses()) for (auto* p : *v) rootView.emplace(p, "DEFCLASS");
        if (auto* v = d->AllPrograms()) for (auto* p : *v) rootView.emplace(p, "DEFPROG");
        if (auto* v = d->AllInterfaces()) for (auto* p : *v) rootView.emplace(p, "DEFIFACE");
    }

    auto viewOf = [&](const any* o) {
        const any* p = o->VpiParent();
        const any* last = o;
        int d = 0;
        while (p && d++ < 128) {
            if (p->UhdmType() != uhdmdesign) last = p;
            p = p->VpiParent();
        }
        auto rv = rootView.find(last);
        return rv != rootView.end() ? rv->second : ("ROOT-" + kd(last));
    };

    std::vector<std::string> rows;
    long nret = 0, nio = 0, nlv = 0, nprop = 0, nrl = 0;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o) continue;
        UHDM_OBJECT_TYPE t = o->UhdmType();
        if (t == uhdmfunction || t == uhdmtask) {
            const task_func* tf = (const task_func*)o;
            std::string home = fn(o), view = viewOf(o);
            if (t == uhdmfunction) {
                const variables* rv = ((const function*)o)->Return();
                if (rv) {
                    rows.push_back("TS " + tag + " key=" + view + "|" + home + "|RET|" +
                                   loc(rv) + " rvk=" + kd(rv) + " v=" + val(rv->Typespec()));
                    nret++;
                }
            }
            if (auto* ios = tf->Io_decls())
                for (auto* io : *ios) {
                    rows.push_back("TS " + tag + " key=" + view + "|" + home + "|IO:" +
                                   std::string(io->VpiName()) + "|" + loc(io) +
                                   " rvk=io_decl v=" + val(io->Typespec()));
                    nio++;
                }
            if (auto* vs = tf->Variables())
                for (auto* v : *vs) {
                    rows.push_back("TS " + tag + " key=" + view + "|" + home + "|LOC:" +
                                   std::string(v->VpiName()) + "|" + loc(v) +
                                   " rvk=" + kd(v) + " v=" + val(v->Typespec()));
                    nlv++;
                }
        }
        // The BODY-LOCAL return variable: the object a body reference
        // (`unpack_field = 'b0;`) binds, minted by `drainFuncRet` on our side
        // and by the write phase on Surelog's.  It is NOT any function's
        // `vpiReturn`, so the task_func walk above cannot see it; it is
        // reached only as the `Actual_group` of a `ref_obj`.  THIS IS THE
        // HEAD'S OWN SITE.
        else if (t == uhdmref_typespec) {
            const ref_typespec* r = (const ref_typespec*)o;
            const any* v = r->VpiParent();
            if (!v || !any_cast<const variables*>(v)) continue;
            const any* p = v->VpiParent();
            if (!p || p->UhdmType() != uhdmref_obj) continue;
            rows.push_back("TS " + tag + " key=" + viewOf(o) + "|" +
                           std::string(r->VpiFullName()) + "|RETLOCAL|" +
                           loc(v) + " rvk=" + kd(v) + " v=" + val(r));
            nrl++;
        }
        else if (t == uhdmclass_defn) {
            const class_defn* c = (const class_defn*)o;
            std::string home = fn(o), view = viewOf(o);
            if (auto* vs = c->Variables())
                for (auto* v : *vs) {
                    rows.push_back("TS " + tag + " key=" + view + "|" + home + "|PROP:" +
                                   std::string(v->VpiName()) + "|" + loc(v) +
                                   " rvk=" + kd(v) + " v=" + val(v->Typespec()));
                    nprop++;
                }
        }
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) std::cout << r << "\n";
    std::cout << "SUMMARY " << tag << " rows=" << rows.size() << " RET=" << nret
              << " IO=" << nio << " LOC=" << nlv << " PROP=" << nprop << " RETLOCAL=" << nrl << "\n";
    return 0;
}
