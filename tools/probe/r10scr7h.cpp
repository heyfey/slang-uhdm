// r10scr7h: echo-head locator. Runs design->Compare and prints the failing
// pair WITH BOTH PARENT CHAINS, then walks the design's own vectors so the
// container that carries the head is named.  Compare stops on the first
// unequal object; the parent chain is what turns "ref_typespec()@0:0" into an
// actionable site.
//   r10scr7h <golden.uhdm> <ours.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string nm(const BaseClass* o) {
    if (!o) return "<null>";
    std::string r = std::string(UhdmName(o->UhdmType())) + "(" +
                    std::string(o->VpiName()) + ")@" +
                    std::to_string(o->VpiLineNo()) + ":" +
                    std::to_string(o->VpiColumnNo());
    if (const scope* sc = dynamic_cast<const scope*>(o))
        r += " fn='" + std::string(sc->VpiFullName()) + "'";
    else if (const ref_obj* ro = dynamic_cast<const ref_obj*>(o))
        r += " fn='" + std::string(ro->VpiFullName()) + "'";
    else if (const ref_typespec* rf = dynamic_cast<const ref_typespec*>(o))
        r += " fn='" + std::string(rf->VpiFullName()) + "'";
    if (o->UhdmType() == uhdmconstant) {
        auto* c = (const constant*)o;
        r += "{ct=" + std::to_string(c->VpiConstType()) + ",sz=" +
             std::to_string(c->VpiSize()) + ",v=" + std::string(c->VpiValue()) +
             ",dc=" + std::string(c->VpiDecompile()) + "}";
    }
    if (o->UhdmType() == uhdmref_typespec) {
        auto* rt = (const ref_typespec*)o;
        r += "{act=" +
             (rt->Actual_typespec()
                  ? std::string(UhdmName(rt->Actual_typespec()->UhdmType())) +
                        "(" + std::string(rt->Actual_typespec()->VpiName()) + ")"
                  : std::string("<null>")) +
             "}";
    }
    return r;
}

static void chain(const char* tag, const BaseClass* o) {
    int d = 0;
    for (const BaseClass* p = o; p && d < 20; p = p->VpiParent(), d++)
        std::cout << "    " << tag << "[" << d << "] " << nm(p) << "\n";
}

static void one(const char* tag, const BaseClass* a, const BaseClass* b) {
    CompareContext c;
    c.m_failedLhs = nullptr;
    c.m_failedRhs = nullptr;
    int r = a->Compare(b, &c);
    if (!r) return;
    std::cout << tag << " r=" << r << "  " << nm(a) << " vs " << nm(b) << "\n";
    std::cout << "  failLhs " << nm(c.m_failedLhs) << "\n";
    chain("L", c.m_failedLhs);
    std::cout << "  failRhs " << nm(c.m_failedRhs) << "\n";
    chain("R", c.m_failedRhs);
}

template <typename V>
static void vec(const char* tag, const V* a, const V* b, int maxrep) {
    size_t sa = a ? a->size() : 0, sb = b ? b->size() : 0;
    if (sa != sb) {
        std::cout << tag << ": SIZE " << sa << " vs " << sb << "\n";
        return;
    }
    int n = 0;
    for (size_t i = 0; i < sa; i++) {
        CompareContext c;
        c.m_failedLhs = nullptr;
        c.m_failedRhs = nullptr;
        if ((*a)[i]->Compare((*b)[i], &c) == 0) continue;
        if (n < maxrep) {
            std::cout << tag << "[" << i << "] " << nm((*a)[i]) << "\n";
            std::cout << "  failLhs " << nm(c.m_failedLhs) << "\n";
            chain("L", c.m_failedLhs);
            std::cout << "  failRhs " << nm(c.m_failedRhs) << "\n";
            chain("R", c.m_failedRhs);
        }
        n++;
    }
    std::cout << tag << ": " << n << " / " << sa << " differ\n";
}

int main(int argc, char** argv) {
    if (argc < 3) return 1;
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    auto* da = (design*)((uhdm_handle*)ha[0])->object;
    auto* db = (design*)((uhdm_handle*)hb[0])->object;
    std::string only = argc > 3 ? argv[3] : "";
    auto want = [&](const char* t) { return only.empty() || only == t; };
    if (want("design")) one("DESIGN", da, db);
    if (want("allmod")) vec("AllModules", da->AllModules(), db->AllModules(), 1);
    if (want("allpkg")) vec("AllPackages", da->AllPackages(), db->AllPackages(), 1);
    if (want("topmod")) vec("TopModules", da->TopModules(), db->TopModules(), 1);
    if (want("ts")) vec("design.Typespecs", da->Typespecs(), db->Typespecs(), 1);
    if (want("pa")) vec("design.Param_assigns", da->Param_assigns(), db->Param_assigns(), 8);
    if (want("pm")) vec("design.Parameters", da->Parameters(), db->Parameters(), 4);
    if (want("tf")) vec("design.Task_funcs", da->Task_funcs(), db->Task_funcs(), 4);
    if (want("let")) vec("design.Let_decls", da->Let_decls(), db->Let_decls(), 4);
    if (want("cls")) vec("design.AllClasses", da->AllClasses(), db->AllClasses(), 2);
    if (want("ifc")) vec("design.AllInterfaces", da->AllInterfaces(), db->AllInterfaces(), 2);
    if (want("udp")) vec("design.AllUdps", da->AllUdps(), db->AllUdps(), 2);
    if (want("prg")) vec("design.AllPrograms", da->AllPrograms(), db->AllPrograms(), 2);
    if (want("toppkg")) vec("design.TopPackages", da->TopPackages(), db->TopPackages(), 2);
    if (want("inc")) vec("design.Include_file_infos", da->Include_file_infos(),
                         db->Include_file_infos(), 2);
    return 0;
}
