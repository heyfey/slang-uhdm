// r10uvm156 — CLASS_TYPESPEC CENSUS.  MEASUREMENT ONLY: the official
// ~/git-repos/UHDM/build/bin/uhdm-cmp is the sole judge; this tool only reads
// databases and reports.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// For every `class_typespec` in a database it prints ONE line:
//   CT <file>:<l>:<c>-<el>:<ec> name=<vpiName|-> inst=<kind:name|-> defn=<name|->
//      hold=<holderkind>(<holdername>) via=<relation> chain=<kinds...>
// The HOLDER is found by a reverse scan: every object X and relation T with
// X.GetByVpiType(T) == the typespec (singular) or containing it (vector).
// `ref_typespec` holders are RESOLVED one more step to the ref's own
// VpiParent, which is the object that actually declares the type.
//
// build: g++ -O2 -std=c++17 ct156cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct156cen
// usage: ct156cen <db.uhdm> [--tag=T] [--at=L[:C]] [--name=N] [--all]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <map>
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
static std::string nm(const BaseClass* o) {
    if (!o) return "-";
    std::string n(o->VpiName());
    return n.empty() ? std::string("-") : n;
}
// HOME COMPONENT, as Surelog's class REGISTRY keys it (Design::addClassDefinition):
//   a class in a package        -> "<pkg>"
//   a class in a module/program -> that module/program
//   a class in an INTERFACE, or at $unit, or nowhere -> "TOP"
// (measured: sl.log of g156_a_mech prints `Compile class "work@ifCls156"` and
//  `work@unitCls156` with NO interface / $unit qualifier, while a module class
//  is `work@mod156::modCls156` and a package class is `ph156::sib156`.)
static std::string homeOf(const BaseClass* o) {
    for (int i = 0; i < 64 && o; ++i) {
        switch (o->UhdmType()) {
            case uhdmpackage: {
                std::string n(o->VpiName());
                return n.empty() ? ("pkg#" + std::to_string(o->UhdmId()))
                                 : ("pkg:" + n);
            }
            case uhdmmodule_inst:
            case uhdmprogram:
                // OBJECT IDENTITY, not a name: our module_inst carries an EMPTY
                // VpiName, and keying two different homes on the same empty
                // string made the predictor call a same-module return "far".
                return "inst#" + std::to_string(o->UhdmId());
            case uhdminterface_inst:
            case uhdmdesign:
                return "TOP";
            default: break;
        }
        o = o->VpiParent();
    }
    return "TOP";
}
int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct156cen <db.uhdm> [--tag=T]\n"); return 2; }
    std::string tag = "DB";
    unsigned atL = 0, atC = 0; bool useAt = false;
    std::string wantName; bool useName = false;
    for (int a = 2; a < argc; a++) {
        if (!strncmp(argv[a], "--tag=", 6)) tag = argv[a] + 6;
        else if (!strncmp(argv[a], "--at=", 5)) { sscanf(argv[a] + 5, "%u:%u", &atL, &atC); useAt = true; }
        else if (!strncmp(argv[a], "--name=", 7)) { wantName = argv[a] + 7; useName = true; }
    }
    Serializer s;
    const std::vector<vpiHandle> h = s.Restore(std::string(argv[1]));
    if (h.empty()) { fprintf(stderr, "restore failed %s\n", argv[1]); return 3; }

    // Collect the class_typespecs first.
    std::vector<const class_typespec*> cts;
    for (const auto& [obj, i] : s.AllObjects())
        if (obj && obj->UhdmType() == uhdmclass_typespec)
            cts.push_back((const class_typespec*)obj);

    // Reverse index: typespec -> (holder, relation, kind-of-edge)
    struct Hold { const BaseClass* h; int t; bool vec; };
    std::map<const BaseClass*, std::vector<Hold>> rev;
    // relations a typespec can hang off.  vpiActual=700 covers ref_typespec.
    static const int rels[] = {700, 1, 2, 3};  // 700 vpiActual; the rest unused placeholders
    for (const auto& [obj, i] : s.AllObjects()) {
        if (!obj) continue;
        auto [single, vt, vec] = obj->GetByVpiType(700);
        if (single) {
            auto it = rev.find(single);
            (void)it;
            rev[single].push_back({obj, 700, false});
        }
        if (vec)
            for (auto* e : *vec) if (e) rev[e].push_back({obj, 700, true});
    }
    (void)rels;

    for (const class_typespec* c : cts) {
        if (useAt && (c->VpiLineNo() != atL || (atC && c->VpiColumnNo() != atC))) continue;
        if (useName && std::string(c->VpiName()) != wantName) continue;
        const BaseClass* holder = nullptr; const char* via = "-";
        auto it = rev.find(c);
        if (it != rev.end() && !it->second.empty()) {
            const BaseClass* r = it->second[0].h;
            if (r && r->UhdmType() == uhdmref_typespec) {
                holder = r->VpiParent(); via = "ref_typespec";
            } else { holder = r; via = "direct"; }
        }
        // Is the holder the RETURN variable of its enclosing function?
        const char* role = "other";
        if (holder) {
            const BaseClass* pp = holder->VpiParent();
            if (pp && pp->UhdmType() == uhdmfunction) {
                const function* fn = (const function*)pp;
                role = (fn->Return() == holder) ? "return" : "tflocal";
            } else if (holder->UhdmType() == uhdmio_decl) role = "formal";
            else if (pp && pp->UhdmType() == uhdmclass_defn) role = "prop";
            else if (pp && pp->UhdmType() == uhdmpackage) role = "pkgvar";
        }
        const std::string dHome = c->Class_defn() ? homeOf(c->Class_defn()) : std::string("?");
        const std::string oHome = holder ? homeOf(holder) : std::string("?");
        std::string chain;
        for (const BaseClass* p = holder ? holder->VpiParent() : nullptr;
             p && chain.size() < 300; p = p->VpiParent()) {
            chain += kindOf(p);
            std::string n = nm(p);
            if (n != "-") { chain += "("; chain += n; chain += ")"; }
            chain += "<";
        }
        const instance* in = c->Instance();
        printf("%s CT %s:%u:%u-%u:%u role=%s name=%s inst=%s%s%s defn=%s hold=%s(%s)@%u:%u via=%s dhome=%s ohome=%s chain=%s\n",
               tag.c_str(), base(c->VpiFile()).c_str(), c->VpiLineNo(),
               (unsigned)c->VpiColumnNo(), c->VpiEndLineNo(), (unsigned)c->VpiEndColumnNo(),
               role, nm(c).c_str(),
               in ? kindOf(in).c_str() : "-", in ? ":" : "", in ? nm(in).c_str() : "",
               c->Class_defn() ? nm(c->Class_defn()).c_str() : "-",
               kindOf(holder).c_str(), nm(holder).c_str(),
               holder ? holder->VpiLineNo() : 0u,
               holder ? (unsigned)holder->VpiColumnNo() : 0u,
               via, dHome.c_str(), oHome.c_str(), chain.c_str());
    }
    printf("%s TOTAL class_typespec=%zu\n", tag.c_str(), cts.size());
    return 0;
}
