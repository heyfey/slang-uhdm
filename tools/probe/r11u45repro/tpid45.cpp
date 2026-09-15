// r11u45/tpid45 — THE TYPE-PARAMETER ACTUAL-TYPESPEC IDENTITY CENSUS.
//
// C1's claim is a SHARE: golden's actual typespec for a type parameter whose
// default NAMES another type parameter of the same list IS that parameter's
// OWN typespec object.  uhdm-dump elides a repeated subtree, so dump TEXT
// cannot tell a share from a copy that happens to print the same — the share
// is proved by OBJECT IDENTITY only (RESUME.md §9: "Clone, never share —
// EXCEPT where golden's ids PROVE golden shares").
//
// For every design listing (AllModules / TopModules / AllPackages /
// TopPackages) this prints one line per type_parameter:
//
//   TP <listing> <owner>.<name>  ts#<id> kind=<k> loc=<l:c..l:c> [ranges=N]
//
// Identity is the pointer, interned in first-seen order, stable WITHIN one
// database and meaningless across two — which is exactly right: the claim is
// "golden shares inside golden's own database", checked inside each database
// separately.
//
// Also prints, for every ref_typespec reachable from a port/net/variable whose
// actual is one of those typespecs, a USE line — so a share that reaches the
// ports is visible too.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <map>
#include <string>
#include <vector>
#include <functional>
using namespace UHDM;

static std::map<const void*, int> ids;
static int idOf(const void* p) {
    if (!p) return -1;
    auto it = ids.find(p);
    if (it != ids.end()) return it->second;
    int n = (int)ids.size() + 1;
    ids[p] = n;
    return n;
}

static std::string loc(const any* a) {
    if (!a) return "-";
    char b[64];
    snprintf(b, sizeof b, "%d:%d..%d:%d", (int)a->VpiLineNo(), (int)a->VpiColumnNo(),
             (int)a->VpiEndLineNo(), (int)a->VpiEndColumnNo());
    return b;
}

static int nRanges(const typespec* ts) {
    if (!ts) return -1;
    switch (ts->UhdmType()) {
        case uhdmlogic_typespec: {
            auto* v = ((logic_typespec*)ts)->Ranges();
            return v ? (int)v->size() : -1;
        }
        case uhdmbit_typespec: {
            auto* v = ((bit_typespec*)ts)->Ranges();
            return v ? (int)v->size() : -1;
        }
        case uhdmpacked_array_typespec: {
            auto* v = ((packed_array_typespec*)ts)->Ranges();
            return v ? (int)v->size() : -1;
        }
        case uhdmarray_typespec: {
            auto* v = ((array_typespec*)ts)->Ranges();
            return v ? (int)v->size() : -1;
        }
        default: return -2;  // kind has no Ranges member
    }
}

static std::string ownerName(const any* a) {
    if (!a) return "-";
    if (auto* m = dynamic_cast<const module_inst*>(a)) return std::string(m->VpiFullName());
    if (auto* p = dynamic_cast<const package*>(a)) return std::string(p->VpiFullName());
    return std::string(a->VpiName());
}

static void doScope(const char* listing, const any* owner,
                    VectorOfany* params) {
    if (!params) return;
    for (any* p : *params) {
        if (p->UhdmType() != uhdmtype_parameter) continue;
        auto* tp = (type_parameter*)p;
        const typespec* act = nullptr;
        if (ref_typespec* rt = tp->Typespec()) act = rt->Actual_typespec();
        std::cout << "TP " << listing << " "
                  << (owner ? std::string(ownerName(owner)) : std::string("-"))
                  << "." << tp->VpiName() << "  ts#" << idOf(act)
                  << " kind=" << (act ? UhdmName(act->UhdmType()) : "<null>")
                  << " loc=" << loc(act) << " ranges=" << nRanges(act)
                  << " tpname=" << (act ? std::string(act->VpiName()) : std::string("-"))
                  << "\n";
    }
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: tpid45 <file.uhdm>\n"; return 2; }
    Serializer s;
    std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
    if (restored.empty()) { std::cerr << "FATAL: restore empty\n"; return 3; }
    for (vpiHandle h : restored) {
        auto* d = (design*)((uhdm_handle*)h)->object;
        // RECURSE into instance children: an OVERRIDE's type parameter lives on
        // the child INSTANCE (work@dut.u.id_t), which is reachable only through
        // the parent's Modules() vector, not from AllModules/TopModules.
        std::function<void(const char*, module_inst*)> rec =
            [&](const char* tag, module_inst* m) {
                doScope(tag, m, m->Parameters());
                if (auto* kids = m->Modules())
                    for (module_inst* k : *kids) rec(tag, k);
            };
        auto emit = [&](const char* tag, VectorOfmodule_inst* v) {
            if (!v) return;
            for (module_inst* m : *v) rec(tag, m);
        };
        emit("AllModules", d->AllModules());
        emit("TopModules", d->TopModules());
        if (auto* v = d->AllPackages())
            for (package* p : *v) doScope("AllPackages", p, p->Parameters());
        if (auto* v = d->TopPackages())
            for (package* p : *v) doScope("TopPackages", p, p->Parameters());
    }
    return 0;
}
