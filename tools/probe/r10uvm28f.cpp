// r10uvm28f — REF-BINDING census for one task_func subtree.  For every object
// whose vpiParent chain reaches the named task_func, print kind/name/line:col
// plus the binding pointers uhdm-cmp actually descends into for a reference
// (`ref_obj::Actual_group`, `ref_var::Actual_group`, `ref_typespec::
// Actual_typespec`).  Golden and ours diff line for line, which is how a
// "golden had nullptr here" report from r10uvm28e is turned into a rule.
//   r10uvm28f <file.uhdm> <className|-> <tfName>
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

static std::string d1(const BaseClass* o) {
    if (!o) return "<null>";
    return std::string(UhdmName(o->UhdmType())) + " '" + std::string(o->VpiName()) +
           "' " + std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo());
}

static const task_func* findTf(const design* d, const std::string& cls,
                               const std::string& tf) {
    for (auto* v : {d->AllPackages(), d->TopPackages()}) {
        if (!v) continue;
        for (auto* p : *v) {
            if (cls == "-" && p->Task_funcs())
                for (auto* f : *p->Task_funcs())
                    if (std::string(f->VpiName()) == tf) return f;
            if (!p->Class_defns()) continue;
            for (auto* c : *p->Class_defns()) {
                if (cls != "-" && std::string(c->VpiName()) != cls) continue;
                if (!c->Task_funcs()) continue;
                for (auto* f : *c->Task_funcs())
                    if (std::string(f->VpiName()) == tf) return f;
            }
        }
    }
    return nullptr;
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    const task_func* tf = findTf(d, argv[2], argv[3]);
    if (!tf) {
        std::cerr << "not found\n";
        return 1;
    }
    std::vector<std::pair<int, const BaseClass*>> objs;
    for (auto& [o, id] : s.AllObjects()) {
        int n = 0;
        const BaseClass* p = o;
        while (p && n < 64) {
            if (p == tf) {
                objs.push_back({n, o});
                break;
            }
            p = p->VpiParent();
            ++n;
        }
    }
    std::sort(objs.begin(), objs.end(), [](auto& a, auto& b) {
        const BaseClass *x = a.second, *y = b.second;
        if (x->VpiLineNo() != y->VpiLineNo()) return x->VpiLineNo() < y->VpiLineNo();
        if (x->VpiColumnNo() != y->VpiColumnNo())
            return x->VpiColumnNo() < y->VpiColumnNo();
        if (x->UhdmType() != y->UhdmType()) return x->UhdmType() < y->UhdmType();
        return x->VpiName() < y->VpiName();
    });
    for (auto& [n, o] : objs) {
        std::cout << "d" << n << " " << d1(o);
        if (auto* r = any_cast<const ref_obj*>(o))
            std::cout << " actual=" << d1(r->Actual_group());
        if (auto* r = any_cast<const ref_var*>(o))
            std::cout << " actual=" << d1(r->Actual_group());
        if (auto* r = any_cast<const ref_typespec*>(o))
            std::cout << " actualts=" << d1(r->Actual_typespec());
        std::cout << "\n";
    }
    return 0;
}
