// r10scr7f: WHOLE-FILE census of func_call / task_call arguments and whether
// each argument carries a formal-typespec stamp (expr->Typespec()).  One line
// per (enclosing-instance, call site, arg index) so golden and ours diff to
// exactly the sites whose stamping disagrees — the way to find the
// discriminator for "which call args does Surelog stamp".
//   r10scr7f <file.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string encl(const BaseClass* o) {
    for (const BaseClass* p = o; p; p = p->VpiParent()) {
        if (p->UhdmType() == uhdmmodule_inst)
            return std::string(((const module_inst*)p)->VpiFullName());
        if (p->UhdmType() == uhdmpackage)
            return std::string(((const package*)p)->VpiFullName());
    }
    return "<noscope>";
}

// Which container kinds the call sits under, nearest-first — the context that
// the emitter's stamping rules key on (cont_assign vs process vs param init).
static std::string ctx(const BaseClass* o) {
    std::string r;
    int n = 0;
    for (const BaseClass* p = o->VpiParent(); p && n < 8; p = p->VpiParent(), n++) {
        if (p->UhdmType() == uhdmmodule_inst || p->UhdmType() == uhdmpackage) break;
        r += std::string(UhdmName(p->UhdmType())) + "<";
    }
    return r;
}

int main(int argc, char** argv) {
    if (argc < 2) return 1;
    Serializer s;
    s.Restore(std::filesystem::path(argv[1]));
    auto all = s.AllObjects();
    std::vector<std::string> rows;
    for (auto& [o, id] : all) {
        if (!o) continue;
        if (o->UhdmType() != uhdmfunc_call && o->UhdmType() != uhdmtask_call)
            continue;
        auto* c = (const tf_call*)o;
        auto* args = c->Tf_call_args();
        if (!args) continue;
        for (size_t i = 0; i < args->size(); i++) {
            const any* a = (*args)[i];
            std::string ts = "-";
            if (auto* e = dynamic_cast<const expr*>(a)) {
                if (auto* rt = e->Typespec())
                    ts = rt->Actual_typespec()
                             ? std::string(UhdmName(
                                   rt->Actual_typespec()->UhdmType())) +
                                   "(" +
                                   std::string(rt->Actual_typespec()->VpiName()) +
                                   ")"
                             : std::string("UNBOUND");
            }
            rows.push_back(encl(o) + " | " + std::string(c->VpiName()) + "@" +
                           std::to_string(o->VpiLineNo()) + ":" +
                           std::to_string(o->VpiColumnNo()) + " | arg" +
                           std::to_string(i) + " " +
                           std::string(UhdmName(a->UhdmType())) + "(" +
                           std::string(a->VpiName()) + ") | ctx=" + ctx(o) +
                           " | " + ts);
        }
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) std::cout << r << "\n";
    return 0;
}
