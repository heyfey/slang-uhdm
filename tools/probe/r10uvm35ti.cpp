// r10uvm35ti — the io_decl typespec OWNERSHIP probe, pass 35.
//
// r10uvm34ti answered "what IS golden's vpiInstance here?".  Pass 35's
// question is one step earlier: WHO LISTS the object?  Surelog stamps a
// typespec's vpiInstance in `UhdmWriter::writeDataTypes` — first non-class
// writer wins (`if (!tps->Instance())`) — and qualifies its name with the
// package it is written for, so "which vpiTypedef listings contain this
// object" IS the decode of both fields.
//
// Per DISTINCT actual typespec reachable from an io_decl (optionally filtered
// by name) this prints: UHDM type, VpiName, file:line, the full identity of
// its vpiInstance, the class_defn a class_typespec targets, and EVERY listing
// (design / package def+elab / module / class) whose Typespecs() vector holds
// the object.  Plus, with --rows, the io_decl rows that reach it.
//
//   r10uvm35ti <file.uhdm> [--name SUB] [--rows]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <set>
#include <string>
#include <vector>
using namespace UHDM;

static std::string nameFilter;
static bool showRows = false;
static std::map<const BaseClass*, int> ids;
static std::vector<const typespec*> order;
static std::map<int, std::vector<std::string>> rows;
static std::map<const typespec*, std::vector<std::string>> owners;

static int idOf(const typespec* o) {
    auto it = ids.find(o);
    if (it != ids.end()) return it->second;
    int n = (int)ids.size();
    ids[o] = n;
    if ((int)order.size() <= n) order.resize(n + 1, nullptr);
    order[n] = o;
    return n;
}
static std::string tn(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("-");
}
static std::string base(std::string_view sv) {
    std::string p(sv);
    size_t s = p.find_last_of('/');
    return s == std::string::npos ? p : p.substr(s + 1);
}
static std::string instDesc(const instance* in) {
    if (!in) return "<null>";
    std::string o = tn(in) + " name='" + std::string(in->VpiName()) + "'";
    o += " full='" + std::string(in->VpiFullName()) + "'";
    o += " def='" + std::string(in->VpiDefName()) + "'";
    if (in->UhdmType() == uhdmpackage)
        o += ((const package*)in)->VpiTop() ? " TOP" : " def";
    else if (in->UhdmType() == uhdmmodule_inst)
        o += ((const module_inst*)in)->VpiTop() ? " TOP" : " def";
    o += " @" + base(in->VpiFile()) + ":" + std::to_string(in->VpiLineNo());
    return o;
}

static void note(const io_decl* io, const std::string& owner) {
    const ref_typespec* r = io->Typespec();
    if (!r) return;
    const typespec* a = r->Actual_typespec();
    if (!a) return;
    std::string nm(a->VpiName());
    if (!nameFilter.empty() && nm.find(nameFilter) == std::string::npos) return;
    rows[idOf(a)].push_back(owner + " '" + std::string(io->VpiName()) + "'");
}
static void doTfs(const char* tag, const std::string& nm,
                  const VectorOftask_func* tfs) {
    if (!tfs) return;
    for (auto* tf : *tfs) {
        if (!tf->Io_decls()) continue;
        std::string h = std::string(tag) + " " + nm + "::" + std::string(tf->VpiName());
        size_t i = 0;
        for (auto* io : *tf->Io_decls())
            note(io, h + " io[" + std::to_string(i++) + "]");
    }
}
static std::set<const class_defn*> seen;
static void doClass(const char* tag, const class_defn* c) {
    if (!c || !seen.insert(c).second) return;
    std::string nm(c->VpiFullName().empty() ? c->VpiName() : c->VpiFullName());
    doTfs(tag, nm, c->Task_funcs());
}
template <typename V>
static void doScope(const char* tag, const V* v) {
    if (!v) return;
    for (auto* p : *v) {
        std::string nm(p->VpiFullName().empty() ? p->VpiName() : p->VpiFullName());
        doTfs(tag, nm, p->Task_funcs());
        if (p->Class_defns())
            for (auto* cd : *p->Class_defns()) doClass(tag, cd);
    }
}

// ---- listing ownership -----------------------------------------------------
static void claim(const VectorOftypespec* v, const std::string& who) {
    if (!v) return;
    int i = 0;
    for (auto* t : *v) {
        if (t) owners[t].push_back(who + "[" + std::to_string(i) + "]");
        i++;
    }
}
static std::set<const class_defn*> lseen;
static void claimClass(const class_defn* c, const std::string& pfx) {
    if (!c || !lseen.insert(c).second) return;
    std::string nm = pfx + "CLS:" +
                     std::string(c->VpiFullName().empty() ? c->VpiName()
                                                          : c->VpiFullName());
    claim(c->Typespecs(), nm);
}
template <typename V>
static void claimScope(const V* v, const char* tag) {
    if (!v) return;
    for (auto* p : *v) {
        std::string nm = std::string(tag) + ":" + std::string(p->VpiName());
        claim(p->Typespecs(), nm);
        if (p->Class_defns())
            for (auto* cd : *p->Class_defns()) claimClass(cd, nm + "/");
    }
}

int main(int argc, char** argv) {
    for (int i = 2; i < argc; i++) {
        std::string a(argv[i]);
        if (a == "--rows") showRows = true;
        else if (a == "--name" && i + 1 < argc) nameFilter = argv[++i];
    }
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    claim(d->Typespecs(), "DESIGN");
    claimScope(d->AllPackages(), "DEFPKG");
    claimScope(d->TopPackages(), "ELABPKG");
    claimScope(d->AllModules(), "DEFMOD");
    claimScope(d->TopModules(), "TOPMOD");
    if (d->AllClasses())
        for (auto* c : *d->AllClasses()) claimClass(c, "ALLCLS/");

    doScope("DEFPKG", d->AllPackages());
    doScope("ELABPKG", d->TopPackages());
    doScope("DEFMOD", d->AllModules());
    doScope("TOPMOD", d->TopModules());
    if (d->AllClasses())
        for (auto* c : *d->AllClasses()) doClass("ALLCLS", c);
    for (size_t i = 0; i < order.size(); i++) {
        const typespec* a = order[i];
        if (!a || rows[(int)i].empty()) continue;
        std::cout << "TS#" << i << " uses=" << rows[(int)i].size() << " "
                  << tn(a) << " '" << a->VpiName() << "'"
                  << " @" << base(a->VpiFile()) << ":" << a->VpiLineNo() << "\n";
        std::cout << "     inst= " << instDesc(a->Instance()) << "\n";
        if (a->UhdmType() == uhdmclass_typespec) {
            const class_defn* cd = ((const class_typespec*)a)->Class_defn();
            std::cout << "     defn= "
                      << (cd ? std::string(cd->VpiFullName().empty()
                                               ? cd->VpiName()
                                               : cd->VpiFullName())
                             : std::string("<null>"))
                      << " defnid=" << (cd ? (uint64_t)cd->UhdmId() : 0)
                      << " tsid=" << (uint64_t)a->UhdmId() << "\n";
        }
        auto it = owners.find(a);
        std::cout << "     listed=" << (it == owners.end() ? 0 : it->second.size());
        if (it != owners.end())
            for (auto& w : it->second) std::cout << " " << w;
        std::cout << "\n";
        if (showRows)
            for (const auto& r : rows[(int)i]) std::cout << "     row " << r << "\n";
    }
    return 0;
}
