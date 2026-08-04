// r10uvm15v: side-by-side listing of ONE task_func's Io_decls / Variables /
// Return with each entry's typespec kind+name, for a golden/ours pair.
//   r10uvm15v <golden.uhdm> <ours.uhdm> <func-name> [class-name]
// Names are matched inside every package (def and elab view) and, when
// class-name is given, inside that class_defn.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string tsOf(const any* o) {
    const ref_typespec* rt = nullptr;
    if (auto* v = dynamic_cast<const variables*>(o))
        rt = v->Typespec();
    else if (auto* d = dynamic_cast<const io_decl*>(o))
        rt = d->Typespec();
    if (!rt) return "<no-ref>";
    auto* at = rt->Actual_typespec();
    if (!at) return "ref<null>";
    return std::string(UhdmName(at->UhdmType())) + "'" +
           std::string(at->VpiName()) + "'@" + std::to_string(at->VpiLineNo()) +
           ":" + std::to_string(at->VpiColumnNo());
}

static void show(const char* side, const task_func* f) {
    std::cout << side << " " << f->VpiName() << "\n";
    if (auto* v = f->Io_decls())
        for (size_t i = 0; i < v->size(); i++)
            std::cout << "  " << side << " io[" << i << "] "
                      << (*v)[i]->VpiName() << " " << tsOf((*v)[i]) << "\n";
    if (auto* v = f->Variables())
        for (size_t i = 0; i < v->size(); i++)
            std::cout << "  " << side << " var[" << i << "] "
                      << (*v)[i]->VpiName() << " " << tsOf((*v)[i]) << "\n";
}

static bool endsWith(std::string_view s, const std::string& t) {
    return s.size() >= t.size() && s.substr(s.size() - t.size()) == t;
}

static const task_func* find(const design* d, const std::string& fn,
                             const std::string& cn) {
    auto scan = [&](const VectorOftask_func* v) -> const task_func* {
        if (!v) return nullptr;
        for (auto* f : *v)
            if (f->VpiName() == fn && (f->Variables() || f->Io_decls()))
                return f;
        return nullptr;
    };
    auto inInst = [&](const instance* p) -> const task_func* {
        if (cn.empty())
            if (auto* f = scan(p->Task_funcs())) return f;
        if (auto* cs = p->Class_defns())
            for (auto* c : *cs)
                if (cn.empty() || endsWith(c->VpiName(), cn))
                    if (auto* f = scan(c->Task_funcs())) return f;
        return nullptr;
    };
    for (auto* v : {d->AllPackages(), d->TopPackages()})
        if (v)
            for (auto* p : *v)
                if (auto* f = inInst(p)) return f;
    for (auto* v : {d->AllModules(), d->TopModules()})
        if (v)
            for (auto* p : *v)
                if (auto* f = inInst(p)) return f;
    return nullptr;
}

int main(int argc, char** argv) {
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    const design* da = (const design*)((uhdm_handle*)ha[0])->object;
    const design* db = (const design*)((uhdm_handle*)hb[0])->object;
    std::string fn = argv[3], cn = argc > 4 ? argv[4] : "";
    auto* fa = find(da, fn, cn);
    auto* fb = find(db, fn, cn);
    if (fa) show("L", fa); else std::cout << "L <not found>\n";
    if (fb) show("R", fb); else std::cout << "R <not found>\n";
    return 0;
}
