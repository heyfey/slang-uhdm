// r10uvm154 — CENSUS of every `enum_const` in ONE database.
// MEASUREMENT ONLY.  The official ~/git-repos/UHDM/build/bin/uhdm-cmp is the
// sole acceptance judge.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// Reads the .uhdm DIRECTLY (Serializer::AllObjects) — never uhdm-dump, which
// is unusable on Earlgrey/UVM-sized designs.
//
// One row per enum_const:
//
//   EC|<owner-typespec-name>|<const-name>|<line>:<col>-<endln>:<endcol>|
//      <VpiValue>|<VpiDecompile>|<VpiSize>|<base-typespec-kind>|<base-name>
//
// The KEY the join uses is  owner-typespec-name + const-name + line:col , which
// is depth-independent and view-BLIND on purpose: the DEF listing object and
// the elaborated twin carry the same key, so the multiset join keeps BOTH and a
// per-view flip cannot hide inside a last-writer dict (RESUME.md §9).
//
// build: g++ -O2 -std=c++17 ct154cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct154cen
// usage: ct154cen <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>

using namespace UHDM;

static std::string esc(std::string_view v) {
    std::string o;
    for (char c : v) o += (c == '|' || c == '\n') ? '~' : c;
    return o;
}

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct154cen db.uhdm\n"); return 2; }
    Serializer s;
    const std::vector<vpiHandle> h = s.Restore(std::string(argv[1]));
    if (h.empty()) { fprintf(stderr, "restore failed\n"); return 3; }
    for (const auto& [obj, id] : s.AllObjects()) {
        if (!obj || obj->UhdmType() != uhdmenum_const) continue;
        const enum_const* e = (const enum_const*)obj;
        std::string owner = "-", bkind = "-", bname = "-";
        const BaseClass* p = e->VpiParent();
        if (p) {
            owner = std::string(p->VpiName());
            if (p->UhdmType() == uhdmenum_typespec) {
                const enum_typespec* et = (const enum_typespec*)p;
                if (const ref_typespec* rt = et->Base_typespec()) {
                    bname = std::string(rt->VpiFullName());
                    if (const typespec* ts = rt->Actual_typespec())
                        bkind = std::string(UhdmName(ts->UhdmType()));
                    else
                        bkind = "<no-actual>";
                }
                else bkind = "<none>";
            }
        }
        printf("EC|%s|%s|%u:%u-%u:%u|%s|%s|%d|%s|%s\n", esc(owner).c_str(),
               esc(e->VpiName()).c_str(), e->VpiLineNo(),
               (unsigned)e->VpiColumnNo(), e->VpiEndLineNo(),
               (unsigned)e->VpiEndColumnNo(), esc(e->VpiValue()).c_str(),
               esc(e->VpiDecompile()).c_str(), (int)e->VpiSize(),
               esc(bkind).c_str(), esc(bname).c_str());
    }
    return 0;
}
