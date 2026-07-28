// r9tdchain: typespec ALIAS-CHAIN / INSTANCE census for a top module's
// Parameters and Param_assigns.
//
// uhdm-dump abbreviates an already-visited object, so a typespec's
// Typedef_alias chain and its vpiInstance are largely INVISIBLE in a dump
// diff — while typespec::Compare recurses through both.  Two databases can
// dump byte-identically and still fail uhdm-cmp on nothing but these links
// (that is exactly what ParamSubstituteComplex did).
//
// Each typespec/ref gets a stable per-FILE id, printed in traversal order, so
// running the probe on golden and ours and diffing the two outputs shows
// object SHARING (the same id revisited) as well as the field values.  What
// the ParamSubstituteComplex decode turned on:
//   * `inst=work@top#2def` vs `#3TOP` — a def-view vs elaborated module_inst.
//     module_inst::Compare tests vpiTopModule and the def view holds
//     Gen_stmts where the elaborated one holds Gen_scope_arrays, so the two
//     are never interchangeable.
//   * `(REVISIT)` on an alias target where the golden has a fresh node —
//     Surelog COPIES a named typedef typespec at every reference; the copies
//     differ from the shared object in vpiInstance alone.
//
// Build (paths as installed on this machine):
//   g++ -std=c++20 -O0 tools/probe/r9tdchain.cpp -o /tmp/r9tdchain \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Run:  /tmp/r9tdchain <file.uhdm>   (once per side, then diff)
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <map>
#include <string>
#include <vector>
using namespace UHDM;

static std::map<const BaseClass*, int> ids;
static int nextId = 1;
static int id(const BaseClass* o) {
    if (!o) return 0;
    auto it = ids.find(o);
    if (it != ids.end()) return it->second;
    ids[o] = nextId;
    return nextId++;
}

static void walkTs(const typespec* t, const std::string& path, int depth);

static void walkRef(const ref_typespec* rt, const std::string& path, int depth) {
    std::string ind(depth * 2, ' ');
    if (!rt) { std::cout << ind << path << " ref=<null>\n"; return; }
    std::cout << ind << path << " ref#" << id(rt) << " full='"
              << rt->VpiFullName() << "' name='" << rt->VpiName() << "'\n";
    walkTs(rt->Actual_typespec(), path + ".act", depth + 1);
}

static void walkTs(const typespec* t, const std::string& path, int depth) {
    std::string ind(depth * 2, ' ');
    if (!t) { std::cout << ind << path << " ts=<null>\n"; return; }
    bool seen = ids.count(t);
    int i = id(t);
    std::cout << ind << path << " ts#" << i << " " << UhdmName(t->UhdmType())
              << " '" << t->VpiName() << "' inst="
              << (t->Instance() ? std::string(t->Instance()->VpiFullName()) +
                                      "#" + std::to_string(id(t->Instance())) +
                                      (t->Instance()->UhdmType() ==
                                               uhdmmodule_inst &&
                                       ((const module_inst*)t->Instance())
                                           ->VpiTopModule()
                                           ? "TOP"
                                           : "def")
                                : std::string("-"))
              << " @" << t->VpiLineNo() << ":" << t->VpiColumnNo()
              << (seen ? "  (REVISIT)" : "") << "\n";
    if (seen || depth > 12) return;
    if (t->Typedef_alias())
        walkRef(t->Typedef_alias(), path + ".alias", depth + 1);
    if (t->UhdmType() == uhdmstruct_typespec) {
        auto* st = (const struct_typespec*)t;
        if (st->Members())
            for (auto* m : *st->Members()) {
                std::cout << ind << "  MEMBER '" << m->VpiName() << "' #"
                          << id(m) << "\n";
                walkRef(m->Typespec(), path + "." + std::string(m->VpiName()),
                        depth + 2);
            }
    }
    if (t->UhdmType() == uhdmpacked_array_typespec) {
        auto* pt = (const packed_array_typespec*)t;
        walkRef(pt->Elem_typespec(), path + ".elem", depth + 1);
    }
}

static void doMod(const module_inst* m, const char* tag) {
    std::cout << "=== " << tag << " " << m->VpiFullName() << "\n";
    if (m->Parameters()) {
        int i = 0;
        for (auto* p : *m->Parameters()) {
            std::string nm = std::string(p->VpiName());
            std::cout << "-- Parameters[" << i << "] " << nm << " #" << id(p)
                      << "\n";
            if (p->UhdmType() == uhdmparameter)
                walkRef(((const parameter*)p)->Typespec(),
                        "P" + std::to_string(i), 1);
            i++;
        }
    }
    if (m->Param_assigns()) {
        int i = 0;
        for (auto* pa : *m->Param_assigns()) {
            auto* lhs = pa->Lhs();
            std::cout << "-- Param_assigns[" << i << "] lhs='"
                      << (lhs ? std::string(lhs->VpiName()) : "-") << "' #"
                      << id(pa) << "\n";
            auto* rhs = pa->Rhs();
            if (rhs) {
                std::cout << "   rhs " << UhdmName(rhs->UhdmType()) << " #"
                          << id(rhs) << "\n";
                const ref_typespec* rrt = nullptr;
                if (auto* e = any_cast<const expr*>(rhs)) rrt = e->Typespec();
                walkRef(rrt, "A" + std::to_string(i) + ".rhs", 2);
                if (rhs->UhdmType() == uhdmoperation)
                    if (auto* ops = ((const operation*)rhs)->Operands()) {
                        int k = 0;
                        for (auto* o : *ops) {
                            std::string p = "A" + std::to_string(i) + ".op[" +
                                            std::to_string(k++) + "]";
                            std::cout << "   " << p << " "
                                      << UhdmName(o->UhdmType()) << " #"
                                      << id(o) << "\n";
                            if (auto* oe = any_cast<const expr*>(o))
                                walkRef(oe->Typespec(), p, 3);
                        }
                    }
            }
            i++;
        }
    }
}

int main(int argc, char** argv) {
    if (argc != 2) { std::cerr << "usage: chain <file.uhdm>\n"; return 2; }
    Serializer s;
    auto h = s.Restore(std::string(argv[1]));
    if (h.empty()) { std::cerr << "load failed\n"; return 2; }
    auto* d = (const design*)((const uhdm_handle*)h[0])->object;
    if (d->AllModules())
        for (auto* m : *d->AllModules())
            std::cout << "ALLMOD #" << id(m) << " " << m->VpiFullName()
                      << " top=" << (int)m->VpiTopModule() << "\n";
    if (d->TopModules())
        for (auto* m : *d->TopModules())
            std::cout << "TOPMOD #" << id(m) << " " << m->VpiFullName()
                      << " top=" << (int)m->VpiTopModule() << "\n";
    if (d->TopModules())
        for (auto* m : *d->TopModules()) doMod(m, "TOP");
    return 0;
}
