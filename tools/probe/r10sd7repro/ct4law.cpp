// r10sd4 — GOLDEN'S RULE, cell for cell: HOME SCOPE x vpiInstance STATE.
//
// The head is now localized to a single fact (`ct4bt` + `ct4key`):
//
//     BuildUVMPkg   golden `struct_typespec(m_inst_typename_alias_t)` — a
//                   typedef declared INSIDE `class uvm_default_factory` —
//                   carries `vpiInstance = <null>`; OURS carries `TOP:uvm_pkg`.
//     SeqDriver     golden emits TEN copies of `bit_typespec@26:1-26:4`; the
//                   FOUR listed under a package carry that package, and the SIX
//                   listed under a `class_defn` (or a `module_inst`) carry
//                   `<null>`.  We emit six copies and give the class-listed one
//                   the package.
//
// Both readings are the same rule, and this tool measures it as a rule rather
// than as two anecdotes: every object with a singular `Instance()` is binned by
// the FIRST scope-bearing ancestor on its `VpiParent` chain, and the
// (home scope x instance state) table is printed for both sides.
//
// CAVEAT THE TOOL PRINTS ITSELF: our emission leaves `VpiParent` unset on many
// typespecs, so OUR table has a large `<no-parent>` row.  That is a real
// property of our database (sd2 R7's sibling), not a measurement failure — and
// it is why the golden column is the one that carries the law.
//
// build: g++ -O2 -std=c++17 ct4law.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct4law
// usage: ct4law <golden.uhdm> <ours.uhdm> [ownerTypeFilter]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>

using namespace UHDM;

static const instance* instOf(const BaseClass* p) {
    if (auto* t = any_cast<const typespec*>(p)) return t->Instance();
    if (auto* v = any_cast<const variables*>(p)) return v->Instance();
    if (auto* f = any_cast<const task_func*>(p)) return f->Instance();
    if (auto* q = any_cast<const ports*>(p)) return q->Instance();
    if (auto* cb = any_cast<const clocking_block*>(p)) return cb->Instance();
    if (auto* in = any_cast<const instance*>(p)) return in->Instance();
    return nullptr;
}
static bool carries(const BaseClass* p) {
    return any_cast<const typespec*>(p) || any_cast<const variables*>(p) ||
           any_cast<const task_func*>(p) || any_cast<const ports*>(p) ||
           any_cast<const clocking_block*>(p) || any_cast<const instance*>(p);
}
// The first SCOPE-bearing ancestor: class_defn, package, module_inst,
// interface_inst, program, design — whichever comes first going up.
static std::string home(const BaseClass* p) {
    const BaseClass* q = p->VpiParent();
    int d = 0;
    bool viaTf = false;
    while (q && d++ < 64) {
        if (any_cast<const task_func*>(q)) viaTf = true;
        switch (q->UhdmType()) {
            case uhdmclass_defn: return viaTf ? "class_METHOD" : "class_MEMBER";
            case uhdmpackage: return "package";
            case uhdmmodule_inst: return "module_inst";
            case uhdminterface_inst: return "interface_inst";
            case uhdmprogram: return "program";
            case uhdmdesign: return "design";
            default: break;
        }
        q = q->VpiParent();
    }
    return p->VpiParent() ? "other" : "<no-parent>";
}

static void table(const char* tag, Serializer& s, design* d,
                  const std::string& filt) {
    std::map<const BaseClass*, std::string> ps;
    if (d->AllPackages())
        for (auto* p : *d->AllPackages()) ps[p] = "PKG";
    if (d->TopPackages())
        for (auto* p : *d->TopPackages()) ps[p] = "PKG";
    std::map<std::string, std::map<std::string, long>> t;
    for (const auto& [p, i] : s.AllObjects()) {
        if (!p || !carries(p)) continue;
        std::string ty = UhdmName(p->UhdmType());
        if (!filt.empty() && ty.find(filt) == std::string::npos) continue;
        const instance* v = instOf(p);
        std::string st = !v ? "<null>"
                            : (ps.count((const BaseClass*)v)
                                   ? "package"
                                   : std::string("OTHER:") +
                                         UhdmName(v->UhdmType()));
        t[home(p)][st]++;
        if (home(p) == "class_MEMBER" && st == "package") t["  ..MEMBERpkg:" + ty][st]++;
    }
    std::cout << "\n--- " << tag << (filt.empty() ? "" : ("  filter=" + filt))
              << "\n";
    printf("%-16s %10s %10s %10s\n", "home scope", "<null>", "package", "other");
    for (auto& [h, m] : t) {
        long o = 0;
        for (auto& [k, n] : m)
            if (k != "<null>" && k != "package") o += n;
        printf("%-16s %10ld %10ld %10ld\n", h.c_str(), m["<null>"], m["package"],
               o);
    }
}

int main(int argc, char** argv) {
    if (argc < 3) { std::cerr << "usage: ct4law <golden> <ours> [typefilter]\n"; return 2; }
    std::string filt = argc > 3 ? argv[3] : "";
    static Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    auto* DA = (design*)((uhdm_handle*)ha[0])->object;
    auto* DB = (design*)((uhdm_handle*)hb[0])->object;
    table("GOLDEN", sa, DA, filt);
    table("OURS", sb, DB, filt);
    return 0;
}
