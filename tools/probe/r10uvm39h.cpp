// r10uvm39h — THE `method_func_call`-under-`hier_path` ARGUMENT projection.
//
// Pass 38 handed over ONE position family that is the head of all three
// binding metrics at once (BINDTOTAL's misses, BINDTOTAL's extras and 180 of
// SeqDriver's 755 BINDWRONG rows): in that position golden sometimes binds the
// ARGUMENT to the object the hier_path's BASE element resolves to, sometimes to
// the argument's own declaration, and sometimes to nothing.  r10uvm28g cannot
// answer the question because it never records the BASE — and "does the
// argument bind to the base" is an IDENTITY question about a sibling object, so
// no KIND:NAME census can answer it either.
//
// One line per reference that is an ARGUMENT of a method_func_call sitting
// inside a hier_path:
//
//   <view> <owner-task_func> | <argkind> '<name>' L:C | act=<kind:name>
//     base='<name>' baseact=<kind:name> SAME=<0|1> SELF=<0|1> nelem=<n>
//     argpos=<i> ctx=<enclosing kinds>
//
// SAME=1 means the argument's vpiActual is the SAME OBJECT as the base
// element's vpiActual (pointer identity, not name equality — a body can hold
// two objects of the same name).  SELF=1 means it is an object whose name is
// the argument's own name.
//
//   r10uvm39h <file.uhdm>
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <map>
#include <string>
#include <vector>
using namespace UHDM;

static const any* actOf(const BaseClass* e) {
    if (!e) return nullptr;
    switch (e->UhdmType()) {
        case uhdmref_obj: return ((const ref_obj*)e)->Actual_group();
        case uhdmref_var: return ((const ref_var*)e)->Actual_group();
        case uhdmbit_select: return ((const bit_select*)e)->Actual_group();
        default: return nullptr;
    }
}
static bool isRef(const BaseClass* e) {
    auto t = e->UhdmType();
    return t == uhdmref_obj || t == uhdmref_var || t == uhdmbit_select;
}
static std::string d1(const BaseClass* o) {
    if (!o) return "-";
    return std::string(UhdmName(o->UhdmType())) + ":" + std::string(o->VpiName());
}

// Same view tagging as r10uvm28g (TRAP: "BOTH" means two DIFFERENT tags merged,
// not "both package views" — see pass 38's README).
static std::map<const BaseClass*, std::string> g_view;
template <typename S>
static void tagScope(const S* p, const char* tag) {
    auto add = [&](const BaseClass* o) {
        auto it = g_view.find(o);
        if (it == g_view.end())
            g_view[o] = tag;
        else if (it->second != tag)
            it->second = "BOTH";
    };
    if (p->Task_funcs())
        for (auto* f : *p->Task_funcs()) add(f);
    if (p->Class_defns())
        for (auto* c : *p->Class_defns())
            if (c->Task_funcs())
                for (auto* f : *c->Task_funcs()) add(f);
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    if (d->AllPackages())
        for (auto* p : *d->AllPackages()) tagScope(p, "DEFPKG");
    if (d->TopPackages())
        for (auto* p : *d->TopPackages()) tagScope(p, "ELABPKG");
    if (d->AllModules())
        for (auto* m : *d->AllModules()) tagScope(m, "DEFMOD");
    if (d->TopModules())
        for (auto* m : *d->TopModules()) tagScope(m, "ELABMOD");

    std::vector<std::string> out;
    for (auto& [o, id] : s.AllObjects()) {
        auto* hp = any_cast<const hier_path*>(o);
        if (!hp || !hp->Path_elems() || hp->Path_elems()->empty()) continue;
        auto& el = *hp->Path_elems();
        const any* bact = actOf(el[0]);
        std::string bname(el[0]->VpiName());
        // Owner task_func, for a key comparable with r10uvm28g's.
        std::string owner = "<none>";
        const BaseClass* p = hp->VpiParent();
        for (int i = 0; p && i < 32; ++i) {
            if (auto* tf = any_cast<const task_func*>(p)) {
                auto vi = g_view.find(tf);
                owner = (vi == g_view.end() ? std::string("?") : vi->second) +
                        " " + std::string(tf->VpiFullName());
                if (tf->VpiFullName().empty()) owner += std::string(tf->VpiName());
                break;
            }
            p = p->VpiParent();
        }
        // The whole element list, kinds and names: "does the argument take the
        // base" turned out to depend on the PATH LENGTH and on whether an
        // element carries an INDEX, so the shape has to be in the row.
        std::string elemDesc;
        for (size_t k = 0; k < el.size(); k++) {
            if (k) elemDesc += ",";
            elemDesc += std::string(UhdmName(el[k]->UhdmType())) + ":" +
                        std::string(el[k]->VpiName());
        }
        std::string ctx;
        {
            const BaseClass* q = hp->VpiParent();
            for (int i = 0; q && i < 2; ++i) {
                ctx += (i ? "/" : "") + std::string(UhdmName(q->UhdmType()));
                q = q->VpiParent();
            }
        }
        for (size_t ei = 0; ei < el.size(); ei++) {
            auto* mfc = any_cast<const method_func_call*>(el[ei]);
            if (!mfc || !mfc->Tf_call_args()) continue;
            auto& args = *mfc->Tf_call_args();
            for (size_t ai = 0; ai < args.size(); ai++) {
                auto* a = args[ai];
                if (!a || !isRef(a)) continue;
                const any* aact = actOf(a);
                bool same = aact && aact == bact;
                bool self = aact && aact->VpiName() == a->VpiName();
                out.push_back(
                    owner + " | " + std::string(UhdmName(a->UhdmType())) + " '" +
                    std::string(a->VpiName()) + "' " +
                    std::to_string(a->VpiLineNo()) + ":" +
                    std::to_string(a->VpiColumnNo()) + " act=" + d1(aact) +
                    " base='" + bname + "' baseact=" + d1(bact) +
                    " SAME=" + (same ? "1" : "0") + " SELF=" + (self ? "1" : "0") +
                    " nelem=" + std::to_string(el.size()) + " argpos=" +
                    std::to_string(ai) + " nargs=" + std::to_string(args.size()) +
                    " mfc='" + std::string(mfc->VpiName()) + "' ei=" +
                    std::to_string(ei) + " elems=" + elemDesc + " ctx=" + ctx);
            }
        }
    }
    std::sort(out.begin(), out.end());
    for (auto& l : out) std::cout << l << "\n";
    return 0;
}
