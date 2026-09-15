// r11u48 / rbnd48 — THE RANGE-BOUND SHAPE LISTER.
//
// One line per `range` in the database, naming both bounds and everything
// a guard could key on:
//
//   RB owner=<kind>(<name>) L=<kind>/ts=<..>/dec=<..>/size=<..>/ct=<..>
//                            R=<kind>/ts=<..>/dec=<..>/size=<..>/ct=<..>
//      chain=<owner chain> @line:col
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string kn(const any* a) {
    return a ? std::string(UhdmName(a->UhdmType())) : std::string("<null>");
}
static std::string chain(const any* a) {
    std::string out;
    const any* p = a ? a->VpiParent() : nullptr;
    for (int i = 0; p && i < 10; i++) {
        if (!out.empty()) out += "<";
        out += kn(p);
        if (!p->VpiName().empty()) out += "(" + std::string(p->VpiName()) + ")";
        p = p->VpiParent();
    }
    return out;
}
static std::string side(const any* b) {
    if (!b) return "<null>";
    std::string out = kn(b);
    const expr* e = any_cast<const expr*>(b);
    const ref_typespec* rt = e ? e->Typespec() : nullptr;
    out += "/ts=";
    out += rt ? (rt->Actual_typespec() ? kn(rt->Actual_typespec()) : std::string("<null>"))
              : std::string("NONE");
    if (e) {
        out += "/dec=" + std::string(e->VpiDecompile());
        out += "/size=" + std::to_string(e->VpiSize());
    }
    if (b->UhdmType() == uhdmconstant)
        out += "/ct=" + std::to_string(((const constant*)b)->VpiConstType());
    else if (b->UhdmType() == uhdmref_obj)
        out += "/nm=" + std::string(((const ref_obj*)b)->VpiName());
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
            if (!a || a->UhdmType() != uhdmrange) continue;
            const range* r = (const range*)a;
            std::cout << "RB owner=" << kn(a->VpiParent())
                      << " L=" << side(r->Left_expr())
                      << " R=" << side(r->Right_expr())
                      << " chain=" << chain(a)
                      << " @" << a->VpiLineNo() << ":" << a->VpiColumnNo()
                      << "\n";
        }
    }
    return 0;
}
