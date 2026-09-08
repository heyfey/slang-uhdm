// r10uvm206 — ct206ts.cpp — MEASUREMENT ONLY.  The official uhdm-cmp
// (~/git-repos/UHDM/build/bin/uhdm-cmp) is the sole judge; this tool only
// reports.  LHS is ALWAYS golden (Surelog), RHS is ALWAYS ours.
//
// STEP 1 of the pass: enumerate the DESIGN-LEVEL `vpiTypespec` vector
// (design->Typespecs(), the field design::Compare reads at generated/src/
// design.cpp:303, immediately after AllModules) by IDENTITY:
//
//     index | kind | VpiName | span | Instance(kind:name) | Typedef_alias face
//
// The vector overload of BaseClass::SafeCompare (~/.local/include/uhdm/
// BaseClass.h:202-224) checks the SIZE first and then walks lhs->at(i) against
// rhs->at(i) — the vector is compared STRICTLY POSITIONALLY, so this tool
// prints the INDEX with every row and can answer "same multiset, wrong order"
// as well as "missing".
//
// build: g++ -O2 -std=c++17 ct206ts.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct206ts
// usage: ct206ts <db.uhdm> [--scope=design|package|module] [--members]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstring>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static std::string span(const BaseClass* o) {
    char b[128];
    snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
             o->VpiEndLineNo(), (unsigned)o->VpiEndColumnNo());
    return b;
}

static std::string instFace(const typespec* t) {
    const BaseClass* i = (const BaseClass*)t->Instance();
    if (!i) return "<noinst>";
    return std::string(UhdmName(i->UhdmType())) + ":" + std::string(i->VpiName());
}

static std::string aliasFace(const typespec* t) {
    const BaseClass* a = (const BaseClass*)t->Typedef_alias();
    if (!a) return "-";
    return std::string(UhdmName(a->UhdmType())) + ":" + std::string(a->VpiName());
}

// judge-visible face of one typespec entry, WITHOUT the index.  VpiFile is
// NOT judge-visible (no generated Compare reads it) — it is printed under
// --file only, to IDENTIFY which source declaration minted an entry.
static bool fileToo = false;
static std::string face(const typespec* t) {
    if (!t) return "<null>";
    return std::string(UhdmName(t->UhdmType())) + "|" + std::string(t->VpiName()) +
           "|" + span(t) + "|" + instFace(t) + "|" + aliasFace(t) +
           (fileToo ? ("|" + std::string(t->VpiFile())) : std::string());
}

// --scan=<name>: every class_typespec in the arena carrying that VpiName, with
// its UhdmId, span, VpiParent face and Class_defn face — the instrument that
// answers "is the design's entry the SAME OBJECT as the class's own listing?".
static void scanNamed(Serializer& s, const std::string& want) {
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdmclass_typespec) continue;
        const class_typespec* t = (const class_typespec*)o;
        if (std::string(t->VpiName()) != want) continue;
        const BaseClass* p = (const BaseClass*)t->VpiParent();
        const BaseClass* cd = (const BaseClass*)t->Class_defn();
        printf("SCAN id:%u %s|%s|%s parent=%s|%s classdefn=%s|%s ext=%s\n",
               (unsigned)t->UhdmId(), std::string(t->VpiName()).c_str(),
               span(t).c_str(), std::string(t->VpiFile()).c_str(),
               p ? std::string(UhdmName(p->UhdmType())).c_str() : "<null>",
               p ? std::string(p->VpiName()).c_str() : "",
               cd ? std::string(UhdmName(cd->UhdmType())).c_str() : "<null>",
               cd ? std::string(cd->VpiName()).c_str() : "",
               t->Extends() ? "y" : "n");
    }
}

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct206ts <db.uhdm> [--members]\n"); return 2; }
    bool members = false;
    std::vector<std::string> scanWant;
    for (int i = 2; i < argc; i++)
    {
        if (std::string(argv[i]) == "--members") members = true;
        else if (std::string(argv[i]) == "--file") fileToo = true;
        else if (std::string(argv[i]).rfind("--scan=", 0) == 0)
            scanWant.push_back(std::string(argv[i]).substr(7));
    }

    Serializer s;
    std::vector<vpiHandle> designs = s.Restore(std::string(argv[1]));
    if (designs.empty()) { fprintf(stderr, "FATAL: no design in %s\n", argv[1]); return 3; }

    for (auto& w : scanWant) scanNamed(s, w);
    for (auto dh : designs) {
        const design* d = (const design*)((const uhdm_handle*)dh)->object;
        auto* v = d->Typespecs();
        printf("DESIGN %s TYPESPECS %zu\n", std::string(d->VpiName()).c_str(),
               v ? v->size() : (size_t)0);
        if (!v) continue;
        for (size_t i = 0; i < v->size(); i++) {
            const typespec* t = v->at(i);
            printf("TS %4zu %s\n", i, face(t).c_str());
            if (members && t && t->UhdmType() == uhdmenum_typespec) {
                auto* ec = ((const enum_typespec*)t)->Enum_consts();
                if (ec)
                    for (auto* c : *ec)
                        printf("TS %4zu   .const %s|%s\n", i,
                               std::string(c->VpiName()).c_str(), span(c).c_str());
            }
            if (members && t && t->UhdmType() == uhdmstruct_typespec) {
                auto* mm = ((const struct_typespec*)t)->Members();
                if (mm)
                    for (auto* m : *mm)
                        printf("TS %4zu   .memb %s|%s\n", i,
                               std::string(m->VpiName()).c_str(), span(m).c_str());
            }
        }
    }
    return 0;
}
