// r10uvm31io — r10uvm30io plus TYPESPEC OBJECT IDENTITY.
//
// Pass 31's ranked #1 is the io_decl TYPESPEC family, and the pair census
// (r10uvm31pair.py) says 1197 of SeqDriver's 1411 differing formals differ in
// ONE field: the typespec's `vpiInstance`, golden `adpcm_pkg` where we say
// `uvm_pkg`.  A per-ROW census cannot tell whether that is 1197 wrong stamps
// or ONE shared object seen 1197 times, and the two have completely different
// fixes.  This probe prints a dense per-file object index for the ACTUAL
// typespec (`ts#<n>`) so the sharing graph is visible, plus the ref_typespec's
// own index (`rt#<n>`) — the ref is per-io_decl, the actual may not be.
//
//   r10uvm31io <file.uhdm>            rows, as r10uvm30io + ts#/rt#
//   r10uvm31io <file.uhdm> --objects  one line per DISTINCT actual typespec:
//                                     its index, kind, name, instance and how
//                                     many io_decls reach it
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <set>
#include <string>
#include <vector>
using namespace UHDM;

static bool objectsMode = false;
static std::map<const BaseClass*, int> ids;
static std::vector<const typespec*> order;
static std::map<int, int> uses;
static std::map<int, std::string> firstOwner;

static int idOf(const BaseClass* o) {
    if (!o) return -1;
    auto it = ids.find(o);
    if (it != ids.end()) return it->second;
    int n = (int)ids.size();
    ids[o] = n;
    return n;
}
static std::string tn(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("-");
}
static const char* dirs(int d) {
    switch (d) {
        case vpiInput: return "in";
        case vpiOutput: return "out";
        case vpiInout: return "inout";
        case vpiRef: return "ref";
        default: return "?";
    }
}
static std::string vals(const any* e) {
    if (!e) return "";
    if (const expr* x = any_cast<const expr*>(e))
        return " v=" + std::string(x->VpiValue()) + " d=" +
               std::string(x->VpiDecompile());
    return "";
}
static std::string ats(const io_decl* io, const std::string& owner) {
    const ref_typespec* r = io->Typespec();
    if (!r) return "-";
    const typespec* a = r->Actual_typespec();
    if (!a) return "ref/null";
    int ti = idOf(a);
    if ((int)order.size() <= ti) order.resize(ti + 1, nullptr);
    order[ti] = a;
    if (!uses[ti]++) firstOwner[ti] = owner;
    std::string o = tn(a) + "'" + std::string(a->VpiName()) + "'";
    if (const instance* in = a->Instance())
        o += "@" + std::string(in->VpiName());
    o += " ts#" + std::to_string(ti);
    if (io->Ranges() && !io->Ranges()->empty())
        o += " iorng=" + std::to_string(io->Ranges()->size());
    return o;
}
static void row(const std::string& h, const io_decl* io, size_t i) {
    std::string owner = h + " io[" + std::to_string(i) + "]";
    std::string t = ats(io, owner);
    if (objectsMode) return;
    std::cout << owner << " '" << io->VpiName() << "' " << dirs(io->VpiDirection())
              << " ts=" << t
              << " expr=" << (io->Expr() ? tn(io->Expr()) : "-") << " '"
              << (io->Expr() ? io->Expr()->VpiName() : "") << "'"
              << vals(io->Expr()) << "\n";
}
static void doTfs(const char* tag, const std::string& nm,
                  const VectorOftask_func* tfs) {
    if (!tfs) return;
    for (auto* tf : *tfs) {
        std::string h = std::string(tag) + " " + nm + "::" + std::string(tf->VpiName());
        if (!tf->Io_decls() || tf->Io_decls()->empty()) {
            if (!objectsMode) std::cout << h << " io[-] <none>\n";
            continue;
        }
        size_t i = 0;
        for (auto* io : *tf->Io_decls()) row(h, io, i++);
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
    for (int i = 2; i < argc; i++)
        if (std::string(argv[i]) == "--objects") objectsMode = true;
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    doScope("DEFPKG", d->AllPackages());
    doScope("ELABPKG", d->TopPackages());
    doScope("DEFMOD", d->AllModules());
    doScope("TOPMOD", d->TopModules());
    if (d->AllClasses())
        for (auto* c : *d->AllClasses()) doClass("ALLCLS", c);
    if (objectsMode)
        for (size_t i = 0; i < order.size(); i++) {
            const typespec* a = order[i];
            if (!a) continue;
            std::cout << "ts#" << i << " uses=" << uses[(int)i] << " "
                      << tn(a) << " '" << a->VpiName() << "'"
                      << " inst=" << (a->Instance() ? a->Instance()->VpiName() : "<null>")
                      << " first=" << firstOwner[(int)i] << "\n";
        }
    return 0;
}
