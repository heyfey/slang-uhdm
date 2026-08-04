// r10earl2h: design-wide HEAD CENSUS.  uhdm-cmp names only the first failing
// pair for the whole design, and parameter::Compare recurses Instance() so a
// package head masks every other one.  This walks the four top-level vectors
// (AllModules / TopModules / AllPackages / TopPackages) and Compares each
// entry against its same-named twin with a FRESH CompareContext, so every
// independent head is named once.
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10earl2h.cpp -o /tmp/r10earl2h \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10earl2h <golden.uhdm> <ours.uhdm> [--brief]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>
#include <vector>
using namespace UHDM;

// AllModules entries carry an EMPTY VpiName (the def listing is keyed by
// vpiDefName), so pair them on whichever identity exists.
template <class T>
static std::string key(T* x) {
    std::string n(x->VpiName());
    if (!n.empty()) return n;
    return "def:" + std::string(x->VpiDefName());
}

static std::string at(const BaseClass* n) {
    if (!n) return "<null>";
    std::string s = std::string(UhdmName(n->UhdmType())) + " '" +
                    std::string(n->VpiName()) + "' " +
                    std::string(n->VpiFile()) + ":" + std::to_string(n->VpiLineNo()) + ":" +
                    std::to_string(n->VpiColumnNo());
    if (n->UhdmType() == uhdmconstant) {
        auto* c = (const constant*)n;
        s += " {ct=" + std::to_string(c->VpiConstType()) +
             " sz=" + std::to_string(c->VpiSize()) +
             " dec=" + std::string(c->VpiDecompile()) + "}";
    }
    if (n->UhdmType() == uhdmref_module) {
        auto* rm = (const ref_module*)n;
        s += " {def='" + std::string(rm->VpiDefName()) + "' actual=" +
             (rm->Actual_group() ? std::string(UhdmName(
                                       rm->Actual_group()->UhdmType()))
                                 : std::string("<null>")) +
             " ports=" +
             (rm->Ports() ? std::to_string(rm->Ports()->size())
                          : std::string("-")) +
             "}";
    }
    // r10earl4: instances (package / module_inst) — the fields instance::Compare
    // and scope::Compare actually read, plus the child-vector sizes, so an
    // "r=1 failLhs=<the instance itself>" head names its own cause.
    if (const instance* in = any_cast<const instance*>((const any*)n)) {
        s += " {top=" + std::to_string((int)in->VpiTop()) + " def=" +
             std::string(in->VpiDefName()) + " uid=" + std::to_string(in->UhdmId());
        auto vs = [&](const char* t, const auto* v) {
            s += std::string(" ") + t + "=" + (v ? std::to_string(v->size()) : "-");
        };
        vs("par", in->Parameters());
        vs("pa", in->Param_assigns());
        vs("ts", in->Typespecs());
        vs("va", in->Variables());
        vs("tf", in->Task_funcs());
        vs("net", in->Nets());
        vs("cls", in->Class_defns());
        s += "}";
    }
    return s;
}

static std::string chain(const BaseClass* n) {
    std::string s;
    int i = 0;
    const any* p = n ? n->VpiParent() : nullptr;
    while (p && i++ < 7) {
        s += "\n        ^ " + at(p);
        p = p->VpiParent();
    }
    return s;
}

template <class V>
static void census(const char* tag, V* va, V* vb, bool brief) {
    size_t na = va ? va->size() : 0, nb = vb ? vb->size() : 0;
    std::cout << "== " << tag << " SIZE " << na << " vs " << nb << "\n";
    std::map<std::string, const typename V::value_type> mb;
    if (vb)
        for (auto* x : *vb) mb.emplace(key(x), x);
    int heads = 0;
    if (va)
        for (auto* x : *va) {
            std::string nm = key(x);
            auto it = mb.find(nm);
            if (it == mb.end()) {
                std::cout << "  MISSING-RHS " << nm << "\n";
                heads++;
                continue;
            }
            CompareContext ctx;
            int r = x->Compare(it->second, &ctx);
            if (r == 0) continue;
            heads++;
            if (brief)
                std::cout << "  HEAD " << nm << " r=" << r << "\n";
            else
                std::cout << "  HEAD " << nm << " r=" << r << "\n    failLhs "
                          << at(ctx.m_failedLhs) << chain(ctx.m_failedLhs)
                          << "\n    failRhs " << at(ctx.m_failedRhs)
                          << chain(ctx.m_failedRhs) << "\n";
        }
    if (vb)
        for (auto* x : *vb) {
            std::string nm = key(x);
            bool found = false;
            if (va)
                for (auto* y : *va)
                    if (key(y) == nm) { found = true; break; }
            if (!found) std::cout << "  EXTRA-RHS " << nm << "\n";
        }
    std::cout << "   -> " << heads << " head(s)\n";
}

int main(int argc, char** argv) {
    if (argc < 3) return 1;
    bool brief = argc > 3 && std::string(argv[3]) == "--brief";
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    if (ha.empty() || hb.empty()) return 2;
    const design* da = (const design*)((uhdm_handle*)ha[0])->object;
    const design* db = (const design*)((uhdm_handle*)hb[0])->object;
    census("AllModules", da->AllModules(), db->AllModules(), brief);
    census("TopModules", da->TopModules(), db->TopModules(), brief);
    census("AllPackages", da->AllPackages(), db->AllPackages(), brief);
    census("TopPackages", da->TopPackages(), db->TopPackages(), brief);
    return 0;
}
