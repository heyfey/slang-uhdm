// r11u48 / fcarg48 — THE CALL-ARGUMENT SHAPE LISTER.
//
// For every object whose VpiParent is a `func_call` / `task_call` /
// `method_func_call`, prints one line naming everything the guard could
// possibly key on:
//
//   FC ts=<act|NONE> arg=<kind> name=<n> callee=<fn> actual=<Actual_group kind>
//      chain=<parent kind chain up to the design> @line:col
//
// Every field is read straight off the restored database; nothing is
// synthesised.  Used golden-side to find WHICH call arguments Surelog types,
// and ours-side to find which we type that it does not.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string kn(const any* a) {
    return a ? std::string(UhdmName(a->UhdmType())) : std::string("<null>");
}

static std::string chain(const any* a) {
    std::string out;
    const any* p = a ? a->VpiParent() : nullptr;
    for (int i = 0; p && i < 12; i++) {
        if (!out.empty()) out += "<";
        out += kn(p);
        if (!p->VpiName().empty()) out += "(" + std::string(p->VpiName()) + ")";
        p = p->VpiParent();
    }
    return out;
}

int main(int argc, char** argv) {
    for (int i = 1; i < argc; i++) {
        Serializer s;
        std::vector<vpiHandle> h;
        try {
            h = s.Restore(std::filesystem::path(argv[i]));
        } catch (...) { std::cout << "## RESTORE-THREW\n"; continue; }
        if (h.empty()) { std::cout << "## " << argv[i] << " RESTORE-FAILED\n"; continue; }
        std::cout << "## " << argv[i] << "\n";
        for (const auto& kv : s.AllObjects()) {
            const any* a = (const any*)kv.first;
            if (!a) continue;
            const any* par = a->VpiParent();
            if (!par) continue;
            UHDM_OBJECT_TYPE pt = par->UhdmType();
            if (pt != uhdmfunc_call && pt != uhdmtask_call &&
                pt != uhdmmethod_func_call && pt != uhdmmethod_task_call)
                continue;
            const expr* e = any_cast<const expr*>(a);
            if (!e) continue;
            const ref_typespec* rt = e->Typespec();
            const typespec* act = rt ? rt->Actual_typespec() : nullptr;
            std::string actual = "-";
            if (a->UhdmType() == uhdmref_obj)
                actual = kn(((const ref_obj*)a)->Actual_group());
            std::cout << "FC ts=" << (rt ? (act ? kn(act) : std::string("<null>"))
                                         : std::string("NONE"))
                      << " arg=" << kn(a)
                      << " name=" << (a->VpiName().empty() ? std::string("-")
                                                           : std::string(a->VpiName()))
                      << " callee=" << (par->VpiName().empty() ? std::string("-")
                                                              : std::string(par->VpiName()))
                      << " actual=" << actual
                      << " chain=" << chain(a)
                      << " @" << a->VpiLineNo() << ":" << a->VpiColumnNo()
                      << "\n";
        }
    }
    return 0;
}
