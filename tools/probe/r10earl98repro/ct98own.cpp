// r10earl98 -- OWNER-FINDER for the Earlgrey/default head
//   LHS: <null>   RHS: logic_var(work@...gen_normal_fifo.fifo_wptr)
// MEASUREMENT ONLY.  ~/git-repos/UHDM/build/bin/uhdm-cmp is the sole judge;
// this tool links the SAME generated Compare and only reports.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// build: g++ -O2 -std=c++17 ct98own.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct98own
// usage: ct98own <golden.uhdm> <ours.uhdm> [--scope=<fullname>] [--name=<leaf>]
//                [--mask-scope] [--refs]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>
#include <map>

using namespace UHDM;

static std::string base(std::string_view p) {
    size_t i = p.find_last_of('/');
    return std::string(i == std::string_view::npos ? p : p.substr(i + 1));
}

static std::string fullOf(const BaseClass* o) {
    if (!o) return "";
    switch (o->UhdmType()) {
        default: break;
    }
    if (const scope* x = any_cast<const scope*>(o)) return std::string(x->VpiFullName());
    if (const variables* x = any_cast<const variables*>(o)) return std::string(x->VpiFullName());
    if (const nets* x = any_cast<const nets*>(o)) return std::string(x->VpiFullName());
    if (const ref_obj* x = any_cast<const ref_obj*>(o)) return std::string(x->VpiFullName());
    if (const ref_typespec* x = any_cast<const ref_typespec*>(o)) return std::string(x->VpiFullName());
    if (const parameter* x = any_cast<const parameter*>(o)) return std::string(x->VpiFullName());
    if (const gen_scope_array* x = any_cast<const gen_scope_array*>(o)) return std::string(x->VpiFullName());
    if (const instance_array* x = any_cast<const instance_array*>(o)) return std::string(x->VpiFullName());
    if (const hier_path* x = any_cast<const hier_path*>(o)) return std::string(x->VpiFullName());
    if (const gen_var* x = any_cast<const gen_var*>(o)) return std::string(x->VpiFullName());
    if (const primitive* x = any_cast<const primitive*>(o)) return std::string(x->VpiFullName());
    if (const type_parameter* x = any_cast<const type_parameter*>(o)) return std::string(x->VpiFullName());
    return "";
}
static std::string ident(const BaseClass* o) {
    if (!o) return "<null>";
    char b[1200];
    const std::string kind(UhdmName(o->UhdmType()));
    const std::string nm(o->VpiName());
    const std::string fn = fullOf(o);
    snprintf(b, sizeof b, "%s(%s)[%s]@%s:%u:%u-%u:%u#%u", kind.c_str(), nm.c_str(),
             fn.c_str(), base(o->VpiFile()).c_str(), o->VpiLineNo(),
             (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo(), o->UhdmId());
    return b;
}
static void chain(const char* tag, const BaseClass* o, int n = 12) {
    printf("%s", tag);
    for (int i = 0; i < n && o; i++) {
        printf("%s%s\n", i ? "      < " : "", ident(o).c_str());
        o = o->VpiParent();
    }
    if (!o) printf("      < <root>\n");
}
struct Head { const BaseClass* lhs = nullptr; const BaseClass* rhs = nullptr; int r = 0; };
static Head runCompare(const BaseClass* a, const BaseClass* b,
                       const std::vector<const BaseClass*>& mask) {
    CompareContext c;
    for (const BaseClass* m : mask) c.m_visited.insert(m);
    Head h;
    h.r = a->Compare(b, &c);
    h.lhs = c.m_failedLhs;
    h.rhs = c.m_failedRhs;
    return h;
}
template <typename V>
static void listVec(const char* tag, const char* field, const V* v) {
    if (!v) { printf("%s %-20s <nullptr>\n", tag, field); return; }
    printf("%s %-20s n=%zu\n", tag, field, v->size());
    for (auto* e : *v) printf("%s   %s\n", tag, ident(e).c_str());
}
static void listScope(const char* tag, const scope* sc) {
    const gen_scope* g = (sc && sc->UhdmType() == uhdmgen_scope) ? (const gen_scope*)sc : nullptr;
    printf("%s SCOPE %s\n", tag, ident(sc).c_str());
    listVec(tag, "Variables", sc->Variables());
    listVec(tag, "Logic_vars", sc->Logic_vars());
    listVec(tag, "Array_vars", sc->Array_vars());
    listVec(tag, "Parameters", sc->Parameters());
    listVec(tag, "Param_assigns", sc->Param_assigns());
    listVec(tag, "Typespecs", sc->Typespecs());
    listVec(tag, "Scopes", sc->Scopes());
    listVec(tag, "Instance_items", sc->Instance_items());
    listVec(tag, "Named_events", sc->Named_events());
    listVec(tag, "Concurrent_assertions", sc->Concurrent_assertions());
    if (g) {
        listVec(tag, "Nets", g->Nets());
        listVec(tag, "Array_nets", g->Array_nets());
        listVec(tag, "Process", g->Process());
        listVec(tag, "Cont_assigns", g->Cont_assigns());
        listVec(tag, "Modules", g->Modules());
        listVec(tag, "Gen_scope_arrays", g->Gen_scope_arrays());
        listVec(tag, "Task_funcs", g->Task_funcs());
        listVec(tag, "Assertions", g->Assertions());
    }
}

static const variables* findVar(Serializer& s, const std::string& full) {
    for (const auto& [obj, id] : s.AllObjects()) {
        if (!obj) continue;
        const variables* v = any_cast<const variables*>(obj);
        if (!v) continue;
        if (std::string(v->VpiFullName()) == full) return v;
    }
    return nullptr;
}
static void dumpVar(const char* tag, const variables* v) {
    printf("%s VAR %s\n", tag, ident(v).c_str());
    printf("%s   VpiArrayMember=%d VpiSigned=%d VpiAutomatic=%d VpiAllocScheme=%d\n", tag,
           (int)v->VpiArrayMember(), (int)v->VpiSigned(), (int)v->VpiAutomatic(), v->VpiAllocScheme());
    printf("%s   VpiConstantVariable=%d VpiIsRandomized=%d VpiRandType=%d VpiStructUnionMember=%d\n", tag,
           (int)v->VpiConstantVariable(), (int)v->VpiIsRandomized(), v->VpiRandType(), (int)v->VpiStructUnionMember());
    printf("%s   VpiScalar=%d VpiVisibility=%d VpiVector=%d VpiSize=%d VpiDecompile='%s'\n", tag,
           (int)v->VpiScalar(), v->VpiVisibility(), (int)v->VpiVector(), v->VpiSize(),
           std::string(v->VpiDecompile()).c_str());
    printf("%s   Typespec=%s\n", tag, ident(v->Typespec()).c_str());
    if (v->Typespec()) printf("%s     Actual=%s\n", tag, ident(v->Typespec()->Actual_typespec()).c_str());
    listVec(tag, "  Ports", v->Ports());
    listVec(tag, "  Variable_drivers", v->Variable_drivers());
    listVec(tag, "  Variable_loads", v->Variable_loads());
    listVec(tag, "  Prim_terms", v->Prim_terms());
    listVec(tag, "  Cont_assigns", v->Cont_assigns());
    printf("%s   Path_term=%s Tchk_term=%s\n", tag, ident(v->Path_term()).c_str(), ident(v->Tchk_term()).c_str());
    printf("%s   Module_inst=%s\n", tag, ident(v->Module_inst()).c_str());
    printf("%s   Instance=%s\n", tag, ident(v->Instance()).c_str());
    printf("%s   Scope=%s\n", tag, ident(v->Scope()).c_str());
    printf("%s   Expr=%s\n", tag, ident(v->Expr()).c_str());
    listVec(tag, "  Indexes", v->Indexes());
    listVec(tag, "  Attributes", v->Attributes());
    if (v->UhdmType() == uhdmlogic_var) {
        const logic_var* lv = (const logic_var*)v;
        listVec(tag, "  Ranges", lv->Ranges());
        printf("%s   Left_expr=%s Right_expr=%s\n", tag, ident(lv->Left_expr()).c_str(),
               ident(lv->Right_expr()).c_str());
        listVec(tag, "  Var_bits", lv->Var_bits());
    }
}

// For each cont_assign of a gen_scope: the Lhs (kind/name/binding) and every
// ref_obj-derived descendant with its Actual_group state.  The descendants are
// found by walking VpiParent UP from every object in the arena, so no per-kind
// child list is needed.
static void listCAs(const char* tag, Serializer& s, const scope* sc) {
    const gen_scope* g = (sc && sc->UhdmType() == uhdmgen_scope) ? (const gen_scope*)sc : nullptr;
    if (!g || !g->Cont_assigns()) { printf("%s CAS none\n", tag); return; }
    std::map<const BaseClass*, std::vector<const ref_obj*>> kids;
    for (const auto& [obj, id] : s.AllObjects()) {
        if (!obj) continue;
        const ref_obj* r = any_cast<const ref_obj*>(obj);
        if (!r) continue;
        const BaseClass* p = r->VpiParent();
        for (int d = 0; d < 12 && p; d++) {
            if (p->UhdmType() == uhdmcont_assign) { kids[p].push_back(r); break; }
            p = p->VpiParent();
        }
    }
    for (auto* ca : *g->Cont_assigns()) {
        const expr* l = ca->Lhs(); const expr* rr = ca->Rhs();
        printf("%s CA %s\n", tag, ident(ca).c_str());
        printf("%s   Lhs=%s\n", tag, ident(l).c_str());
        if (l && any_cast<const ref_obj*>(l))
            printf("%s   Lhs->Actual=%s\n", tag, ident(any_cast<const ref_obj*>(l)->Actual_group()).c_str());
        printf("%s   Rhs=%s%s\n", tag, ident(rr).c_str(),
               (rr && rr->UhdmType() == uhdmoperation)
                   ? (" op=" + std::to_string(((const operation*)rr)->VpiOpType())).c_str() : "");
        for (auto* r : kids[ca])
            printf("%s     ref %-20s %s bound=%d -> %s\n", tag,
                   std::string(UhdmName(r->UhdmType())).c_str(), ident(r).c_str(),
                   r->Actual_group() ? 1 : 0, ident(r->Actual_group()).c_str());
    }
}
static const scope* findScope(Serializer& s, const std::string& full) {
    for (const auto& [obj, id] : s.AllObjects()) {
        if (!obj) continue;
        if (obj->UhdmType() != uhdmgen_scope) continue;
        if (fullOf(obj) == full) return (const scope*)obj;
    }
    return nullptr;
}
int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct98own golden ours [opts]\n"); return 2; }
    std::string scopeFull, leaf, varFull, scanFile;
    bool maskScope = false, doRefs = false;
    for (int a = 3; a < argc; a++) {
        if (!strncmp(argv[a], "--scope=", 8)) scopeFull = argv[a] + 8;
        else if (!strncmp(argv[a], "--name=", 7)) leaf = argv[a] + 7;
        else if (!strcmp(argv[a], "--mask-scope")) maskScope = true;
        else if (!strncmp(argv[a], "--var=", 6)) varFull = argv[a] + 6;
        else if (!strncmp(argv[a], "--scan=", 7)) scanFile = argv[a] + 7;
        else if (!strcmp(argv[a], "--refs")) doRefs = true;
    }
    Serializer sg, so;
    const std::vector<vpiHandle> hg = sg.Restore(std::string(argv[1]));
    const std::vector<vpiHandle> ho = so.Restore(std::string(argv[2]));
    if (hg.empty() || ho.empty()) { fprintf(stderr, "restore failed\n"); return 3; }
    const design* dg = (const design*)((const uhdm_handle*)hg[0])->object;
    const design* dou = (const design*)((const uhdm_handle*)ho[0])->object;

    Head h0 = runCompare(dg, dou, {});
    printf("HEAD r=%d\n", h0.r);
    chain("LHS: ", h0.lhs);
    chain("RHS: ", h0.rhs);

    if (!scopeFull.empty()) {
        const scope* gs = findScope(sg, scopeFull);
        const scope* os = findScope(so, scopeFull);
        printf("SCOPE-FOUND golden=%d ours=%d\n", gs ? 1 : 0, os ? 1 : 0);
        if (gs) { listScope("GOLD", gs); listCAs("GOLD", sg, gs); }
        if (os) { listScope("OURS", os); listCAs("OURS", so, os); }
        if (gs && os) {
            Head hl = runCompare(gs, os, {});
            printf("LOCAL-SCOPE-COMPARE r=%d\n", hl.r);
            chain("  lLHS: ", hl.lhs);
            chain("  lRHS: ", hl.rhs);
        }
        if (maskScope && gs) {
            Head hm = runCompare(dg, dou, {gs});
            printf("MASK-SCOPE -> %s r=%d\n",
                   (hm.lhs == h0.lhs && hm.rhs == h0.rhs) ? "HEAD-UNCHANGED" : "HEAD-MOVED", hm.r);
            chain("  mLHS: ", hm.lhs);
            chain("  mRHS: ", hm.rhs);
        }
    }
    if (!varFull.empty()) {
        const variables* gv = findVar(sg, varFull);
        const variables* ov = findVar(so, varFull);
        printf("VAR-FOUND golden=%d ours=%d\n", gv ? 1 : 0, ov ? 1 : 0);
        if (gv) dumpVar("GOLD", gv);
        if (ov) dumpVar("OURS", ov);
        if (gv && ov) {
            Head hv = runCompare(gv, ov, {});
            printf("LOCAL-VAR-COMPARE r=%d\n", hv.r);
            chain("  vLHS: ", hv.lhs);
            chain("  vRHS: ", hv.rhs);
        }
    }
    if (!leaf.empty()) {
        for (int side = 0; side < 2; side++) {
            Serializer& s = side ? so : sg;
            const char* tag = side ? "OURS" : "GOLD";
            for (const auto& [obj, id] : s.AllObjects()) {
                if (!obj) continue;
                std::string fn = fullOf(obj); std::string nm(obj->VpiName());
                if (fn.find(leaf) == std::string::npos && nm != leaf) continue;
                printf("%s NAMED %s\n", tag, ident(obj).c_str());
                chain(std::string(std::string(tag) + "   parent ").c_str(), obj->VpiParent(), 6);
            }
        }
    }
    if (!scanFile.empty()) {
        // Every ref_obj (incl. bit_select/part_select/indexed_part_select)
        // declared in <basename>, with its BINDING state and the enclosing
        // instance path -- the golden-vs-ours binding census.
        for (int side = 0; side < 2; side++) {
            Serializer& s = side ? so : sg;
            const char* tag = side ? "OURS" : "GOLD";
            for (const auto& [obj, id] : s.AllObjects()) {
                if (!obj) continue;
                const ref_obj* r = any_cast<const ref_obj*>(obj);
                if (!r) continue;
                if (base(r->VpiFile()) != scanFile) continue;
                printf("%s SCAN %-22s %-16s %u:%u-%u:%u bound=%d full=%s\n", tag,
                       std::string(UhdmName(r->UhdmType())).c_str(),
                       std::string(r->VpiName()).c_str(), r->VpiLineNo(),
                       (unsigned)r->VpiColumnNo(), r->VpiEndLineNo(),
                       (unsigned)r->VpiEndColumnNo(), r->Actual_group() ? 1 : 0,
                       fullOf(r).c_str());
            }
        }
    }
    if (doRefs) {
        // Which objects on each side point AT a thing whose fullname contains `leaf`?
        for (int side = 0; side < 2; side++) {
            Serializer& s = side ? so : sg;
            const char* tag = side ? "OURS" : "GOLD";
            for (const auto& [obj, id] : s.AllObjects()) {
                if (!obj) continue;
                const ref_obj* r = any_cast<const ref_obj*>(obj);
                if (!r) continue;
                std::string nm(r->VpiName());
                if (!leaf.empty() && nm.find(leaf) == std::string::npos) continue;
                const any* act = r->Actual_group();
                printf("%s REF %s -> %s\n", tag, ident(r).c_str(), ident(act).c_str());
                chain(std::string(std::string(tag) + "   up ").c_str(), r->VpiParent(), 5);
            }
        }
    }
    return 0;
}
