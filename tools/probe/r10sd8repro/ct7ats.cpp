// r10sd7 — EVERY `array_typespec` IN THE DATABASE, with its `vpiInstance` and
// its owner chain.  The population census that decides where the head's RHS is.
//
// The frame `ct7bt` reads is unambiguous about the ARM — `typespec::Compare`
// called as `array_typespec::Compare`'s `basetype_t::Compare`, and the only
// slot there that can hold a `package` is the singular `vpiInstance`.  So SOME
// `array_typespec` on our side carries `uvm_pkg` where golden's twin carries
// null.  Rather than trust a register read for the RHS (this pass caught gdb's
// prologue-skipped `$rsi` handing back a stale object), enumerate the whole
// population on both sides and join it by owner.
//
// GUARD: zero array_typespecs is a hard error.
//
// build: g++ -O2 -std=c++17 ct7ats.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct7ats
// usage: ct7ats <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>

using namespace UHDM;

static std::string span(const BaseClass* p) {
    if (!p) return "-";
    return std::to_string(p->VpiLineNo()) + ":" + std::to_string(p->VpiColumnNo()) + "-" +
           std::to_string(p->VpiEndLineNo()) + ":" + std::to_string(p->VpiEndColumnNo());
}
static std::string ident(const BaseClass* p) {
    if (!p) return "<null>";
    std::string s = UhdmName(p->UhdmType());
    std::string nm(p->VpiName());
    if (!nm.empty()) s += "(" + nm + ")";
    return s + "@" + span(p);
}
static std::string chain(const BaseClass* p) {
    std::string s;
    const BaseClass* q = p ? p->VpiParent() : nullptr;
    for (int i = 0; i < 4 && q; i++) {
        s += " <- " + ident(q);
        q = q->VpiParent();
    }
    return s.empty() ? " <- <no-parent>" : s;
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: ct7ats <db>\n"; return 2; }
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    if (h.empty()) { std::cerr << "RESTORE FAILED\n"; return 3; }
    size_t n = 0, nn = 0;
    std::map<std::string, int> byInst;
    for (const auto& [obj, id] : s.AllObjects()) {
        if (!obj || obj->UhdmType() != uhdmarray_typespec) continue;
        n++;
        auto* t = (const array_typespec*)obj;
        const instance* in = t->Instance();
        byInst[in ? std::string(in->VpiName()) : "<null>"]++;
        if (!in) continue;
        nn++;
        std::cout << "ATS " << ident(t) << "  inst=" << ident(in) << chain(t) << "\n";
    }
    std::cout << "[S] array_typespec objects=" << n << "  with instance=" << nn << "\n";
    for (auto& [k, v] : byInst) std::cout << "    inst=" << k << "  " << v << "\n";
    if (n == 0) { std::cerr << "REFUSING TO REPORT: empty population\n"; return 5; }
    return 0;
}
