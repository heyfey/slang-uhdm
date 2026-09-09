// r10uvm227 — THE CALLEE-ROUTE READER for one database.  MEASUREMENT ONLY;
// `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance judge.
//
// For every `func_call` / `task_call` whose name matches, prints
//   CALL <ident>  holder=<outermost package/module/interface in the parent
//                        chain>  callee=<ident>  calleeOwner=<its parent
//                        package/class>
// and, so the route can be named without guessing, lists every `package`
// object with the entries of its `Task_funcs` listing that match the name and
// the VIEW it belongs to (TopPackages / AllPackages / neither).
//
// build: g++ -O2 -std=c++17 ct227route.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct227route
// usage: ct227route <db.uhdm> <name-substring>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <map>
#include <string>
#include <vector>

using namespace UHDM;

static std::string ident(const BaseClass* o) {
    if (!o) return "<null>";
    char b[600];
    const std::string kind(UhdmName(o->UhdmType()));
    const std::string nm(o->VpiName());
    snprintf(b, sizeof b, "%s(%s)@%u:%u#%u", kind.c_str(), nm.c_str(),
             o->VpiLineNo(), (unsigned)o->VpiColumnNo(), o->UhdmId());
    return b;
}
static bool isHolder(const BaseClass* o) {
    return o->UhdmType() == uhdmpackage || o->UhdmType() == uhdmmodule_inst ||
           o->UhdmType() == uhdminterface_inst || o->UhdmType() == uhdmclass_defn;
}
// The OUTERMOST holder in the parent chain, and the INNERMOST one.
static std::string holderChain(const BaseClass* o) {
    std::string in, out;
    int guard = 0;
    for (const BaseClass* p = o->VpiParent(); p && guard < 64;
         p = p->VpiParent(), ++guard)
        if (isHolder(p)) {
            if (in.empty()) in = ident(p);
            out = ident(p);
        }
    return "inner=" + (in.empty() ? std::string("-") : in) + " outer=" +
           (out.empty() ? std::string("-") : out);
}
static const design* topDesign(Serializer& s) {
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign)
            return (const design*)kv.first;
    return nullptr;
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct227route <db.uhdm> <name>\n"); return 2; }
    const std::string want(argv[2]);
    Serializer S;
    if (S.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
    printf("# ct227route MEASUREMENT-ONLY — uhdm-cmp remains the sole judge\n");
    printf("# DB %s  NAME %s\n", argv[1], argv[2]);
    const design* d = topDesign(S);
    std::map<const BaseClass*, std::string> view;
    if (d) {
        if (auto* v = d->TopPackages()) for (auto* p : *v) view[p] = "TOP";
        if (auto* v = d->AllPackages()) for (auto* p : *v) view[p] = "ALL";
        if (auto* v = d->TopModules()) for (auto* p : *v) view[p] = "TOP";
        if (auto* v = d->AllModules()) for (auto* p : *v) view[p] = "ALL";
        if (auto* v = d->AllInterfaces()) for (auto* p : *v) view[p] = "ALLIFACE";
    }
    // listings
    std::vector<std::string> lst;
    for (auto& kv : S.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdmpackage) continue;
        const package* p = (const package*)o;
        std::string row = "  PKG " + ident(p) + " view=" +
                          (view.count(p) ? view[p] : std::string("-")) +
                          " tfs=" +
                          std::to_string(p->Task_funcs() ? p->Task_funcs()->size() : 0);
        if (p->Task_funcs())
            for (auto* t : *p->Task_funcs())
                if (std::string(t->VpiName()).find(want) != std::string::npos)
                    row += "\n      lists " + ident(t);
        lst.push_back(row);
    }
    std::sort(lst.begin(), lst.end());
    printf("PACKAGE LISTINGS:\n");
    for (auto& r : lst) printf("%s\n", r.c_str());
    // the holders themselves (a module/interface may list the callee too)
    std::vector<std::string> hl;
    for (auto& kv : S.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        if (o->UhdmType() != uhdmmodule_inst && o->UhdmType() != uhdminterface_inst)
            continue;
        const instance* inst = (const instance*)o;
        std::string row = "  HOLDER " + ident(o) + " view=" +
                          (view.count(o) ? view[o] : std::string("-")) + " tfs=" +
                          std::to_string(inst->Task_funcs() ? inst->Task_funcs()->size() : 0);
        if (inst->Task_funcs())
            for (auto* t : *inst->Task_funcs())
                if (std::string(t->VpiName()).find(want) != std::string::npos)
                    row += "\n      lists " + ident(t);
        hl.push_back(row);
    }
    std::sort(hl.begin(), hl.end());
    printf("HOLDER LISTINGS:\n");
    for (auto& r : hl) printf("%s\n", r.c_str());
    // the calls
    std::vector<std::string> rows;
    for (auto& kv : S.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        const tf_call* tc = any_cast<const tf_call*>(o);
        if (!tc) continue;
        if (std::string(o->VpiName()).find(want) == std::string::npos) continue;
        const BaseClass* callee = nullptr;
        if (const func_call* fc = any_cast<const func_call*>(o)) callee = fc->Function();
        else if (const task_call* tk = any_cast<const task_call*>(o)) callee = tk->Task();
        const BaseClass* cown = callee ? callee->VpiParent() : nullptr;
        char b[1600];
        snprintf(b, sizeof b, "  CALL %-34s %s\n        callee=%s  calleeOwner=%s view=%s",
                 ident(o).c_str(), holderChain(o).c_str(), ident(callee).c_str(),
                 ident(cown).c_str(),
                 (cown && view.count(cown)) ? view[cown].c_str() : "-");
        rows.push_back(b);
    }
    std::sort(rows.begin(), rows.end());
    printf("CALLS (%zu):\n", rows.size());
    for (auto& r : rows) printf("%s\n", r.c_str());
    return 0;
}
