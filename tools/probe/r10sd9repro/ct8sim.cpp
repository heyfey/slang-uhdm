// r10sd8 — THE ARTIFACT-BASED SIMULATION.  What does the head do if exactly the
// element-variable stamps golden leaves null are removed, and NOTHING else?
//
// This is the prediction made BEFORE the patch is written, from the databases
// alone, so the patch has a number to be judged against instead of being its
// own evidence.  It nulls, in OUR database only:
//
//   every class-listing ARRAY variable's ELEMENT VARIABLE's typespec whose
//   GOLDEN twin — matched by (class full name + class span, variable name,
//   typespec kind+name) — carries no vpiInstance
//
// and then re-runs the whole-design `design::Compare`, reporting the tuple
// `(r, failedLhs, failedRhs, |m_visited|)`.  It also reports the CONTROL: how
// many element-variable typespecs golden DOES stamp, which the patch must
// leave alone.
//
// GUARD: zero matched rows is a hard error.
//
// build: g++ -O2 -std=c++17 ct8sim.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct8sim
// usage: ct8sim <golden.uhdm> <ours.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static std::string span(const BaseClass* p) {
    return std::to_string(p->VpiLineNo()) + ":" + std::to_string(p->VpiColumnNo()) + "-" +
           std::to_string(p->VpiEndLineNo()) + ":" + std::to_string(p->VpiEndColumnNo());
}
static std::string ident(const BaseClass* p) {
    if (!p) return "<null>";
    std::string s = UhdmName(p->UhdmType());
    std::string nm(p->VpiName());
    if (!nm.empty()) s += "(" + nm + ")";
    return s;
}

// class full name + span :: variable name :: element typespec kind(name)
static void collect(Serializer& s, std::map<std::string, std::vector<typespec*>>& out) {
    for (const auto& [obj, id] : s.AllObjects()) {
        if (!obj || obj->UhdmType() != uhdmclass_defn) continue;
        auto* cd = (class_defn*)obj;
        if (!cd->Variables()) continue;
        std::string cn(cd->VpiFullName().empty() ? cd->VpiName() : cd->VpiFullName());
        cn += "@" + span(cd);
        for (auto* v : *cd->Variables()) {
            if (!v || v->UhdmType() != uhdmarray_var) continue;
            auto* av = (array_var*)v;
            if (!av->Variables()) continue;
            for (auto* ev : *av->Variables()) {
                if (!ev || !ev->Typespec()) continue;
                auto* t = ev->Typespec()->Actual_typespec();
                if (!t) continue;
                out[cn + " :: " + std::string(v->VpiName()) + " :: " + ident(t)].push_back(t);
            }
        }
    }
}

int main(int argc, char** argv) {
    if (argc < 3) { std::cerr << "usage: ct8sim <golden> <ours>\n"; return 2; }
    Serializer sg, so;
    auto hg = sg.Restore(std::filesystem::path(argv[1]));
    auto ho = so.Restore(std::filesystem::path(argv[2]));
    if (hg.empty() || ho.empty()) { std::cerr << "RESTORE FAILED\n"; return 3; }
    auto* dg = (design*)((uhdm_handle*)hg[0])->object;
    auto* dobj = (design*)((uhdm_handle*)ho[0])->object;

    std::map<std::string, std::vector<typespec*>> G, O;
    collect(sg, G);
    collect(so, O);
    size_t gStamped = 0, gNull = 0;
    for (auto& [k, v] : G) for (auto* t : v) (t->Instance() ? gStamped : gNull)++;
    std::cout << "golden element-var typespecs: stamped=" << gStamped << " null=" << gNull
              << "   keys golden=" << G.size() << " ours=" << O.size() << "\n";

    std::vector<std::pair<typespec*, instance*>> todo;
    size_t noTwin = 0, keepStamped = 0;
    for (auto& [k, v] : O) {
        auto it = G.find(k);
        if (it == G.end()) { for (auto* t : v) if (t->Instance()) noTwin++; continue; }
        bool gAllNull = true;
        for (auto* t : it->second) if (t->Instance()) gAllNull = false;
        for (auto* t : v) {
            if (!t->Instance()) continue;
            if (gAllNull) todo.push_back({t, (instance*)t->Instance()});
            else keepStamped++;
        }
    }
    std::cout << "TO_NULL=" << todo.size() << "  (golden stamps, ours agrees: " << keepStamped
              << ")  (ours stamped, no golden twin at key: " << noTwin << ")\n";
    for (auto& [t, in] : todo)
        std::cout << "  null " << ident(t) << "@" << span(t) << " was " << in->VpiName() << "\n";
    if (todo.empty()) { std::cerr << "REFUSING: nothing to null\n"; return 5; }

    auto probe = [&](const char* tag) {
        CompareContext c;
        int r = dg->Compare(dobj, &c);
        std::cout << tag << " r=" << r << " visited=" << c.m_visited.size()
                  << " failedLhs=" << (c.m_failedLhs ? ident(c.m_failedLhs) + "@" + span(c.m_failedLhs) : "<null>")
                  << " failedRhs=" << (c.m_failedRhs ? ident(c.m_failedRhs) + "@" + span(c.m_failedRhs) : "<null>")
                  << "\n";
    };
    probe("BASELINE ");
    for (auto& [t, in] : todo) t->Instance(nullptr);
    probe("SIMULATED");
    for (auto& [t, in] : todo) t->Instance(in);
    probe("RESTORED ");
    return 0;
}
