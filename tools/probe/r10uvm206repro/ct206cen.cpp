// r10uvm206 — ct206cen.cpp — MEASUREMENT ONLY.  The official uhdm-cmp is the
// sole judge; this tool only reports.  LHS is ALWAYS golden (Surelog), RHS is
// ALWAYS ours.
//
// THE CENSUS both of this pass's edits are scored on.  It emits one
// `<key>\t<value>` cell per position of every TYPESPEC LISTING in a database —
// the design's, each package's, each module's (def and elab told apart by the
// vector they came out of) and each class's — plus one cell per ASSOCIATIVE
// ARRAY_VAR naming the vpiInstance its INDEX and ELEMENT typespecs carry.
//
// The key is the LISTING POSITION, because the vector overload of
// BaseClass::SafeCompare walks index by index; the value is the judge-visible
// identity (kind | name | the KIND and NAME of vpiInstance | the kind of
// vpiTypedefAlias).  The SPAN is deliberately absent: no generated Compare
// reads VpiLineNo/VpiColumnNo, so a span difference is a dump residue, never a
// head.
//
// build: g++ -O2 -std=c++17 ct206cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct206cen
// usage: ct206cen <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <string>
#include <vector>

using namespace UHDM;

static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("<null>");
}

static std::string val(const typespec* t) {
    if (!t) return "<null>";
    const BaseClass* i = (const BaseClass*)t->Instance();
    std::string iv = i ? kindOf(i) + ":" + std::string(i->VpiName()) : std::string("<noinst>");
    return kindOf(t) + "|" + std::string(t->VpiName()) + "|" + iv + "|" +
           kindOf((const BaseClass*)t->Typedef_alias());
}

static void emitList(const std::string& key, const VectorOftypespec* v) {
    if (!v) return;
    for (size_t i = 0; i < v->size(); i++)
        printf("%s#%zu\t%s\n", key.c_str(), i, val(v->at(i)).c_str());
}

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct206cen <db.uhdm>\n"); return 2; }
    Serializer s;
    auto designs = s.Restore(std::string(argv[1]));
    if (designs.empty()) { fprintf(stderr, "FATAL: no design in %s\n", argv[1]); return 3; }

    for (auto dh : designs) {
        const design* d = (const design*)((const uhdm_handle*)dh)->object;
        emitList("D", d->Typespecs());
        auto pkgs = [&](const char* tag, const VectorOfpackage* v) {
            if (!v) return;
            for (auto* p : *v) {
                if (!p) continue;
                emitList(std::string("P:") + tag + ":" + std::string(p->VpiName()),
                         p->Typespecs());
                if (p->Class_defns())
                    for (auto* c : *p->Class_defns())
                        if (c)
                            emitList("C:" + std::string(p->VpiName()) + "::" +
                                         std::string(c->VpiName()),
                                     c->Typespecs());
            }
        };
        pkgs("top", d->TopPackages());
        pkgs("all", d->AllPackages());
        auto mods = [&](const char* tag, const VectorOfmodule_inst* v) {
            if (!v) return;
            for (auto* m : *v) {
                if (!m) continue;
                std::string mk = std::string("M:") + tag + ":" +
                                 std::string(m->VpiDefName()) + ":" +
                                 std::string(m->VpiName());
                emitList(mk, m->Typespecs());
                if (m->Class_defns())
                    for (auto* c : *m->Class_defns())
                        if (c)
                            emitList("C:" + mk + "::" + std::string(c->VpiName()),
                                     c->Typespecs());
            }
        };
        mods("all", d->AllModules());
        mods("top", d->TopModules());
        if (d->AllClasses())
            for (auto* c : *d->AllClasses())
                if (c) emitList("C:design::" + std::string(c->VpiName()), c->Typespecs());
    }

    // The array_var arm: the vpiInstance of the INDEX and ELEMENT typespecs of
    // every associative / queue / dynamic array_var, keyed by its owner.
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdmarray_var) continue;
        const array_var* av = (const array_var*)o;
        const BaseClass* p = (const BaseClass*)av->VpiParent();
        std::string key = "A:" + kindOf(p) + ":" +
                          (p ? std::string(p->VpiName()) : std::string()) + "." +
                          std::string(av->VpiName());
        const ref_typespec* rt = av->Typespec();
        const typespec* at = rt ? rt->Actual_typespec() : nullptr;
        if (!at || at->UhdmType() != uhdmarray_typespec) continue;
        const array_typespec* ats = (const array_typespec*)at;
        if (auto* irt = ats->Index_typespec())
            printf("%s@idx\t%s\n", key.c_str(), val(irt->Actual_typespec()).c_str());
        if (auto* ert = ats->Elem_typespec())
            printf("%s@elem\t%s\n", key.c_str(), val(ert->Actual_typespec()).c_str());
    }
    return 0;
}
