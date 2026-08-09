// r10uvm28g — GLOBAL reference-BINDING census.  One line per reference object
// in the database (`ref_obj`, `ref_var`, `bit_select`, `indexed_part_select`,
// `var_select`, `hier_path`), keyed by the enclosing task_func's vpiFullName
// and the reference's own line:col, carrying the KIND+NAME of its
// `Actual_group`.  This is the projection § classMethodNoBind needs: the flag
// decides one pointer per reference and nothing else in the dump shows it, so
// golden-vs-ours can be diffed as text and the law's real predicate read off
// the residue instead of guessed from one repro.
//   r10uvm28g <file.uhdm>
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string d1(const BaseClass* o) {
    if (!o) return "-";
    std::string r =
        std::string(UhdmName(o->UhdmType())) + ":" + std::string(o->VpiName());
    // Whether the bound declaration carried an INITIALIZER: the candidate
    // predicate for § the class-method binding law, so it belongs in the
    // census rather than in a follow-up hand check.
    if (auto* v = any_cast<const variables*>(o)) r += v->Expr() ? "(init)" : "(bare)";
    return r;
}

// The two package views hold DIFFERENT task_func objects for the same source
// routine and Surelog binds them differently (an elaborated listing binds
// where the folded one does not).  Keying a census by name alone silently
// merges the two and makes the law unreadable, so every task_func is tagged
// with the view it was reached from.
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
        const any* act = nullptr;
        if (auto* r = any_cast<const ref_obj*>(o))
            act = r->Actual_group();
        else if (auto* r = any_cast<const ref_var*>(o))
            act = r->Actual_group();
        else if (auto* r = any_cast<const bit_select*>(o))
            act = r->Actual_group();
        else
            continue;
        // Nearest enclosing task_func (or scope) for a stable key.
        std::string owner = "<none>";
        const BaseClass* p = o->VpiParent();
        for (int i = 0; p && i < 32; ++i) {
            if (auto* tf = any_cast<const task_func*>(p)) {
                auto vi = g_view.find(tf);
                owner = (vi == g_view.end() ? std::string("?") : vi->second) + " " +
                        std::string(tf->VpiFullName());
                if (tf->VpiFullName().empty())
                    owner += std::string(tf->VpiName());
                break;
            }
            p = p->VpiParent();
        }
        // Syntactic position, as the three enclosing object kinds.  The
        // binding rule is positional, so the residue is unreadable without it.
        std::string ctx;
        const BaseClass* q = o->VpiParent();
        for (int i = 0; q && i < 3; ++i) {
            ctx += (i ? "/" : "") + std::string(UhdmName(q->UhdmType()));
            if (auto* op = any_cast<const operation*>(q))
                ctx += "#" + std::to_string(op->VpiOpType());
            q = q->VpiParent();
        }
        out.push_back(owner + " | " + std::string(UhdmName(o->UhdmType())) + " '" +
                      std::string(o->VpiName()) + "' " +
                      std::to_string(o->VpiLineNo()) + ":" +
                      std::to_string(o->VpiColumnNo()) + " -> " + d1(act) +
                      " @ " + ctx);
    }
    std::sort(out.begin(), out.end());
    for (auto& l : out) std::cout << l << "\n";
    return 0;
}
