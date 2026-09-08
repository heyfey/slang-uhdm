// r10uvm215 — THE A-PRIORI MOVER PREDICTOR.  MEASUREMENT ONLY; the official
// `uhdm-cmp` is the sole judge.  LHS is ALWAYS golden, RHS is ALWAYS ours.
//
// § modportNeedsSimplePort215 removes exactly those `modport` objects we mint
// with an EMPTY io_decl list, and it changes a modport-qualified port view's
// listing only when the connected modport is one of those.  So the set of
// databases whose BYTES can move is decidable from the PRISTINE database alone,
// before the patched binary exists: it is the set that holds at least one
// modport with `Io_decls()` null or empty.
//
// Prints one line per database:  `<n empty modports> <n modports total> <path>`
// and a MOVER/CLEAN verdict, so a driver can turn a whole sweep workdir into a
// predicted mover list BY NAME.
//
// build: g++ -O2 -std=c++17 ct215pred.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct215pred
// usage: ct215pred <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <string>

using namespace UHDM;

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct215pred <db>\n"); return 2; }
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) {
        printf("RESTORE_FAIL %s\n", argv[1]);
        return 3;
    }
    size_t empt = 0, tot = 0, ifaces = 0;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdminterface_inst) continue;
        ++ifaces;
        const interface_inst* ii = (const interface_inst*)o;
        if (!ii->Modports()) continue;
        for (auto* mp : *ii->Modports()) {
            ++tot;
            if (!mp->Io_decls() || mp->Io_decls()->empty()) ++empt;
        }
    }
    printf("%s emptyModports=%zu modports=%zu interfaces=%zu %s\n",
           empt ? "MOVER" : "CLEAN", empt, tot, ifaces, argv[1]);
    return 0;
}
