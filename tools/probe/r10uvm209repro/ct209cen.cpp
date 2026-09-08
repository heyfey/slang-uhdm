// r10uvm209 — ct209cen.cpp — MEASUREMENT ONLY.  The official uhdm-cmp is the
// sole judge; this tool only reports.  LHS is ALWAYS golden (Surelog), RHS is
// ALWAYS ours.
//
// THE VARIABLE-LISTING CENSUS **WITH THE OWNER-FINDER**.  One
// `<key>\t<value>\t<scope>` row per POSITION of every VARIABLE listing in a
// database — each package's, each module's DEF and ELAB view (told apart by
// the vector they came out of, `AllModules` vs `TopModules`), each class's,
// each task/function's, each named begin's.
//
//   key    the LISTING POSITION (`<listing>#<i>`), because the vector overload
//          of BaseClass::SafeCompare walks index by index.
//   value  the JUDGE-VISIBLE identity of the object at that position:
//          `<kind>|<name>|A<vpiAutomatic>|V<vpiVisibility>|C<vpiConstantVariable>`.
//          `variables::Compare` (generated) reads VpiArrayMember, VpiSigned,
//          VpiAutomatic, VpiVisibility, VpiConstantVariable; the SPAN is
//          deliberately absent — no generated Compare reads VpiLineNo.
//   scope  THE OWNER-FINDER's verdict: the SOURCE SCOPE the declaration was
//          WRITTEN in, recovered from the database by SPAN CONTAINMENT — the
//          innermost object among every package / class_defn / task / function
//          / module_inst / named begin whose file matches and whose span
//          strictly contains the variable's span.  This is what makes
//          "function-local vs package-scope" measurable ON THE GOLDEN SIDE,
//          where we have no slang symbol to ask.
//
// build: g++ -O2 -std=c++17 ct209cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct209cen
// usage: ct209cen <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <string>
#include <vector>
#include <map>

using namespace UHDM;

static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("<null>");
}

// ------------------------------------------------------------------ scopes
namespace {
struct Scope {
    const BaseClass* o;
    std::string file;
    unsigned l0, c0, l1, c1;
};
std::vector<Scope> g_scopes;

bool isScopeKind(UHDM_OBJECT_TYPE t) {
    switch (t) {
        case uhdmpackage:
        case uhdmclass_defn:
        case uhdmtask:
        case uhdmfunction:
        case uhdmmodule_inst:
        case uhdmbegin:
        case uhdmnamed_begin:


            return true;
        default:
            return false;
    }
}

// span "size" as a crude ordering: fewer lines wins; on a tie fewer columns.
long long spanSize(const Scope& s) {
    return (long long)(s.l1 - s.l0) * 100000 + (long long)s.c1 - (long long)s.c0;
}

bool contains(const Scope& s, const std::string& f, unsigned l0, unsigned c0,
              unsigned l1, unsigned c1) {
    if (s.file != f) return false;
    if (l0 < s.l0 || (l0 == s.l0 && c0 < s.c0)) return false;
    if (l1 > s.l1 || (l1 == s.l1 && c1 > s.c1)) return false;
    return true;
}

std::string ownerOf(const BaseClass* v) {
    std::string f(v->VpiFile());
    unsigned l0 = v->VpiLineNo(), c0 = (unsigned)v->VpiColumnNo();
    unsigned l1 = v->VpiEndLineNo(), c1 = (unsigned)v->VpiEndColumnNo();
    if (f.empty() || l0 == 0) return "<noloc>";
    const Scope* best = nullptr;
    for (auto& s : g_scopes) {
        if (s.o == v) continue;
        if (!contains(s, f, l0, c0, l1, c1)) continue;
        if (!best || spanSize(s) < spanSize(*best)) best = &s;
    }
    if (!best) return "<none>";
    return kindOf(best->o) + ":" + std::string(best->o->VpiName());
}
}  // namespace

// The ancestor-face path: kind:name:line of every ancestor, up to the root.
static std::string parentPath(const BaseClass* o) {
    std::string r;
    int guard = 0;
    for (const BaseClass* p = o->VpiParent(); p && guard < 24;
         p = p->VpiParent(), guard++) {
        r += "<";
        r += UhdmName(p->UhdmType());
        r += ":";
        r += p->VpiName();
        r += ":";
        r += std::to_string(p->VpiLineNo());
    }
    return r;
}

static std::string val(const BaseClass* b) {
    if (!b) return "<null>";
    const variables* v = (const variables*)b;
    char buf[64];
    snprintf(buf, sizeof buf, "|A%d|V%d|C%d", v->VpiAutomatic() ? 1 : 0,
             (int)v->VpiVisibility(), v->VpiConstantVariable() ? 1 : 0);
    return kindOf(b) + "|" + std::string(b->VpiName()) + buf;
}

static void emitList(const std::string& key, const VectorOfvariables* v) {
    if (!v) return;
    for (size_t i = 0; i < v->size(); i++) {
        const BaseClass* o = v->at(i);
        printf("%s#%zu\t%s\t%s\n", key.c_str(), i, val(o).c_str(),
               o ? ownerOf(o).c_str() : "<null>");
    }
}

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct209cen <db.uhdm>\n"); return 2; }
    Serializer s;
    auto designs = s.Restore(std::string(argv[1]));
    if (designs.empty()) { fprintf(stderr, "FATAL: no design in %s\n", argv[1]); return 3; }

    // Pass 1 — every source scope in the database, for the owner-finder.
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || !isScopeKind(o->UhdmType())) continue;
        if (o->VpiLineNo() == 0) continue;
        std::string f(o->VpiFile());
        if (f.empty()) continue;
        g_scopes.push_back({o, f, o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
                            o->VpiEndLineNo(), (unsigned)o->VpiEndColumnNo()});
    }

    // Pass 2 — the listings.
    for (auto dh : designs) {
        const design* d = (const design*)((const uhdm_handle*)dh)->object;
        auto klass = [&](const std::string& pfx, const VectorOfclass_defn* v) {
            if (!v) return;
            for (auto* c : *v)
                if (c)
                    emitList(pfx + "::" + std::string(c->VpiName()),
                             c->Variables());
        };
        auto pkgs = [&](const char* tag, const VectorOfpackage* v) {
            if (!v) return;
            for (auto* p : *v) {
                if (!p) continue;
                std::string pk = std::string("P:") + tag + ":" +
                                 std::string(p->VpiName());
                emitList(pk, p->Variables());
                klass("C:" + pk, p->Class_defns());
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
                emitList(mk, m->Variables());
                klass("C:" + mk, m->Class_defns());
            }
        };
        mods("all", d->AllModules());   // the DEF view
        mods("top", d->TopModules());   // the ELAB view
        klass("C:design", d->AllClasses());
    }

    // THE WHOLE-DATABASE VARIABLE MULTISET.  The position-keyed listings above
    // cover the vectors the judge WALKS at a scope; this pass covers EVERY
    // variable object in the database, including the ones that live inside a
    // task/function or a `begin` — which is where "a variable golden leaves
    // unmarked MUST stay unmarked" has to be scored, and which no listing key
    // can address: an anonymous `begin`'s only identity is its span, and the
    // two producers do not nest their blocks identically, so a listing key
    // built from one manufactures phantoms on the other (measured: 6858 such
    // phantom rows on SimpleUVM before this pass was replaced by the multiset).
    //
    // A MULTISET, printed one row per object and counted downstream — never a
    // dict — because keys legitimately repeat (an import copy is a second
    // object with the same face).  The span IS in the key here: it is
    // judge-invisible, but it is what tells two same-named variables in
    // different functions apart, and this census is not a judge.
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        switch (o->UhdmType()) {
            case uhdmlogic_var: case uhdmarray_var: case uhdmint_var:
            case uhdmshort_int_var: case uhdmlong_int_var: case uhdmbyte_var:
            case uhdminteger_var: case uhdmtime_var: case uhdmreal_var:
            case uhdmshort_real_var: case uhdmstring_var: case uhdmchandle_var:
            case uhdmclass_var: case uhdmenum_var: case uhdmstruct_var:
            case uhdmunion_var: case uhdmbit_var: case uhdmpacked_array_var:
            case uhdmref_var: case uhdmvar_bit:
                break;
            default:
                continue;
        }
        char sp[96];
        snprintf(sp, sizeof sp, "|%u:%u-%u:%u", o->VpiLineNo(),
                 (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
                 (unsigned)o->VpiEndColumnNo());
        printf("VAR\t%s%s\t%s\n", val(o).c_str(), sp, ownerOf(o).c_str());
    }
    return 0;
}
