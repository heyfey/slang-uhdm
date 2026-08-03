// r10scr5ta: for every design-level typespec, walk its Range()/expression
// subtree and report each ref_obj with whether its Actual_group is bound.
// Answers "which def-view range refs does Surelog bind, and which does it
// leave dangling" without wading through a 300k-line uhdm-dump.
//   r10scr5ta <file.uhdm>
// Build:
//   g++ -std=c++20 -O0 tools/probe/r10scr5ta.cpp -o /tmp/r10scr5ta \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <set>
#include <string>
using namespace UHDM;

static std::string nm(const BaseClass* o) {
    if (!o) return "<null>";
    return std::string(UhdmName(o->UhdmType())) + "(" + std::string(o->VpiName()) +
           ")@" + std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo());
}

static std::set<const BaseClass*> seen;

static void walk(const any* o, const std::string& path) {
    if (!o || !seen.insert(o).second) return;
    if (o->UhdmType() == uhdmref_obj) {
        auto* r = (const ref_obj*)o;
        std::cout << (r->Actual_group() ? "BOUND   " : "DANGLING") << "  "
                  << nm(r) << "  actual=" << nm(r->Actual_group())
                  << "  under " << path << "\n";
        return;
    }
    // Generic child walk via the vpi iterator would need the visitor; instead
    // handle the shapes that appear in typespec ranges.
    if (o->UhdmType() == uhdmoperation) {
        auto* op = (const operation*)o;
        if (op->Operands())
            for (auto* x : *op->Operands()) walk(x, path);
        return;
    }
    if (o->UhdmType() == uhdmrange) {
        auto* rg = (const range*)o;
        walk(rg->Left_expr(), path);
        walk(rg->Right_expr(), path);
        return;
    }
    if (o->UhdmType() == uhdmbit_select) {
        walk(((const bit_select*)o)->VpiIndex(), path);
        return;
    }
    if (o->UhdmType() == uhdmpart_select) {
        auto* ps = (const part_select*)o;
        walk(ps->Left_range(), path);
        walk(ps->Right_range(), path);
        return;
    }
}

static void walkTs(const typespec* ts, const std::string& path) {
    if (!ts) return;
    switch (ts->UhdmType()) {
        case uhdmlogic_typespec:
            if (auto* rs = ((const logic_typespec*)ts)->Ranges())
                for (auto* r : *rs) walk(r, path);
            break;
        case uhdmbit_typespec:
            if (auto* rs = ((const bit_typespec*)ts)->Ranges())
                for (auto* r : *rs) walk(r, path);
            break;
        case uhdmarray_typespec:
            if (auto* rs = ((const array_typespec*)ts)->Ranges())
                for (auto* r : *rs) walk(r, path);
            break;
        case uhdmpacked_array_typespec:
            if (auto* rs = ((const packed_array_typespec*)ts)->Ranges())
                for (auto* r : *rs) walk(r, path);
            break;
        case uhdmstruct_typespec:
            if (auto* ms = ((const struct_typespec*)ts)->Members())
                for (auto* m : *ms)
                    if (m->Typespec() && m->Typespec()->Actual_typespec())
                        walkTs(m->Typespec()->Actual_typespec(),
                               path + "." + std::string(m->VpiName()));
            break;
        default:
            break;
    }
}

int main(int argc, char** argv) {
    if (argc < 2) return 1;
    Serializer ser;
    auto hs = ser.Restore(std::filesystem::path(argv[1]));
    auto* d = (design*)((uhdm_handle*)hs[0])->object;
    if (d->Typespecs())
        for (auto* ts : *d->Typespecs()) walkTs(ts, nm(ts));
    return 0;
}
