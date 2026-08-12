// r10det1repro/dtvec.cpp — print the ORDER of every TYPESPEC LISTING VECTOR in a
// restored database, keyed on the OWNER's source identity (never on an id or an
// address, both of which are run-local).  Written because the pad experiment
// (dtperturb.sh) found ONE object changing position and a dump diff cannot name
// the vector it moved inside.
//   usage: dtvec <db.uhdm>   -> one line per vector: "<count>\t<ownerkind>\t<seq>"
// The owner is printed as its KIND ONLY and the vectors are SORTED as whole
// lines, so the comparison needs no owner identity at all -- which matters
// because a design carries a DEF and a TOP `uvm_pkg` package with the SAME
// name and span, and any name-keyed owner map silently drops one of them (the
// first version of this probe did exactly that and reported a false "no
// difference").  Two runs' outputs are then compared as MULTISETS of vector
// orders: an order that moved shows up as one line changing.
// GUARD: zero vectors found is UNMEASURED, exit 4.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <iostream>
#include <map>
#include <string>
#include <vector>
using namespace UHDM;
static void emit(const std::string& ownerKind, const VectorOftypespec* v,
                 size_t& nvec) {
    if (!v) return;
    ++nvec;
    std::string seq;
    for (auto* t : *v) {
        char b[256];
        snprintf(b, sizeof(b), "%s:%s@%u:%u ",
                 t ? UhdmName(t->UhdmType()).data() : "(null)",
                 t ? std::string(t->VpiName()).c_str() : "-",
                 t ? t->VpiLineNo() : 0u, t ? t->VpiColumnNo() : 0u);
        seq += b;
    }
    printf("%zu\t%s\t%s\n", v->size(), ownerKind.c_str(), seq.c_str());
}
int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: dtvec <db.uhdm>\n"; return 3; }
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) {
        std::cerr << "UNMEASURED: no handles\n"; return 4; }
    size_t nvec = 0;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        std::string nm = std::string(UhdmName(o->UhdmType()));
        switch (o->UhdmType()) {
            case uhdmdesign:    emit(nm, ((const design*)o)->Typespecs(), nvec); break;
            case uhdmpackage:   emit(nm, ((const package*)o)->Typespecs(), nvec); break;
            case uhdmclass_defn:emit(nm, ((const class_defn*)o)->Typespecs(), nvec); break;
            case uhdmmodule_inst: emit(nm, ((const module_inst*)o)->Typespecs(), nvec); break;
            case uhdminterface_inst: emit(nm, ((const interface_inst*)o)->Typespecs(), nvec); break;
            default: break;
        }
    }
    if (!nvec) { std::cerr << "UNMEASURED: no typespec vectors\n"; return 4; }
    fprintf(stderr, "VECTORS n=%zu\n", nvec);
    return 0;
}
