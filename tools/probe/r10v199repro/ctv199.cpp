// r10v199 VERIFIER census — MEASUREMENT ONLY. uhdm-cmp is the sole judge.
// Emits one stable line per parameter cell:
//   <view>|<ownerkind>|<ownername>|<listing>|<index>|<paramname>  <ts>
// where <ts> is NO-TS or "ref->"+actual kind, plus the Rhs constant's own ts.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <map>
#include <set>
#include <string>
#include <vector>
#include <algorithm>
using namespace UHDM;

static std::string tsOf(const ref_typespec* rt) {
    if (!rt) return "NO-TS";
    const typespec* a = rt->Actual_typespec();
    return std::string("ref->") + (a ? std::string(UhdmName(a->UhdmType())) : std::string("<unbound>"));
}
static std::string ownName(const BaseClass* o) {
    std::string n(o->VpiName());
    if (n.empty()) n = std::string(o->VpiDefName());
    if (n.empty()) n = "<anon>";
    return n;
}

static std::vector<std::string> out;

static void doScope(const std::string& view, const BaseClass* owner) {
    const scope* sc = dynamic_cast<const scope*>(owner);
    if (!sc) return;
    std::string ok = std::string(UhdmName(owner->UhdmType()));
    std::string on = ownName(owner);
    char buf[1200];
    if (auto* ps = sc->Parameters()) {
        int i = 0;
        for (auto* a : *ps) {
            if (a && a->UhdmType() == uhdmparameter) {
                const parameter* p = (const parameter*)a;
                snprintf(buf, sizeof buf, "%s|%s|%s|Parameters|%d|%s\t%s\timp=%s",
                         view.c_str(), ok.c_str(), on.c_str(), i,
                         std::string(p->VpiName()).c_str(), tsOf(p->Typespec()).c_str(),
                         std::string(p->VpiImported()).c_str());
                out.push_back(buf);
            }
            i++;
        }
    }
    if (auto* pas = sc->Param_assigns()) {
        int i = 0;
        for (auto* pa : *pas) {
            if (!pa) { i++; continue; }
            const any* l = pa->Lhs();
            std::string lname = l ? std::string(l->VpiName()) : "<null>";
            std::string lts = "NO-LHS";
            std::string limp = "";
            if (l && l->UhdmType() == uhdmparameter) {
                const parameter* p = (const parameter*)l;
                lts = tsOf(p->Typespec());
                limp = std::string(p->VpiImported());
            }
            snprintf(buf, sizeof buf, "%s|%s|%s|PA.Lhs|%d|%s\t%s\timp=%s",
                     view.c_str(), ok.c_str(), on.c_str(), i, lname.c_str(),
                     lts.c_str(), limp.c_str());
            out.push_back(buf);
            const any* r = pa->Rhs();
            std::string rts = "NO-RHS";
            if (r && r->UhdmType() == uhdmconstant) {
                const constant* c = (const constant*)r;
                char b2[400];
                snprintf(b2, sizeof b2, "const/%d/sz=%d/%s", (int)c->VpiConstType(),
                         (int)c->VpiSize(), tsOf(c->Typespec()).c_str());
                rts = b2;
            } else if (r) {
                rts = std::string("other/") + std::string(UhdmName(r->UhdmType()));
            }
            snprintf(buf, sizeof buf, "%s|%s|%s|PA.Rhs|%d|%s\t%s",
                     view.c_str(), ok.c_str(), on.c_str(), i, lname.c_str(), rts.c_str());
            out.push_back(buf);
            i++;
        }
    }
}

int main(int argc, char** argv) {
    if (argc < 2) { printf("usage: ctv199 <db>\n"); return 2; }
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdmdesign) continue;
        const design* d = (const design*)o;
        if (d->AllModules())    for (auto* x : *d->AllModules())    doScope("def", x);
        if (d->TopModules())    for (auto* x : *d->TopModules())    doScope("elab", x);
        if (d->AllPackages())   for (auto* x : *d->AllPackages())   doScope("defpkg", x);
        if (d->TopPackages())   for (auto* x : *d->TopPackages())   doScope("elabpkg", x);
        if (d->AllInterfaces()) for (auto* x : *d->AllInterfaces()) doScope("defif", x);
        if (d->AllPrograms())   for (auto* x : *d->AllPrograms())   doScope("defprog", x);
    }
    std::sort(out.begin(), out.end());
    for (auto& l : out) printf("%s\n", l.c_str());
    return 0;
}
