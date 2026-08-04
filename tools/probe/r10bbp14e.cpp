// r10bbp14e: per-view Variables/Nets rosters + the vpiActual every ref_obj at a
// requested LINE:COL binds, WITHOUT the listener escaping through the actual
// (r10bbp14d's listenAny walks into the bound net and re-reaches the whole
// design).  Walks cont_assign / process trees by hand, one level of expression
// structure at a time.
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10bbp14e.cpp -o /tmp/r10bbp14eq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10bbp14eq <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <set>
#include <string>
using namespace UHDM;

static std::set<const BaseClass*> topSet, defSet;
static const char* where(const BaseClass* o) {
    if (!o) return "null";
    if (topSet.count(o)) return "TOP";
    if (defSet.count(o)) return "DEF";
    return "other";
}

static std::set<const any*> seen;

static void walk(const any* e) {
    if (!e || !seen.insert(e).second) return;
    switch (e->UhdmType()) {
        case uhdmref_obj: {
            auto* r = (const ref_obj*)e;
            auto* a = r->Actual_group();
            std::cout << "    ref '" << std::string(r->VpiName()) << "' @"
                      << r->VpiLineNo() << ":" << r->VpiColumnNo() << " -> "
                      << (a ? UhdmName(a->UhdmType()) : "<null>") << " id"
                      << (a ? a->UhdmId() : 0) << " [" << where(a) << "]\n";
            break;
        }
        case uhdmoperation: {
            auto* o = (const operation*)e;
            if (o->Operands())
                for (auto* op : *o->Operands()) walk(op);
            break;
        }
        case uhdmhier_path: {
            auto* hp = (const hier_path*)e;
            std::cout << "    hier_path '" << std::string(hp->VpiName())
                      << "' @" << hp->VpiLineNo() << ":" << hp->VpiColumnNo()
                      << "\n";
            if (hp->Path_elems())
                for (auto* pe : *hp->Path_elems()) walk(pe);
            break;
        }
        case uhdmindexed_part_select: {
            auto* ip = (const indexed_part_select*)e;
            std::cout << "    ips '" << std::string(ip->VpiName()) << "' fn='"
                      << std::string(ip->VpiFullName()) << "'\n";
            walk(ip->Base_expr());
            walk(ip->Width_expr());
            break;
        }
        case uhdmbit_select:
            walk(((const bit_select*)e)->VpiIndex());
            break;
        default:
            break;
    }
}

int main(int argc, char** argv) {
    if (argc < 2) return 1;
    Serializer ser;
    auto h = ser.Restore(std::filesystem::path(argv[1]));
    if (h.empty()) return 2;
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    const module_inst* def = (*d->AllModules())[0];
    const module_inst* top = (*d->TopModules())[0];
    auto fill = [](std::set<const BaseClass*>& s, const module_inst* m) {
        if (m->Nets())
            for (auto* n : *m->Nets()) s.insert(n);
        if (m->Variables())
            for (auto* v : *m->Variables()) s.insert(v);
    };
    fill(topSet, top);
    fill(defSet, def);
    auto roster = [](const char* tag, const module_inst* m) {
        std::cout << "== " << tag << " id" << m->UhdmId() << "\n";
        std::cout << "  Nets:";
        if (m->Nets())
            for (auto* n : *m->Nets())
                std::cout << " " << std::string(n->VpiName()) << "("
                          << UhdmName(n->UhdmType()) << ",id" << n->UhdmId()
                          << ")";
        std::cout << "\n  Variables:";
        if (m->Variables())
            for (auto* v : *m->Variables())
                std::cout << " " << std::string(v->VpiName()) << "("
                          << UhdmName(v->UhdmType()) << ",id" << v->UhdmId()
                          << ")";
        std::cout << "\n";
    };
    roster("DEF", def);
    roster("TOP", top);
    if (top->Cont_assigns()) {
        size_t i = 0;
        for (auto* ca : *top->Cont_assigns()) {
            std::cout << "CA[" << i++ << "] @" << ca->VpiLineNo() << ":"
                      << ca->VpiColumnNo() << " lhs="
                      << (ca->Lhs() ? std::string(ca->Lhs()->VpiName())
                                    : std::string("<null>"))
                      << " [" << where(ca->Lhs()) << "]\n";
            seen.clear();
            walk(ca->Rhs());
        }
    }
    return 0;
}
