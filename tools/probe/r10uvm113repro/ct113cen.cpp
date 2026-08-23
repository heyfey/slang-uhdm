// r10uvm113 — CALL->CALLEE BINDING CENSUS (measurement only).
//
// For every REACHABLE tf_call in a database (func_call / task_call /
// method_func_call / method_task_call) print one row:
//
//   VIEW <TAB> TOP <TAB> HOME <TAB> CALL <TAB> SPAN <TAB> KIND <TAB> CALLEE
//
//   VIEW   DEF   (the container is in design::AllPackages/AllModules/AllClasses)
//          ELAB  (the container is in design::TopPackages/TopModules)
//   TOP    the root container's VpiName (package/module/class name)
//   HOME   the compressed owner chain: the names of the enclosing
//          class_defn / function / task objects, outermost first
//   CALL   the call's VpiName
//   SPAN   file:line:col-endline:endcol   (the producer-stable identity;
//          UhdmId is NOT comparable across producers)
//   KIND   the call's UHDM kind
//   CALLEE "<null>" or  <calleeKind>|<calleeName>|<parentKind>:<parentName>
//
// Reachability: the vpiParent chain must terminate at the design object.
// (uvm97's lesson: Serializer::AllObjects also holds objects that are in NO
// dump tree and can never be reached by the judge.)
//
// build: g++ -O2 -std=c++17 ct113cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct113cen
// usage: ct113cen <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static std::string base(std::string_view p) {
    size_t i = p.find_last_of('/');
    return std::string(i == std::string_view::npos ? p : p.substr(i + 1));
}
static std::string span(const BaseClass* o) {
    char b[256];
    snprintf(b, sizeof b, "%s:%u:%u-%u:%u", base(o->VpiFile()).c_str(), o->VpiLineNo(),
             (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(), (unsigned)o->VpiEndColumnNo());
    return b;
}
static std::string calleeDesc(const BaseClass* c) {
    if (!c) return "<null>";
    const std::string k(UhdmName(c->UhdmType()));
    const std::string n(c->VpiName());
    std::string p = "<none>";
    if (const BaseClass* q = c->VpiParent())
        p = std::string(UhdmName(q->UhdmType())) + ":" + std::string(q->VpiName());
    return k + "|" + n + "|" + p + "@" + span(c);
}

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct113cen <db.uhdm>\n"); return 2; }
    Serializer s;
    auto h = s.Restore(std::string(argv[1]));
    if (h.empty()) { fprintf(stderr, "FATAL: restore failed %s\n", argv[1]); return 3; }
    const design* d = (const design*)((const uhdm_handle*)h[0])->object;

    std::set<const BaseClass*> defRoots, elabRoots;
    if (d->AllPackages()) for (auto* p : *d->AllPackages()) defRoots.insert(p);
    if (d->AllModules())  for (auto* p : *d->AllModules())  defRoots.insert(p);
    if (d->AllClasses())  for (auto* p : *d->AllClasses())  defRoots.insert(p);
    if (d->AllInterfaces())for (auto* p : *d->AllInterfaces())defRoots.insert(p);
    if (d->TopPackages()) for (auto* p : *d->TopPackages()) elabRoots.insert(p);
    if (d->TopModules())  for (auto* p : *d->TopModules())  elabRoots.insert(p);

    for (const auto& [obj, id] : s.AllObjects()) {
        UHDM_OBJECT_TYPE t = obj->UhdmType();
        if (t != uhdmfunc_call && t != uhdmtask_call &&
            t != uhdmmethod_func_call && t != uhdmmethod_task_call) continue;
        // walk to the root; record the outermost DEF/ELAB container hit
        std::vector<std::string> home;
        const BaseClass* view = nullptr; const char* viewTag = "?";
        const BaseClass* root = nullptr;
        for (const BaseClass* p = obj->VpiParent(); p; p = p->VpiParent()) {
            UHDM_OBJECT_TYPE pt = p->UhdmType();
            if (pt == uhdmclass_defn || pt == uhdmfunction || pt == uhdmtask ||
                pt == uhdmpackage || pt == uhdmmodule_inst || pt == uhdminterface_inst ||
                pt == uhdmclass_typespec)
                home.push_back(std::string(UhdmName(pt)) + ":" + std::string(p->VpiName()));
            if (defRoots.count(p)) { view = p; viewTag = "DEF"; }
            else if (elabRoots.count(p)) { view = p; viewTag = "ELAB"; }
            root = p;
        }
        if (!root || root->UhdmType() != uhdmdesign) continue;   // unreachable
        std::string homeS;
        for (size_t i = home.size(); i-- > 0;) { homeS += home[i]; if (i) homeS += "/"; }
        const BaseClass* callee = nullptr;
        if (const func_call* f = any_cast<const func_call*>((const any*)obj))
            if (t == uhdmfunc_call) callee = (const BaseClass*)f->Function();
        if (const method_func_call* f = any_cast<const method_func_call*>((const any*)obj))
            if (t == uhdmmethod_func_call) callee = (const BaseClass*)f->Function();
        if (const task_call* k = any_cast<const task_call*>((const any*)obj))
            if (t == uhdmtask_call) callee = (const BaseClass*)k->Task();
        if (const method_task_call* k = any_cast<const method_task_call*>((const any*)obj))
            if (t == uhdmmethod_task_call) callee = (const BaseClass*)k->Task();
        printf("%s\t%s\t%s\t%s\t%s\t%s\t%s\n", viewTag,
               view ? std::string(view->VpiName()).c_str() : "<noview>",
               homeS.c_str(), std::string(obj->VpiName()).c_str(), span(obj).c_str(),
               std::string(UhdmName(t)).c_str(), calleeDesc(callee).c_str());
    }
    return 0;
}
