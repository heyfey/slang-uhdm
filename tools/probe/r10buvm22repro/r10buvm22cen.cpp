// r10buvm22 — THE FUNCTION-RETURN-VARIABLE CENSUS.  MEASUREMENT ONLY; nothing
// here is an acceptance judge (uhdm-cmp and scripts/verify_golden.py are).
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// One row per `function` object in the database, carrying
//   * VIEW    — the root listing the function is reached from (buvm17/21's
//               classifier: ELABPKG / DEFPKG / DEFCLASS / TOPMOD / DEFMOD / …).
//   * HOME    — nearest enclosing class_defn (or "-"), plus whether the
//               function's own vpiParent IS that class_defn (in-body listing)
//               or something else (OOB / package / module).
//   * SITE    — RET (the function's vpiReturn variable).
//   * KIND    — the return variable's UHDM object kind (the head's field).
//   * TS      — the return variable's typespec kind, its name, and for an
//               array_typespec its vpiArrayType (queue / dynamic / assoc /
//               static), i.e. the RETURN-TYPE shape axis.
//
// A second row family, SITE=RETLOCAL, covers every `variables` object inside a
// function whose VpiName equals the function's short name and whose vpiParent
// is NOT the function — the per-reference body-local return variable
// (buvm20's site, ours minted by drainFuncRet).
//
// Key for the golden-vs-ours join: VIEW + function fullname + the variable's
// line:col (start only — end columns differ between the tools and are not
// Compare-visible for the object identity we are joining on).
//
// usage: r10buvm22cen <file.uhdm> [tag]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

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
static std::string arrTy(int t) {
    switch (t) {
        case vpiStaticArray: return "static";
        case vpiDynamicArray: return "dynamic";
        case vpiAssocArray: return "assoc";
        case vpiQueueArray: return "queue";
        default: return "at" + std::to_string(t);
    }
}
static const ref_typespec* tsRefOf(const any* v) {
    if (!v) return nullptr;
    if (const variables* vv = any_cast<const variables*>(v)) return vv->Typespec();
    return nullptr;
}
// the return-type SHAPE, as the census key: typespec kind (+ array flavour)
static std::string tsShape(const any* v) {
    const ref_typespec* rt = tsRefOf(v);
    if (!rt) return "NOTSREF";
    const typespec* ts = rt->Actual_typespec();
    if (!ts) return "NOTS";
    std::string k = kd(ts);
    if (ts->UhdmType() == uhdmarray_typespec) {
        const array_typespec* a = (const array_typespec*)ts;
        k += "/" + arrTy(a->VpiArrayType());
        const ref_typespec* er = a->Elem_typespec();
        const typespec* et = er ? er->Actual_typespec() : nullptr;
        k += "/elem=" + (et ? kd(et) : std::string("-"));
    } else if (ts->UhdmType() == uhdmpacked_array_typespec) {
        const packed_array_typespec* a = (const packed_array_typespec*)ts;
        const ref_typespec* er = a->Elem_typespec();
        const typespec* et = er ? er->Actual_typespec() : nullptr;
        k += "/elem=" + (et ? kd(et) : std::string("-"));
    }
    return k;
}
static std::string tsName(const any* v) {
    const ref_typespec* rt = tsRefOf(v);
    const typespec* ts = rt ? rt->Actual_typespec() : nullptr;
    return ts ? std::string(ts->VpiName()) : "-";
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: r10buvm22cen <file.uhdm> [tag]\n"; return 2; }
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

    long rows = 0;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o || o->UhdmType() != uhdmfunction) continue;
        const function* f = (const function*)o;
        // view + nearest class ancestor
        const any* clsAnc = nullptr;
        const any* root = nullptr;
        const any* p = f->VpiParent();
        int d = 0;
        while (p && d++ < 64) {
            if (!clsAnc && p->UhdmType() == uhdmclass_defn) clsAnc = p;
            auto it = rootView.find(p);
            if (it != rootView.end()) { root = p; break; }
            if (p->UhdmType() == uhdmdesign) break;
            p = p->VpiParent();
        }
        std::string view = root ? rootView[root] : "OTHER";
        std::string home = clsAnc ? "cls:" + nm(clsAnc) : "-";
        std::string parKind = kd(f->VpiParent());
        std::string quals;
        quals += f->VpiMethod() ? "m" : "-";
        quals += f->VpiVirtual() ? "v" : "-";
        quals += f->VpiAutomatic() ? "a" : "-";
        quals += f->VpiDPIContext() ? "d" : "-";

        const any* rv = f->Return();
        std::string kind = rv ? kd(rv) : "NORET";
        std::string sgn = "-";
        if (const variables* vv = rv ? any_cast<const variables*>(rv) : nullptr)
            sgn = vv->VpiSigned() ? "s" : "u";
        std::cout << tag << "\tRET\t" << view << "\t" << f->VpiFullName() << "\t"
                  << loc(f) << "\t" << home << "\t" << parKind << "\t" << quals
                  << "\t" << kind << "\t" << (rv ? loc(rv) : "-") << "\t"
                  << tsShape(rv) << "\ttsname=" << tsName(rv) << "\tsgn=" << sgn
                  << "\n";
        rows++;
    }
    // RETLOCAL, in ONE pass over the objects rather than per function: every
    // `variables` object whose nearest enclosing `function` ancestor is not its
    // own vpiParent-as-Return and whose VpiName equals that function's SHORT
    // name.  (The per-function inner scan this replaces was quadratic and the
    // UVM databases have ~10^6 objects.)
    for (auto& kv : s.AllObjects()) {
        const any* v2 = kv.first;
        if (!v2) continue;
        const variables* vv2 = any_cast<const variables*>(v2);
        if (!vv2) continue;
        if (vv2->VpiName().empty()) continue;
        const any* a = vv2->VpiParent();
        const function* f = nullptr;
        int dd = 0;
        while (a && dd++ < 64) {
            if (a->UhdmType() == uhdmfunction) { f = (const function*)a; break; }
            a = a->VpiParent();
        }
        if (!f) continue;
        if ((const any*)vv2 == f->Return()) continue;
        std::string shortName(f->VpiName());
        auto sp = shortName.rfind("::");
        if (sp != std::string::npos) shortName = shortName.substr(sp + 2);
        if (vv2->VpiName() != shortName) continue;
        const any* clsAnc = nullptr;
        const any* root = nullptr;
        const any* p = f->VpiParent();
        int d = 0;
        while (p && d++ < 64) {
            if (!clsAnc && p->UhdmType() == uhdmclass_defn) clsAnc = p;
            auto it = rootView.find(p);
            if (it != rootView.end()) { root = p; break; }
            if (p->UhdmType() == uhdmdesign) break;
            p = p->VpiParent();
        }
        std::string view = root ? rootView[root] : "OTHER";
        std::string home = clsAnc ? "cls:" + nm(clsAnc) : "-";
        std::string quals;
        quals += f->VpiMethod() ? "m" : "-";
        quals += f->VpiVirtual() ? "v" : "-";
        quals += f->VpiAutomatic() ? "a" : "-";
        quals += f->VpiDPIContext() ? "d" : "-";
        std::cout << tag << "\tRETLOCAL\t" << view << "\t" << f->VpiFullName()
                  << "\t" << loc(f) << "\t" << home << "\t" << kd(f->VpiParent())
                  << "\t" << quals << "\t" << kd(vv2) << "\t" << loc(vv2) << "\t"
                  << tsShape(vv2) << "\ttsname=" << tsName(vv2) << "\tsgn=-\n";
        rows++;
    }
    std::cerr << "ROWS " << tag << " " << rows << "\n";
    return 0;
}
