// r10uvm178 — THE PARAMETER-REFERENCE BIND CENSUS, PER LISTING.
// MEASUREMENT ONLY; the official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the
// sole judge of equality.  LHS is ALWAYS golden (Surelog), RHS is ALWAYS ours.
//
// Reads a database out of `Serializer::AllObjects()` (never dump TEXT) and
// prints one row per family:
//
//   PREF| every reference (ref_obj / ref_var and their IS-A selects) that sits
//        inside a PACKAGE-rooted subroutine body and whose name is the name of
//        a PARAMETER declared somewhere in the database — the family this pass
//        moves.  Keyed by
//          LST   the design-level LISTING its outermost package ancestor
//                belongs to: ALL (design::AllPackages), TOP
//                (design::TopPackages), BOTH, or NONE.  A UVM package exists
//                TWICE per database and a wildcard importer carries a CLONE of
//                the imported listing, so "the reference" is really N copies
//                and the judge pairs them listing by listing.  The listing is
//                keyed by ROLE + the package's NAME, never by a vector INDEX
//                or an object id — those are producer-private.
//          PKG   that outermost package's name (the COPY key: the home package
//                for the original, the importer for a clone)
//          HOME  the enclosing subroutine and the container it hangs off
//          REF   the reference's own kind, name and span
//        and the value BOUND=<kind:name@span> / BARE.
//
//   REF| EVERY reference object in the database with its bind state — the
//        MUST-NOT-MOVE family.
//   OBJ| one row per UHDM kind with its count — nothing may be created or
//        destroyed.
//
// The DEF/ELAB RUN is deliberately NOT part of any key (RESUME.md §9: the two
// producers label the run differently); the caller tags each run.  The
// within-database LISTING is a different thing and IS keyed, by role+name.
//
// build: g++ -O2 -std=c++17 ct178cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct178cen
// usage: ct178cen <db.uhdm> <tag> [--nospan] [--pref]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static bool NOSPAN = false;
static bool PREFONLY = false;

static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("<null>");
}
static std::string nameOf(const BaseClass* o) {
    return o ? std::string(o->VpiName()) : std::string("");
}
static std::string spanOf(const BaseClass* o) {
    if (NOSPAN || !o) return "";
    char b[64];
    snprintf(b, sizeof b, "@%u:%u", o->VpiLineNo(), (unsigned)o->VpiColumnNo());
    return b;
}
static std::string actOf(const BaseClass* a) {
    if (!a) return "BARE";
    return "BOUND=" + kindOf(a) + ":" + nameOf(a) + spanOf(a);
}
// the LAST `::`-separated component of a name
static std::string shortName(const std::string& n) {
    auto p = n.rfind("::");
    return p == std::string::npos ? n : n.substr(p + 2);
}

static std::string homeOf(const BaseClass* o) {
    std::string sub = "-", subk = "-", cont = "-", contn = "-";
    int guard = 0;
    for (const BaseClass* p = o->VpiParent(); p && guard < 128;
         p = p->VpiParent(), ++guard) {
        UHDM_OBJECT_TYPE t = p->UhdmType();
        if (sub == "-" &&
            (t == uhdmfunction || t == uhdmtask || t == uhdmprocess_stmt ||
             t == uhdminitial || t == uhdmalways)) {
            subk = UhdmName(t);
            sub = nameOf(p);
            if (sub.empty()) sub = "<anon>";
            continue;
        }
        if (t == uhdmclass_defn || t == uhdmpackage || t == uhdmmodule_inst ||
            t == uhdminterface_inst || t == uhdmdesign) {
            cont = UhdmName(t);
            contn = nameOf(p);
            if (contn.empty()) contn = "<anon>";
            break;
        }
    }
    return subk + ":" + sub + "/" + cont + ":" + contn;
}
static bool isRefKind(UHDM_OBJECT_TYPE t) {
    return t == uhdmref_obj || t == uhdmref_var || t == uhdmref_module ||
           t == uhdmbit_select || t == uhdmindexed_part_select ||
           t == uhdmpart_select || t == uhdmvar_select;
}
static const any* actualOf(const BaseClass* o) {
    if (const ref_obj* r = any_cast<const ref_obj*>(o)) return r->Actual_group();
    if (const ref_var* r = any_cast<const ref_var*>(o)) return r->Actual_group();
    if (const ref_module* r = any_cast<const ref_module*>(o))
        return r->Actual_group();
    return nullptr;
}
// the outermost PACKAGE ancestor, or null
static const BaseClass* pkgRoot(const BaseClass* o) {
    const BaseClass* pkg = nullptr;
    int guard = 0;
    for (const BaseClass* p = o; p && guard < 256; p = p->VpiParent(), ++guard)
        if (p->UhdmType() == uhdmpackage) pkg = p;
    return pkg;
}
// is the reference inside a subroutine body?
static bool inSubroutine(const BaseClass* o) {
    int guard = 0;
    for (const BaseClass* p = o->VpiParent(); p && guard < 128;
         p = p->VpiParent(), ++guard) {
        UHDM_OBJECT_TYPE t = p->UhdmType();
        if (t == uhdmfunction || t == uhdmtask) return true;
        if (t == uhdmpackage || t == uhdmmodule_inst || t == uhdmdesign)
            return false;
    }
    return false;
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: ct178cen <db.uhdm> <tag> [--nospan] [--pref]\n");
        return 2;
    }
    for (int i = 3; i < argc; i++) {
        if (!strcmp(argv[i], "--nospan")) NOSPAN = true;
        if (!strcmp(argv[i], "--pref")) PREFONLY = true;
    }
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) {
        fprintf(stderr, "FATAL: nothing restored from %s\n", argv[1]);
        return 3;
    }
    const std::string tag = argv[2];

    // --- the listing map: package object -> ALL / TOP / BOTH ---------------
    std::map<const BaseClass*, std::string> lst;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdmdesign) continue;
        const design* d = (const design*)o;
        if (auto* v = d->AllPackages())
            for (auto* p : *v) lst[(const BaseClass*)p] += "ALL";
        if (auto* v = d->TopPackages())
            for (auto* p : *v) {
                auto& e = lst[(const BaseClass*)p];
                e = (e == "ALL") ? "BOTH" : (e.empty() ? "TOP" : e);
            }
    }
    // --- the parameter NAME set (producer-independent) ---------------------
    std::set<std::string> pnames;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        if (o->UhdmType() == uhdmparameter) {
            std::string n = shortName(nameOf(o));
            if (!n.empty()) pnames.insert(n);
        } else if (o->UhdmType() == uhdmparam_assign) {
            const param_assign* pa = (const param_assign*)o;
            if (pa->Lhs()) {
                std::string n = shortName(nameOf(pa->Lhs()));
                if (!n.empty()) pnames.insert(n);
            }
        }
    }

    std::map<std::string, int> objs;
    std::vector<std::string> prefRows, refRows;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        if (!PREFONLY) objs[std::string(UhdmName(o->UhdmType()))]++;
        if (!isRefKind(o->UhdmType())) continue;
        const std::string sn = shortName(nameOf(o));
        if (const BaseClass* pkg = pkgRoot(o))
            if (inSubroutine(o) && pnames.count(sn)) {
                auto it = lst.find(pkg);
                prefRows.push_back(
                    "PREF|" + tag + "|LST=" +
                    (it == lst.end() ? std::string("NONE") : it->second) +
                    "|PKG=" + nameOf(pkg) + "|HOME=" + homeOf(o) + "|REF=" +
                    kindOf(o) + ":" + sn + spanOf(o) + "|" +
                    actOf(actualOf(o)));
            }
        if (!PREFONLY)
            refRows.push_back("REF|" + tag + "|" + kindOf(o) + ":" + nameOf(o) +
                              spanOf(o) + "|HOME=" + homeOf(o) + "|" +
                              actOf(actualOf(o)));
    }
    std::sort(prefRows.begin(), prefRows.end());
    std::sort(refRows.begin(), refRows.end());
    for (auto& r : prefRows) printf("%s\n", r.c_str());
    for (auto& r : refRows) printf("%s\n", r.c_str());
    if (!PREFONLY)
        for (auto& kv : objs)
            printf("OBJ|%s|%s|%d\n", tag.c_str(), kv.first.c_str(), kv.second);
    return 0;
}
