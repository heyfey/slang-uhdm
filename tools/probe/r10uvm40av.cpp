// r10uvm40av — the ARRAY-shaped DECLARATION census.  One line per `array_var`
// / `packed_array_var` / plain variable whose name matches, projected onto
// exactly the fields `uhdm-cmp` compares plus the array_typespec's own SHAPE
// (range COUNT, index/elem typespec kinds, vpiReg kind).  Built for pass 40's
// item (1): a body-local ASSOCIATIVE array inside a class method is an
// `array_var` in golden and a `logic_var` in ours, and the fix has to
// reproduce the whole shape, not just the object kind.
//
//   r10uvm40av <file.uhdm> [--all]
// Without --all only variables under a task_func are listed (the law's reach).
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

static std::string tsKind(const any* rt) {
    if (!rt) return "-";
    auto* r = any_cast<const ref_typespec*>(rt);
    if (!r) return std::string(UhdmName(rt->UhdmType()));
    auto* a = r->Actual_typespec();
    if (!a) return "ref<null>";
    std::string s = std::string(UhdmName(a->UhdmType()));
    if (!a->VpiName().empty()) s += "'" + std::string(a->VpiName()) + "'";
    // uhdm-cmp RECURSES a typespec's Instance(), so its presence and identity
    // are compared fields — a census that omitted them would hide the half of
    // the shape that decides the verdict.
    if (auto* ts = any_cast<const typespec*>(a))
        s += ts->Instance() ? "@" + std::string(ts->Instance()->VpiName()) : "@-";
    return s;
}

int main(int argc, char** argv) {
    bool all = argc > 2 && std::string(argv[2]) == "--all";
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
        auto* v = any_cast<const variables*>(o);
        if (!v) continue;
        std::string owner = "<none>";
        for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
            if (auto* tf = any_cast<const task_func*>(p)) {
                auto vi = g_view.find(tf);
                owner = (vi == g_view.end() ? std::string("?") : vi->second) +
                        " " + std::string(tf->VpiFullName());
                break;
            }
        }
        if (!all && owner == "<none>") continue;
        std::string line = owner + " | " + std::string(UhdmName(o->UhdmType())) +
                           " '" + std::string(v->VpiName()) + "'";
        if (auto* av = any_cast<const array_var*>(o)) {
            line += " atype=" + std::to_string(av->VpiArrayType());
            line += " avranges=" +
                    std::to_string(av->Ranges() ? av->Ranges()->size() : 0);
            size_t nreg = av->Variables() ? av->Variables()->size() : 0;
            line += " reg=" + std::to_string(nreg);
            if (nreg)
                line += ":" + std::string(UhdmName((*av->Variables())[0]->UhdmType()));
            const array_typespec* ats = nullptr;
            if (auto* rt = av->Typespec())
                if (auto* rr = any_cast<const ref_typespec*>(rt))
                    ats = any_cast<const array_typespec*>(rr->Actual_typespec());
            if (!ats)
                line += " ats=<none>";
            else {
                line += " atsranges=" +
                        std::to_string(ats->Ranges() ? ats->Ranges()->size() : 0);
                line += " idx=" + tsKind(ats->Index_typespec());
                line += " elem=" + tsKind(ats->Elem_typespec());
                if (ats->Ranges())
                    for (auto* r : *ats->Ranges()) {
                        auto cc = [](const any* e) -> std::string {
                            auto* c = any_cast<const constant*>(e);
                            if (!c) return e ? std::string(UhdmName(e->UhdmType()))
                                             : std::string("-");
                            return std::string(c->VpiDecompile()) + "/ct" +
                                   std::to_string(c->VpiConstType()) + "/sz" +
                                   std::to_string(c->VpiSize());
                        };
                        // The SIZE model's `<name> - 1` operand and WHETHER
                        // IT IS BOUND: golden creates one implicit net per
                        // index NAME in the top module and binds only SOME of
                        // these references to it, so the per-view answer is
                        // the whole remaining question (r10uvm40 residue 1).
                        auto op = [](const any* e) -> std::string {
                            auto* o2 = any_cast<const operation*>(e);
                            if (!o2 || !o2->Operands() || o2->Operands()->empty())
                                return "";
                            auto* f = (*o2->Operands())[0];
                            auto* ro = any_cast<const ref_obj*>(f);
                            if (!ro) return "";
                            auto* a = ro->Actual_group();
                            return " ref'" + std::string(ro->VpiName()) + "'->" +
                                   (a ? std::string(UhdmName(a->UhdmType())) + ":" +
                                            std::string(a->VpiName())
                                      : std::string("<null>"));
                        };
                        line += " [" + cc(r->Left_expr()) + " : " +
                                cc(r->Right_expr()) + op(r->Right_expr());
                        if (auto* c = any_cast<const constant*>(r->Right_expr()))
                            line += " ts=" + tsKind(c->Typespec());
                        line += "]";
                    }
            }
        }
        else {
            line += " ts=" + tsKind(v->Typespec());
        }
        out.push_back(line);
    }
    std::sort(out.begin(), out.end());
    for (auto& l : out) std::cout << l << "\n";
    return 0;
}
