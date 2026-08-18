// r10earl60 — PARAM_ASSIGN RHS-TYPESPEC census, taken on the DATABASES, not on
// the dump.
//
// MEASUREMENT ONLY.  The official `uhdm-cmp` remains the sole judge.
//
// WHY NOT THE DUMP.  `uhdm-dump` keeps a GLOBAL visited set, so an object that
// is SHARED between two instances prints its children exactly ONCE; a dump-text
// census of "what does this instance's param_assign RHS point at" therefore
// reads NOTHING for every instance after the first, and the reading is
// ASYMMETRIC precisely when one side shares and the other clones -- which is
// the question being asked.  Walking the database has no such blind spot.
//
// Emits one TAB-separated row per param_assign, keyed on a position that exists
// identically on both sides (scope full name, Lhs name, param_assign span) with
// the Rhs's typespec target as the payload:
//
//   SECTION  scope  lhsName  paSpan  rhsKind  refTsName  actualKind  actualSpan
//            actualInstanceKind  actualInstanceName  aliasKind
//
// GUARDS:
//   * VpiFullName is used only in the KEY (positions), never in the payload:
//     our fullname prefixes differ from golden's in places and Compare does not
//     read fullname.  Spans are payload-only for the SAME reason in reverse --
//     Compare does not read spans either, so a span difference in the payload is
//     reported but never called a defect on its own.
//   * every scope is visited ONCE (an `emitted` set), so a shared sub-object
//     cannot inflate a count.
//   * DEF (AllModules/AllPackages) and ELAB (TopModules/TopPackages) are
//     SEPARATE sections; folding them together is how a def/elab leak hides.
//
// build: g++ -O2 -std=c++17 pacensus60.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o pacensus60
// usage: pacensus60 <db.uhdm> <out.tsv>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static std::string base(std::string_view p) {
    size_t i = p.find_last_of('/');
    return std::string(i == std::string_view::npos ? p : p.substr(i + 1));
}
static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("-");
}
static std::string spanOf(const BaseClass* o) {
    if (!o) return "-";
    char b[256];
    snprintf(b, sizeof b, "%s:%u:%u-%u:%u", base(o->VpiFile()).c_str(), o->VpiLineNo(),
             (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(), (unsigned)o->VpiEndColumnNo());
    return b;
}
// VpiFullName lives on `scope`/`expr`/etc, not on BaseClass; read it through the
// public introspection so no cast table is needed and a kind without a fullname
// simply reports "-".
static std::string fullOf(const BaseClass* o) {
    if (!o) return "-";
    auto v = o->GetVpiPropertyValue(vpiFullName);
    if (const char* const* p = std::get_if<const char*>(&v))
        if (*p) return std::string(*p);
    return std::string(o->VpiName());
}
static std::string nameOf(const BaseClass* o) {
    return o ? std::string(o->VpiName()) : std::string("-");
}

static FILE* out;
static std::set<const BaseClass*> emitted;

static void rowsFor(const char* sec, const std::string& scope,
                    const VectorOfany* pas) {
    if (!pas) return;
    for (const any* a : *pas) {
        const param_assign* pa = any_cast<const param_assign*>(a);
        if (!pa) continue;
        const any* rhs = pa->Rhs();
        const any* lhs = pa->Lhs();
        const ref_typespec* rt = nullptr;
        if (const expr* e = any_cast<const expr*>(rhs)) rt = e->Typespec();
        const typespec* act = rt ? rt->Actual_typespec() : nullptr;
        const instance* ai = act ? act->Instance() : nullptr;
        fprintf(out, "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", sec,
                scope.c_str(), nameOf(lhs).c_str(), spanOf(pa).c_str(),
                kindOf(rhs).c_str(), rt ? nameOf(rt).c_str() : "-",
                kindOf(act).c_str(), spanOf(act).c_str(), kindOf(ai).c_str(),
                nameOf(ai).c_str(),
                act ? kindOf(act->Typedef_alias()).c_str() : "-");
    }
}

static void walkScope(const char* sec, const scope* sc);

// EVERY param_assign in the database, found by enumerating the serializer's own
// object table instead of walking the instance tree.  The tree walk below MISSED
// scopes (its first reading of Earlgrey_0_1 found 13 791 param_assigns and 31
// disagreeing cells, while the whole-dump diff showed the patch moving 307), and
// a census that cannot see a cell cannot attribute it.  The key is the Lhs
// parameter's VpiFullName plus the param_assign span: a POSITION that exists
// identically on both sides.  ALLOBJ rows are the arbiter; the tree rows are
// kept only because they carry the enclosing-scope name.
static void allObjRows(Serializer& s) {
    for (const auto& [obj, id] : s.AllObjects()) {
        const param_assign* pa = any_cast<const param_assign*>((const any*)obj);
        if (!pa) continue;
        const any* rhs = pa->Rhs();
        const any* lhs = pa->Lhs();
        const ref_typespec* rt = nullptr;
        if (const expr* e = any_cast<const expr*>(rhs)) rt = e->Typespec();
        const typespec* act = rt ? rt->Actual_typespec() : nullptr;
        const instance* ai = act ? act->Instance() : nullptr;
        fprintf(out, "ALLOBJ\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
                lhs ? fullOf(lhs).c_str() : "-",
                nameOf(lhs).c_str(), spanOf(pa).c_str(), kindOf(rhs).c_str(),
                rt ? nameOf(rt).c_str() : "-", kindOf(act).c_str(),
                spanOf(act).c_str(), kindOf(ai).c_str(), nameOf(ai).c_str(),
                act ? kindOf(act->Typedef_alias()).c_str() : "-");
    }
}

static void walkInst(const char* sec, const instance* in) {
    if (!in || !emitted.insert(in).second) return;
    std::string full(in->VpiFullName());
    rowsFor(sec, full, (const VectorOfany*)in->Param_assigns());
    if (const module_inst* m = any_cast<const module_inst*>(in)) {
        if (m->Modules()) for (auto* c : *m->Modules()) walkInst(sec, c);
        if (m->Interfaces()) for (auto* c : *m->Interfaces()) walkInst(sec, c);
        if (m->Gen_scope_arrays())
            for (auto* g : *m->Gen_scope_arrays())
                if (g->Gen_scopes()) for (auto* s : *g->Gen_scopes()) walkScope(sec, s);
    }
    if (const interface_inst* f = any_cast<const interface_inst*>(in)) {
        if (f->Gen_scope_arrays())
            for (auto* g : *f->Gen_scope_arrays())
                if (g->Gen_scopes()) for (auto* s : *g->Gen_scopes()) walkScope(sec, s);
    }
}
static void walkScope(const char* sec, const scope* sc) {
    if (!sc || !emitted.insert(sc).second) return;
    std::string full(sc->VpiFullName());
    rowsFor(sec, full, (const VectorOfany*)sc->Param_assigns());
    if (const gen_scope* g = any_cast<const gen_scope*>(sc)) {
        if (g->Modules()) for (auto* c : *g->Modules()) walkInst(sec, c);
        if (g->Gen_scope_arrays())
            for (auto* ga : *g->Gen_scope_arrays())
                if (ga->Gen_scopes()) for (auto* s : *ga->Gen_scopes()) walkScope(sec, s);
    }
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: pacensus60 <db> <out.tsv>\n"); return 2; }
    Serializer s;
    auto h = s.Restore(std::string(argv[1]));
    if (h.empty()) { fprintf(stderr, "FATAL: restore failed\n"); return 3; }
    const design* d = (const design*)((const uhdm_handle*)h[0])->object;
    out = fopen(argv[2], "w");
    if (!out) { fprintf(stderr, "FATAL: cannot write %s\n", argv[2]); return 3; }
    if (d->AllPackages()) for (auto* p : *d->AllPackages()) walkInst("DEF", p);
    if (d->AllModules())  for (auto* m : *d->AllModules())  walkInst("DEF", m);
    emitted.clear();
    if (d->TopPackages()) for (auto* p : *d->TopPackages()) walkInst("ELAB", p);
    if (d->TopModules())  for (auto* m : *d->TopModules())  walkInst("ELAB", m);
    allObjRows(s);
    fclose(out);
    fprintf(stderr, "%s: done\n", argv[1]);
    return 0;
}
