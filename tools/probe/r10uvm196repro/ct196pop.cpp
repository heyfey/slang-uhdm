// r10uvm196 — THE INSTANCE-POPULATION CENSUS.  MEASUREMENT ONLY;
// `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// The SimpleUVM head is `LHS: module_inst work@top / RHS: <null>`.  Per
// BaseClass.h's VECTOR SafeCompare, an LHS-only head with the RHS UNSET means a
// vector that is NON-EMPTY on golden and NULL on ours, and `m_failedLhs` is the
// OWNER, not the value (RESUME §9).  `scope::Compare` reaches `Parameters`
// eleventh and `Param_assigns` twelfth, both BEFORE `instance::Compare`'s
// `Nets`, so the head names whichever of those is first to differ.
//
// This tool prints, for every instance (module/interface/program) of both
// databases, the SIZE of each listing `scope::Compare` and `instance::Compare`
// walk, in THEIR OWN COMPARE ORDER, and then the element-by-element face lists
// of the listings asked for, so the missing members can be named and their
// HOME (the file they are written in) read off.
//
// build: g++ -O2 -std=c++17 ct196pop.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct196pop
// usage: ct196pop <golden.uhdm> <ours.uhdm> [<instance name>] [--lists]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static std::string face(const BaseClass* o) {
    if (!o) return "<null>";
    char b[1200];
    const std::string k(UhdmName(o->UhdmType()));
    const std::string n(o->VpiName());
    const std::string f(o->VpiFile());
    snprintf(b, sizeof b, "%s(%s)@%s:%u:%u-%u:%u#%u", k.c_str(), n.c_str(), f.c_str(),
             o->VpiLineNo(), (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo(), o->UhdmId());
    return b;
}
template <class T>
static size_t sz(const std::vector<T*>* v) { return v ? v->size() : 0; }
template <class T>
static const char* nul(const std::vector<T*>* v) { return v ? "" : " (NULL)"; }

// The set key deliberately DROPS the UhdmId (ids are allocation order, not
// content) and keeps kind + name + file + span — the compare-visible face.
static std::string key(const BaseClass* o) {
    if (!o) return "<null>";
    char b[1200];
    const std::string k(UhdmName(o->UhdmType()));
    const std::string n(o->VpiName());
    const std::string f(o->VpiFile());
    snprintf(b, sizeof b, "%s(%s)@%s:%u:%u-%u:%u", k.c_str(), n.c_str(), f.c_str(),
             o->VpiLineNo(), (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo());
    return b;
}
template <class T>
static void listOf(const char* tag, const std::vector<T*>* g,
                   const std::vector<T*>* o) {
    std::multiset<std::string> G, O;
    if (g) for (auto* e : *g) G.insert(key(e));
    if (o) for (auto* e : *o) O.insert(key(e));
    std::multiset<std::string> onlyG = G, onlyO = O;
    for (auto& s : O) { auto it = onlyG.find(s); if (it != onlyG.end()) onlyG.erase(it); }
    for (auto& s : G) { auto it = onlyO.find(s); if (it != onlyO.end()) onlyO.erase(it); }
    printf("  --- %s: golden %zu%s, ours %zu%s; GOLDEN-ONLY %zu, OURS-ONLY %zu ---\n",
           tag, G.size(), nul(g), O.size(), nul(o), onlyG.size(), onlyO.size());
    for (auto& s : onlyG) printf("      GOLDEN-ONLY %s\n", s.c_str());
    for (auto& s : onlyO) printf("      OURS-ONLY   %s\n", s.c_str());
}

static void sizes(const char* who, const instance* in) {
    const scope* sc = (const scope*)in;
    printf("  %s %s @%u:%u\n", who, face(in).c_str(), in->VpiLineNo(),
           (unsigned)in->VpiColumnNo());
    printf("    scope order:   Property_decls=%zu%s Sequence_decls=%zu%s "
           "Concurrent_assertions=%zu%s Named_events=%zu%s Named_event_arrays=%zu%s\n",
           sz(sc->Property_decls()), nul(sc->Property_decls()),
           sz(sc->Sequence_decls()), nul(sc->Sequence_decls()),
           sz(sc->Concurrent_assertions()), nul(sc->Concurrent_assertions()),
           sz(sc->Named_events()), nul(sc->Named_events()),
           sz(sc->Named_event_arrays()), nul(sc->Named_event_arrays()));
    printf("                   Variables=%zu%s Virtual_interface_vars=%zu%s "
           "Logic_vars=%zu%s Array_vars=%zu%s Array_var_mems=%zu%s\n",
           sz(sc->Variables()), nul(sc->Variables()),
           sz(sc->Virtual_interface_vars()), nul(sc->Virtual_interface_vars()),
           sz(sc->Logic_vars()), nul(sc->Logic_vars()),
           sz(sc->Array_vars()), nul(sc->Array_vars()),
           sz(sc->Array_var_mems()), nul(sc->Array_var_mems()));
    printf("                   >>> Parameters=%zu%s  Param_assigns=%zu%s <<<  "
           "Scopes=%zu%s Typespecs=%zu%s Instance_items=%zu%s Let_decls=%zu%s Attributes=%zu%s\n",
           sz(sc->Parameters()), nul(sc->Parameters()),
           sz(sc->Param_assigns()), nul(sc->Param_assigns()),
           sz(sc->Scopes()), nul(sc->Scopes()),
           sz(sc->Typespecs()), nul(sc->Typespecs()),
           sz(sc->Instance_items()), nul(sc->Instance_items()),
           sz(sc->Let_decls()), nul(sc->Let_decls()),
           sz(sc->Attributes()), nul(sc->Attributes()));
    printf("    instance order: Programs=%zu%s Program_arrays=%zu%s Class_defns=%zu%s "
           "Task_funcs=%zu%s Nets=%zu%s Array_nets=%zu%s Spec_params=%zu%s Assertions=%zu%s\n",
           sz(in->Programs()), nul(in->Programs()),
           sz(in->Program_arrays()), nul(in->Program_arrays()),
           sz(in->Class_defns()), nul(in->Class_defns()),
           sz(in->Task_funcs()), nul(in->Task_funcs()),
           sz(in->Nets()), nul(in->Nets()),
           sz(in->Array_nets()), nul(in->Array_nets()),
           sz(in->Spec_params()), nul(in->Spec_params()),
           sz(in->Assertions()), nul(in->Assertions()));
}

static void collect(Serializer& s, std::vector<const instance*>& out) {
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        if (o->UhdmType() == uhdmmodule_inst || o->UhdmType() == uhdminterface_inst ||
            o->UhdmType() == uhdmprogram)
            out.push_back((const instance*)o);
    }
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct196pop <golden> <ours> [name] [--lists]\n"); return 2; }
    const char* want = (argc > 3 && argv[3][0] != '-') ? argv[3] : nullptr;
    bool lists = false;
    for (int i = 3; i < argc; ++i) if (std::string(argv[i]) == "--lists") lists = true;
    Serializer sg, so;
    if (sg.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL golden\n"); return 3; }
    if (so.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL ours\n"); return 3; }
    std::vector<const instance*> G, O;
    collect(sg, G);
    collect(so, O);
    printf("instances: golden %zu, ours %zu\n", G.size(), O.size());
    for (const instance* g : G) printf("  GOLDEN INST %s nets=%zu params=%zu\n", face(g).c_str(), sz(g->Nets()), sz(((const scope*)g)->Parameters()));
    for (const instance* o : O) printf("  OURS   INST %s nets=%zu params=%zu\n", face(o).c_str(), sz(o->Nets()), sz(((const scope*)o)->Parameters()));
    for (const instance* g : G) {
        const std::string gn(g->VpiName());
        const std::string gd(g->VpiDefName());
        if (want && gn.find(want) == std::string::npos &&
            gd.find(want) == std::string::npos) continue;
        const instance* o = nullptr;
        for (const instance* c : O)
            if (c->UhdmType() == g->UhdmType() && std::string(c->VpiName()) == gn &&
                std::string(c->VpiDefName()) == gd &&
                c->VpiLineNo() == g->VpiLineNo() &&
                c->VpiColumnNo() == g->VpiColumnNo()) { o = c; break; }
        printf("\n==== INSTANCE name='%s' defname='%s' %s ====\n", gn.c_str(),
               gd.c_str(), face(g).c_str());
        sizes("GOLDEN", g);
        if (!o) { printf("  OURS: NO COUNTERPART\n"); continue; }
        sizes("OURS  ", o);
        if (!lists) continue;
        const scope* gs = (const scope*)g;
        const scope* os = (const scope*)o;
        listOf("Parameters", gs->Parameters(), os->Parameters());
        listOf("Param_assigns", gs->Param_assigns(), os->Param_assigns());
        listOf("Nets", g->Nets(), o->Nets());
        listOf("Typespecs", gs->Typespecs(), os->Typespecs());
        listOf("Variables", gs->Variables(), os->Variables());
    }
    return 0;
}
