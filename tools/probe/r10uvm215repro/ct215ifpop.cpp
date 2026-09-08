// r10uvm215 — THE INTERFACE-INSTANCE POPULATION CENSUS.  MEASUREMENT ONLY; the
// official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge; this tool
// links the SAME generated `Compare` and only reports.  LHS is ALWAYS golden
// (Surelog), RHS is ALWAYS ours.
//
// The head of this pass is a VECTOR-overload null (`BaseClass.h:220-222`):
// golden's `interface_inst::Modports()` POINTER is null where ours holds a
// one-element vector, so the judge prints `LHS: <null>` with OUR def-view
// interface as the RHS.  The question that decides the law is therefore a
// POPULATION question: which interface_inst objects, in which VIEW, carry a
// Modports vector on each side, and what is in each modport.
//
// Every interface_inst in the arena is listed with its view (parent kind), its
// name/defname/span, and — per modport — the io_decl names it carries, so a
// modport that exists but is EMPTY is visibly different from one that is
// absent.  `NULLVEC` is printed distinctly from `size 0`: they are what the two
// SafeCompare arms discriminate on.
//
// build: g++ -O2 -std=c++17 ct215ifpop.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct215ifpop
// usage: ct215ifpop <db.uhdm> [<tag>]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <string>
#include <vector>

using namespace UHDM;

static std::string ident(const BaseClass* o) {
    if (!o) return "<null>";
    char b[900];
    snprintf(b, sizeof b, "%s(%s)@%u:%u-%u:%u",
             std::string(UhdmName(o->UhdmType())).c_str(),
             std::string(o->VpiName()).c_str(), o->VpiLineNo(),
             (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo());
    return b;
}
static std::string vecstate(const BaseClass* owner, int t) {
    auto tup = owner->GetByVpiType(t);
    const std::vector<const BaseClass*>* vec = std::get<2>(tup);
    const BaseClass* one = std::get<0>(tup);
    if (one) return "SING";
    if (!vec) return "NULLVEC";
    char b[64];
    snprintf(b, sizeof b, "size%zu", vec->size());
    return b;
}

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct215ifpop <db> [tag]\n"); return 2; }
    const char* tag = argc > 2 ? argv[2] : "";
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
    size_t n = 0, withMp = 0, nullMp = 0;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdminterface_inst) continue;
        const interface_inst* ii = (const interface_inst*)o;
        ++n;
        const BaseClass* p = ii->VpiParent();
        std::string view = p ? std::string(UhdmName(p->UhdmType())) + ":" +
                                   std::string(p->VpiName())
                             : std::string("<no-parent>");
        const char* mps = ii->Modports() ? "" : "NULLVEC";
        if (ii->Modports()) ++withMp; else ++nullMp;
        printf("%sIFACE %-46s defname=%-24s parent=%-28s nets=%-8s modports=%-8s "
               "cb=%-8s vars=%-8s tf=%-8s ports=%-8s ca=%-8s proc=%-8s ifacetf=%s\n",
               tag, ident(ii).c_str(), std::string(ii->VpiDefName()).c_str(),
               view.c_str(), vecstate(ii, vpiNet).c_str(),
               vecstate(ii, vpiModport).c_str(),
               vecstate(ii, vpiClockingBlock).c_str(),
               vecstate(ii, vpiVariables).c_str(),
               vecstate(ii, vpiTaskFunc).c_str(), vecstate(ii, vpiPort).c_str(),
               vecstate(ii, vpiContAssign).c_str(),
               vecstate(ii, vpiProcess).c_str(),
               vecstate(ii, vpiInterfaceTfDecl).c_str());
        (void)mps;
        if (ii->Modports())
            for (auto* mp : *ii->Modports()) {
                std::string ios;
                if (!mp->Io_decls()) ios = "NULLVEC";
                else
                    for (auto* io : *mp->Io_decls()) {
                        ios += " ";
                        ios += io->VpiName();
                        char d[32];
                        snprintf(d, sizeof d, "(dir%d)", io->VpiDirection());
                        ios += d;
                        if (io->Expr()) ios += "{expr}";
                    }
                printf("%s   MODPORT %-36s iodecls=%s\n", tag, ident(mp).c_str(),
                       ios.c_str());
            }
    }
    printf("%sTOTAL interface_inst=%zu withModports=%zu nullModports=%zu\n", tag, n,
           withMp, nullMp);
    return 0;
}
