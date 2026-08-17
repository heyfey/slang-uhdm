// r10buvm10cen — THE CENSUS INSTRUMENT for the Typedef_alias (per-use typedef
// COPY) family.
//
// MEASUREMENT ONLY.  The official uhdm-cmp is the acceptance judge.
// LHS is ALWAYS golden; this tool reads ONE database and tags its rows, so the
// caller joins golden rows against ours.
//
// Reads a .uhdm and prints, out of Serializer::AllObjects() (never dump TEXT):
//
//   TS  <tag> kind=<k> name=<n> loc=<l:c-l:c> id=<#> alias=<target> aliasfull=<s>
//       inst=<kind:name:#id> instview=<ELAB|DEF|OTHER|NONE> nref=<k>
//       parent=<kind#id> range=<n>
//   REF <tag> ts=<kind:name:#id> hasalias=<0|1> ref=<#id> reffull=<s>
//       chain=<parent chain>            (one row per ref_typespec Actual edge)
//   LST <tag> view=<ELAB|DEF|CLS|MOD> owner=<name> ts=<kind:name:#id> hasalias=<0|1>
//
// usage: r10buvm10cen <file.uhdm> [tag]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdlib>
#include <iostream>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static std::string nm(const any* t) {
    if (!t) return "-";
    std::string n(t->VpiName());
    return n.empty() ? "<anon>" : n;
}
static std::string loc(const any* o) {
    if (!o) return "-";
    return std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo()) +
           "-" + std::to_string(o->VpiEndLineNo()) + ":" +
           std::to_string(o->VpiEndColumnNo());
}
static std::string idOf(const any* o) {
    if (!o) return "-";
    return std::string(UhdmName(o->UhdmType())) + ":" + nm(o) + ":#" +
           std::to_string((long)o->UhdmId());
}
static std::string chainOf(const any* o) {
    std::string r;
    int guard = 0;
    for (const any* p = o ? o->VpiParent() : nullptr; p && guard < 20;
         p = p->VpiParent(), guard++) {
        if (!r.empty()) r += "<";
        r += std::string(UhdmName(p->UhdmType())) + "(" + nm(p) + ")#" +
             std::to_string((long)p->UhdmId());
    }
    return r.empty() ? "-" : r;
}
// Typedef_alias lives on `typespec`, so one cast reaches every kind.
static ref_typespec* aliasOf(const any* o) {
    if (!o) return nullptr;
    auto* t = dynamic_cast<const typespec*>(o);
    return t ? (ref_typespec*)t->Typedef_alias() : nullptr;
}
static const instance* instOf(const any* o) {
    auto* t = dynamic_cast<const typespec*>(o);
    return t ? t->Instance() : nullptr;
}
static int nRanges(const any* o) {
    if (!o) return -1;
    switch (o->UhdmType()) {
        case uhdmlogic_typespec: {
            auto* r = ((const logic_typespec*)o)->Ranges();
            return r ? (int)r->size() : 0;
        }
        case uhdmbit_typespec: {
            auto* r = ((const bit_typespec*)o)->Ranges();
            return r ? (int)r->size() : 0;
        }
        default:
            return -1;
    }
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: r10buvm10cen <file.uhdm> [tag]\n"; return 2; }
    std::string tag = argc > 2 ? argv[2] : "T";
    Serializer s;
    const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
    if (restored.empty()) { std::cout << "RESTORE_FAIL " << tag << "\n"; return 3; }

    std::map<const any*, std::string> pkgView;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o || o->UhdmType() != uhdmdesign) continue;
        auto* d = (const design*)o;
        if (auto* v = d->TopPackages()) for (auto* p : *v) pkgView[p] = "ELAB";
        if (auto* v = d->AllPackages()) for (auto* p : *v) if (!pkgView.count(p)) pkgView[p] = "DEF";
    }

    // listing membership
    std::vector<std::string> lst;
    std::map<const any*, int> refCount;
    auto noteListing = [&](const any* owner, const char* view,
                           const VectorOftypespec* v) {
        if (!v) return;
        for (auto* t : *v) {
            if (!t) continue;
            lst.push_back(std::string("LST ") + tag + " view=" + view +
                          " owner=" + nm(owner) + " ts=" + idOf(t) +
                          " hasalias=" + (aliasOf(t) ? "1" : "0"));
        }
    };
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o) continue;
        switch (o->UhdmType()) {
            case uhdmpackage: {
                auto* p = (const package*)o;
                auto it = pkgView.find(o);
                noteListing(o, it == pkgView.end() ? "PKG?" : it->second.c_str(),
                            p->Typespecs());
                break;
            }
            case uhdmclass_defn:
                noteListing(o, "CLS", ((const class_defn*)o)->Typespecs());
                break;
            case uhdmmodule_inst:
                noteListing(o, "MOD", ((const module_inst*)o)->Typespecs());
                break;
            default: break;
        }
    }
    // ref edges
    std::vector<std::string> refs;
    for (auto& kv : s.AllObjects()) {
        auto* rt = dynamic_cast<const ref_typespec*>(kv.first);
        if (!rt) continue;
        auto* at = rt->Actual_typespec();
        if (!at) continue;
        refCount[at]++;
        refs.push_back(std::string("REF ") + tag + " ts=" + idOf(at) +
                       " hasalias=" + (aliasOf(at) ? "1" : "0") +
                       " ref=#" + std::to_string((long)rt->UhdmId()) +
                       " reffull=" + (rt->VpiFullName().empty() ? "-" : std::string(rt->VpiFullName())) +
                       " chain=" + chainOf(rt));
    }
    // typespec rows
    long nts = 0, nal = 0;
    for (auto& kv : s.AllObjects()) {
        auto* t = dynamic_cast<const typespec*>(kv.first);
        if (!t) continue;
        nts++;
        auto* al = aliasOf(t);
        if (al) nal++;
        const instance* in = instOf(t);
        std::string iv = "NONE";
        if (in) {
            auto it = pkgView.find(in);
            iv = it == pkgView.end() ? "OTHER" : it->second;
        }
        std::cout << "TS " << tag << " kind=" << UhdmName(t->UhdmType())
                  << " name=" << nm(t) << " loc=" << loc(t)
                  << " id=#" << (long)t->UhdmId()
                  << " alias=" << (al ? idOf(al->Actual_typespec()) : "-")
                  << " aliasfull=" << (al ? (al->VpiFullName().empty() ? "-" : std::string(al->VpiFullName())) : "-")
                  << " inst=" << idOf(in) << " instview=" << iv
                  << " nref=" << refCount[t]
                  << " parent=" << (t->VpiParent() ? idOf(t->VpiParent()) : "-")
                  << " range=" << nRanges(t) << "\n";
    }
    for (auto& r : refs) std::cout << r << "\n";
    for (auto& r : lst) std::cout << r << "\n";
    std::cout << "TOTALS " << tag << " ts=" << nts << " alias=" << nal
              << " refs=" << refs.size() << " listings=" << lst.size() << "\n";
    return 0;
}
