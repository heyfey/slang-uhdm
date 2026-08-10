// r10uvm34ti — the io_decl TYPESPEC IDENTITY probe, pass 34.
//
// Pass 33's ranked #1 is `this_type`: 58 rows, 42% of the residue, and its
// biggest family (`ts/OTHER`, 11 rows on Scoreboard and 11 on SimpleUVM)
// prints an IDENTICAL kind+name+inst under r10uvm30io, because that probe
// renders a null Instance() and an Instance() whose VpiName is EMPTY the same
// way (one omits `@`, the other prints a bare `@`).  So the first question —
// "what IS golden's instance here?" — cannot be asked with the pass-30..33
// probes at all.
//
// This one prints, per DISTINCT actual typespec reachable from an io_decl and
// matching a name filter, the FULL identity of the object and of its
// vpiInstance: UHDM type, VpiName, VpiFullName, VpiDefName, vpiTop, and the
// file:line of both.  Plus the io_decl rows that reach it.
//
//   r10uvm34ti <file.uhdm> [--name SUB] [--rows]
//
// --name SUB   only typespecs whose VpiName contains SUB (default: all)
// --rows       also list every io_decl row that reaches each object
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
static std::string loc(const BaseClass* o) {
    if (!o) return "";
    return std::string(o->VpiFile()) + ":" + std::to_string(o->VpiLineNo());
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

int main(int argc, char** argv) {
    for (int i = 2; i < argc; i++) {
        std::string a(argv[i]);
        if (a == "--rows") showRows = true;
        else if (a == "--name" && i + 1 < argc) nameFilter = argv[++i];
    }
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
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
        if (showRows)
            for (const auto& r : rows[(int)i]) std::cout << "     row " << r << "\n";
    }
    return 0;
}
