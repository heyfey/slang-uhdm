// r10buvm9cen — THE CENSUS INSTRUMENT for the typespec vpiInstance family.
//
// Reads ONE .uhdm database and reports, for EVERY typespec the serializer
// holds, its identity and its vpiInstance — the field typespec::Compare reads
// and the dump NEVER prints (uvm83's lesson: a leaf decompile is SILENT about
// vpiInstance, so only an object-model census can measure it).
//
//   TS <tag> <kind> <name> <l:c-l:c> id=<n> inst=<kind:name:id> instview=<ELAB|DEF|MOD|CLS|NONE|OTHER>
//      listed=<comma list of "view:pkgname"> alias=<vpiTypedefAlias target>
//      parent=<kind#id>
//
// Package listings are walked EXPLICITLY too (PKGTS rows), because a typespec
// can be in a listing and also referenced from a class member, and the cell of
// the law is "which LISTING holds it in which VIEW".
//
// usage: r10buvm9cen <file.uhdm> [tag]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdlib>
#include <iostream>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static std::string tsName(const any* t) {
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
    return std::string(UhdmName(o->UhdmType())) + ":" + tsName(o) + ":#" +
           std::to_string((long)o->UhdmId());
}
static std::string chainOf(const any* o) {
    std::string r;
    int guard = 0;
    for (const any* p = o ? o->VpiParent() : nullptr; p && guard < 24;
         p = p->VpiParent(), guard++) {
        if (!r.empty()) r += "<";
        r += std::string(UhdmName(p->UhdmType())) + "(" + tsName(p) + ")#" +
             std::to_string((long)p->UhdmId());
    }
    return r.empty() ? "-" : r;
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: r10buvm9cen <file.uhdm> [tag]\n"; return 2; }
    std::string tag = argc > 2 ? argv[2] : argv[1];
    Serializer s;
    const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
    if (restored.empty()) {
        std::cout << "RESTORE_FAIL " << tag << "\n";
        std::cout << "TOTALS " << tag << " ts=0 inst=0 noinst=0\n";
        return 3;
    }
    std::set<const any*> topPkgs, defPkgs;
    std::map<const any*, std::string> pkgView;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o || o->UhdmType() != uhdmdesign) continue;
        auto* d = (const design*)o;
        if (auto* v = d->TopPackages())
            for (auto* p : *v) { topPkgs.insert(p); pkgView[p] = "ELAB"; }
        if (auto* v = d->AllPackages())
            for (auto* p : *v) { defPkgs.insert(p); if (!pkgView.count(p)) pkgView[p] = "DEF"; }
    }
    // listing membership: which package/class/module listing holds each typespec
    std::map<const any*, std::string> listedIn;
    auto note = [&](const any* ts, const std::string& what) {
        if (!ts) return;
        auto& s2 = listedIn[ts];
        if (!s2.empty()) s2 += ",";
        s2 += what;
    };
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o) continue;
        if (auto* p = dynamic_cast<const package*>(o)) {
            std::string view = pkgView.count(p) ? pkgView[p] : "PKG?";
            if (auto* v = p->Typespecs())
                for (auto* t : *v) note(t, view + ":" + std::string(p->VpiName()));
        } else if (auto* c = dynamic_cast<const class_defn*>(o)) {
            if (auto* v = c->Typespecs())
                for (auto* t : *v) note(t, "CLS:" + std::string(c->VpiName()));
        } else if (auto* m = dynamic_cast<const module_inst*>(o)) {
            if (auto* v = m->Typespecs())
                for (auto* t : *v) note(t, "MOD:" + std::string(m->VpiName()));
        } else if (auto* i = dynamic_cast<const interface_inst*>(o)) {
            if (auto* v = i->Typespecs())
                for (auto* t : *v) note(t, "IFC:" + std::string(i->VpiName()));
        }
    }
    long nts = 0, ninst = 0, nnoinst = 0;
    std::map<std::string, long> cell;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o) continue;
        auto* ts = dynamic_cast<const typespec*>(o);
        if (!ts) continue;
        nts++;
        const instance* in = ts->Instance();
        std::string iview = "NONE";
        if (in) {
            ninst++;
            if (topPkgs.count(in)) iview = "ELABPKG";
            else if (defPkgs.count(in)) iview = "DEFPKG";
            else iview = std::string(UhdmName(in->UhdmType()));
        } else nnoinst++;
        std::string lst = listedIn.count(o) ? listedIn[o] : "-";
        cell[std::string(UhdmName(o->UhdmType())) + "|" + lst + "|" + iview]++;
        std::cout << "TS " << tag << " " << UhdmName(o->UhdmType()) << " "
                  << tsName(o) << " " << loc(o)
                  << " id=#" << (long)o->UhdmId()
                  << " inst=" << idOf(in)
                  << " instview=" << iview
                  << " listed=" << lst
                  << " defname=" << (ts->VpiDefName().empty() ? "-" : std::string(ts->VpiDefName()))
                  << " file=" << (o->VpiFile().empty() ? "-" : std::string(o->VpiFile()))
                  << " chain=" << chainOf(o) << "\n";
    }
    // explicit listing walk, in ORDER, so golden and ours join positionally too
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o) continue;
        auto* p = dynamic_cast<const package*>(o);
        if (!p) continue;
        std::string view = pkgView.count(p) ? pkgView[p] : "PKG?";
        auto* v = p->Typespecs();
        size_t i = 0;
        if (v) for (auto* t : *v) {
            const instance* in = t->Instance();
            std::cout << "PKGTS " << tag << " " << view << " pkg=" << p->VpiName()
                      << " pkgid=#" << (long)p->UhdmId()
                      << " pos=" << i++ << " kind=" << UhdmName(t->UhdmType())
                      << " name=" << tsName(t) << " " << loc(t)
                      << " id=#" << (long)t->UhdmId()
                      << " inst=" << idOf(in) << "\n";
        }
    }
    // Every ref_typespec, so "is the object the local declaration binds the
    // SAME object the class listing holds" is a MEASURED pointer fact rather
    // than an inference from equal names (sd8's lesson: a shared object and a
    // clone print identically in the dump).
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o) continue;
        auto* rt = dynamic_cast<const ref_typespec*>(o);
        if (!rt) continue;
        const typespec* act = rt->Actual_typespec();
        std::cout << "REFTS " << tag << " id=#" << (long)o->UhdmId()
                  << " name=" << (rt->VpiName().empty() ? "-" : std::string(rt->VpiName()))
                  << " " << loc(o)
                  << " act=" << idOf(act)
                  << " actinst=" << idOf(act ? act->Instance() : nullptr)
                  << " chain=" << chainOf(o) << "\n";
    }
    // Every package object, with its VIEW, so an arm with no package-scope
    // typedef still names the elaborated package id.
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o) continue;
        if (auto* p = dynamic_cast<const package*>(o))
            std::cout << "PKG " << tag << " "
                      << (pkgView.count(p) ? pkgView[p] : std::string("PKG?"))
                      << " name=" << p->VpiName() << " id=#" << (long)p->UhdmId()
                      << "\n";
    }
    for (auto& c : cell)
        std::cout << "CELL " << tag << " " << c.first << " " << c.second << "\n";
    std::cout << "TOTALS " << tag << " ts=" << nts << " inst=" << ninst
              << " noinst=" << nnoinst << "\n";
    return 0;
}
