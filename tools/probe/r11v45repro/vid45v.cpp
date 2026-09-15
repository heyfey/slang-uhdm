// r11v45/vid — INDEPENDENT type-parameter actual-typespec identity census.
// Written from scratch by the verifier; it does NOT reuse tpid45.
//
// Two sections per database:
//   TP  <listing> <owner>.<name> tp#<id> rt#<id> ts#<id> kind loc ranges name
//   TS  ts#<id> kind loc ranges name parentkind parentname   (the SHAPE LISTER)
//
// Pointer ids are interned in first-seen order and are meaningful only WITHIN
// one database — which is the point: "does golden share?" is a question about
// golden's own pointers.  Coverage is wider than tpid45's: interfaces,
// interface children, packages, class defns, and the module def/elab listings.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <functional>
#include <iostream>
#include <map>
#include <set>
#include <string>
#include <vector>
using namespace UHDM;

static std::map<const void*, int> ids;
static int idOf(const void* p) {
    if (!p) return -1;
    auto it = ids.find(p);
    if (it != ids.end()) return it->second;
    int n = (int)ids.size() + 1;
    ids[p] = n;
    return n;
}
static std::string loc(const any* a) {
    if (!a) return "-";
    char b[64];
    snprintf(b, sizeof b, "%u:%u..%u:%u", a->VpiLineNo(), a->VpiColumnNo(),
             a->VpiEndLineNo(), a->VpiEndColumnNo());
    return b;
}
static int nRanges(const typespec* ts) {
    if (!ts) return -1;
    switch (ts->UhdmType()) {
        case uhdmlogic_typespec: { auto* v = ((logic_typespec*)ts)->Ranges(); return v ? (int)v->size() : -1; }
        case uhdmbit_typespec: { auto* v = ((bit_typespec*)ts)->Ranges(); return v ? (int)v->size() : -1; }
        case uhdmpacked_array_typespec: { auto* v = ((packed_array_typespec*)ts)->Ranges(); return v ? (int)v->size() : -1; }
        case uhdmarray_typespec: { auto* v = ((array_typespec*)ts)->Ranges(); return v ? (int)v->size() : -1; }
        case uhdminteger_typespec: case uhdmint_typespec: case uhdmreal_typespec:
        case uhdmstruct_typespec: case uhdmenum_typespec: return -2;
        default: return -2;
    }
}
static std::set<const void*> tsSeen;
static std::vector<const typespec*> tsOrder;
static void noteTs(const typespec* ts) {
    if (!ts) return;
    if (tsSeen.insert((const void*)ts).second) tsOrder.push_back(ts);
}

static void doParams(const char* listing, const std::string& owner, VectorOfany* params) {
    if (!params) return;
    for (any* p : *params) {
        if (p->UhdmType() != uhdmtype_parameter) continue;
        auto* tp = (type_parameter*)p;
        ref_typespec* rt = tp->Typespec();
        const typespec* act = rt ? rt->Actual_typespec() : nullptr;
        noteTs(act);
        printf("TP %-12s %s.%s tp#%d rt#%d ts#%d kind=%s loc=%s ranges=%d tsname=%s\n",
               listing, owner.c_str(), std::string(tp->VpiName()).c_str(),
               idOf(tp), idOf(rt), idOf(act),
               act ? UhdmName(act->UhdmType()).c_str() : "<null>", loc(act).c_str(),
               nRanges(act), act ? std::string(act->VpiName()).c_str() : "-");
    }
}

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: vid <file.uhdm>\n"); return 2; }
    Serializer s;
    std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
    if (restored.empty()) { fprintf(stderr, "FATAL: restore empty\n"); return 3; }
    for (vpiHandle h : restored) {
        auto* d = (design*)((uhdm_handle*)h)->object;
        std::function<void(const char*, module_inst*)> recM =
            [&](const char* tag, module_inst* m) {
                doParams(tag, std::string(m->VpiFullName()), m->Parameters());
                if (auto* kids = m->Modules()) for (module_inst* k : *kids) recM(tag, k);
                if (auto* ifs = m->Interfaces()) for (interface_inst* i : *ifs)
                    doParams(tag, std::string(i->VpiFullName()), i->Parameters());
            };
        if (auto* v = d->AllModules()) for (module_inst* m : *v) recM("AllModules", m);
        if (auto* v = d->TopModules()) for (module_inst* m : *v) recM("TopModules", m);
        if (auto* v = d->AllInterfaces()) for (interface_inst* i : *v)
            doParams("AllInterfaces", std::string(i->VpiFullName()), i->Parameters());
        if (auto* v = d->AllPackages()) for (package* p : *v)
            doParams("AllPackages", std::string(p->VpiFullName()), p->Parameters());
        if (auto* v = d->TopPackages()) for (package* p : *v)
            doParams("TopPackages", std::string(p->VpiFullName()), p->Parameters());
        if (auto* v = d->AllClasses()) for (class_defn* c : *v)
            doParams("AllClasses", std::string(c->VpiFullName()), c->Parameters());
    }
    // SHAPE LISTER over every typespec any TP reached, in first-seen order.
    for (const typespec* ts : tsOrder) {
        const any* par = ts->VpiParent();
        printf("TS ts#%d kind=%s loc=%s ranges=%d name=%s parent=%s(%s)\n",
               idOf(ts), UhdmName(ts->UhdmType()).c_str(), loc(ts).c_str(), nRanges(ts),
               std::string(ts->VpiName()).c_str(),
               par ? UhdmName(par->UhdmType()).c_str() : "<null>",
               par ? std::string(par->VpiName()).c_str() : "-");
    }
    return 0;
}
