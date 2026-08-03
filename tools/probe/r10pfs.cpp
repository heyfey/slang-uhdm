// r10pfs: per-VIEW typespec-IDENTITY census — every net / var / port / module
// typedef-listing binding printed with a stable per-file object index AND the
// UhdmId, plus each logic_typespec's Elem_typespec, Typedef_alias and
// Instance.  Decides "same object vs per-use clone" and "qualified vs bare
// clone name", which a uhdm-dump cannot show (repeated objects print
// abbreviated).  It is what cracked PackedArrayHighConn: golden mints FOUR
// pad_pok_t clones (def net elem + def port typedef, both package-QUALIFIED;
// elab var ts + elab port typedef, both BARE) where we minted two.
//   g++ -std=c++17 -I$HOME/.local/include r10pfs.cpp -o r10pfs \
//       -L$HOME/.local/lib64 -luhdm -lcapnp -lkj
//   r10pfs <a.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
#include <set>
#include <string>
using namespace UHDM;

static std::map<const BaseClass*, int> g_ids;
static int oid(const BaseClass* o) {
    if (!o) return -1;
    auto it = g_ids.find(o);
    if (it != g_ids.end()) return it->second;
    int n = (int)g_ids.size();
    return g_ids[o] = n;
}
static std::string tsdesc(const typespec* t) {
    if (!t) return "none";
    return std::string(UhdmName(t->UhdmType())) + "#" + std::to_string(oid(t)) +
           "/id" + std::to_string(t->UhdmId()) + "'" + std::string(t->VpiName()) + "'";
}
static std::string rtd(const ref_typespec* r) {
    if (!r) return "<norefts>";
    return "ref#" + std::to_string(oid(r)) + "/id" + std::to_string(r->UhdmId()) +
           "'" + std::string(r->VpiName()) + "'->" + tsdesc(r->Actual_typespec());
}
static std::string full(const typespec* t) {
    if (!t) return "none";
    std::string r = tsdesc(t);
    if (t->UhdmType() == uhdmlogic_typespec) {
        auto* lt = (const logic_typespec*)t;
        r += " elem=" + rtd(lt->Elem_typespec());
        r += " alias=" + rtd(lt->Typedef_alias());
        r += std::string(" inst=") +
             (lt->Instance() ? std::string(lt->Instance()->VpiName()) : "-");
    }
    return r;
}
static void dumpMod(const std::string& tag, const module_inst* m) {
    std::cout << tag << " MOD " << m->VpiFullName() << " def=" << m->VpiDefName() << "\n";
    if (m->Nets())
        for (auto* n : *m->Nets()) {
            std::cout << tag << "   net " << n->VpiName() << " nettype=" << n->VpiNetType()
                      << " ts=";
            const ref_typespec* nrt = nullptr;
            if (n->UhdmType() == uhdmlogic_net)
                nrt = ((const logic_net*)n)->Typespec();
            std::cout << rtd(nrt);
            auto* nat = nrt ? nrt->Actual_typespec() : nullptr;
            if (nat && nat->UhdmType() == uhdmlogic_typespec) {
                auto* lt = (const logic_typespec*)nat;
                std::cout << " ELEM=" << rtd(lt->Elem_typespec());
                if (lt->Elem_typespec())
                    std::cout << " ELEMFULL=[" << full(lt->Elem_typespec()->Actual_typespec()) << "]";
            }
            std::cout << "\n";
        }
    if (m->Variables())
        for (auto* v : *m->Variables()) {
            std::cout << tag << "   var " << v->VpiName() << " " << UhdmName(v->UhdmType())
                      << " ts=" << rtd(v->Typespec());
            if (v->Typespec()) std::cout << " FULL=[" << full(v->Typespec()->Actual_typespec()) << "]";
            std::cout << "\n";
            if (v->UhdmType() == uhdmpacked_array_var) {
                auto* pa = (const packed_array_var*)v;
                auto* at = pa->Typespec() ? pa->Typespec()->Actual_typespec() : nullptr;
                if (at && at->UhdmType() == uhdmlogic_typespec)
                    std::cout << tag << "      arrayTs elem="
                              << rtd(((const logic_typespec*)at)->Elem_typespec()) << "\n";
            }
        }
    if (m->Ports())
        for (auto* p : *m->Ports()) {
            std::cout << tag << "   port " << p->VpiName() << " dir=" << p->VpiDirection()
                      << " typedef=" << rtd(p->Typespec());
            if (p->Typespec()) std::cout << " FULL=[" << full(p->Typespec()->Actual_typespec()) << "]";
            std::cout << "\n";
        }
    if (m->Typespecs())
        for (auto* t : *m->Typespecs())
            std::cout << tag << "   tsListing " << full(t) << "\n";
    if (m->Modules())
        for (auto* c : *m->Modules()) dumpMod(tag + ">", c);
}
int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    if (d->AllPackages())
        for (auto* p : *d->AllPackages()) {
            std::cout << "ALLPKG " << p->VpiName() << "\n";
            if (p->Typespecs()) for (auto* t : *p->Typespecs())
                std::cout << "ALLPKG   ts " << tsdesc(t) << "\n";
        }
    if (d->TopPackages())
        for (auto* p : *d->TopPackages()) {
            std::cout << "TOPPKG " << p->VpiName() << "\n";
            if (p->Typespecs()) for (auto* t : *p->Typespecs())
                std::cout << "TOPPKG   ts " << tsdesc(t) << "\n";
        }
    if (d->AllModules()) for (auto* m : *d->AllModules()) dumpMod("ALL", m);
    if (d->TopModules()) for (auto* m : *d->TopModules()) dumpMod("TOP", m);
    return 0;
}
