// r11u26/idcen26 — THE ID-KEYED LEFTOVER CENSUS.
//
// The brief's caution: golden SHARING an object and uhdm-dump ELIDING a
// repeated subtree read identically in dump TEXT (a shared subtree is printed
// once and later readers look empty).  So the share is proved by OBJECT
// IDENTITY, never by dump text.
//
// For every design listing (AllPackages / TopPackages / AllModules /
// TopModules) this prints, in two blocks:
//
//   PA  <listing> <scope>.<param>  rhs#<id> kind=<k> [op=<n> nops=<n>]
//         — every param_assign's Rhs OBJECT identity;
//   TM  <listing> <struct ts name>.<member>  val#<id> kind=<k> [...]
//         — every typespec_member's Actual_value OBJECT identity (the
//           EvalFunc leftover).
//
// A leftover that SHARES a parameter's elaborated Rhs prints the SAME #id as
// that parameter's PA line.  Identity is the pointer, interned in first-seen
// order, so it is stable within one database and meaningless across two —
// which is exactly right: the claim is "golden shares inside golden's own
// database", and it is checked inside each database separately.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <set>
#include <string>
#include <vector>
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

static std::string kindName(const any* a) {
    if (!a) return "<null>";
    switch (a->UhdmType()) {
        case uhdmconstant: return "constant";
        case uhdmoperation: return "operation";
        case uhdmref_obj: return "ref_obj";
        case uhdmhier_path: return "hier_path";
        case uhdmstruct_var: return "struct_var";
        case uhdmfunc_call: return "func_call";
        case uhdmsys_func_call: return "sys_func_call";
        case uhdmarray_expr: return "array_expr";
        case uhdmbit_select: return "bit_select";
        case uhdmtagged_pattern: return "tagged_pattern";
        default: return "other";
    }
}

// the judge-visible payload of an expression object, plus the operand SHAPE
static std::string payload(const any* a) {
    if (!a) return "";
    std::string out;
    if (a->UhdmType() == uhdmconstant) {
        auto* c = (const constant*)a;
        out += " val=" + std::string(c->VpiValue()) +
               " dec=" + std::string(c->VpiDecompile()) +
               " size=" + std::to_string(c->VpiSize()) +
               " ct=" + std::to_string(c->VpiConstType());
    }
    else if (a->UhdmType() == uhdmoperation) {
        auto* o = (const operation*)a;
        out += " op=" + std::to_string(o->VpiOpType());
        auto* ops = o->Operands();
        out += " nops=" + std::to_string(ops ? ops->size() : 0);
        if (ops) {
            out += " operands=";
            for (size_t i = 0; i < ops->size(); i++) {
                if (i) out += ",";
                out += kindName((*ops)[i]) + "#" +
                       std::to_string(idOf((*ops)[i]));
            }
        }
    }
    else if (a->UhdmType() == uhdmref_obj) {
        out += " name=" + std::string(((const ref_obj*)a)->VpiName());
    }
    // the Rhs typespec is judge-visible through ref_typespec::Actual
    const ref_typespec* rt = nullptr;
    if (auto* e = any_cast<const expr*>(a)) rt = e->Typespec();
    if (rt)
        out += " ts#" + std::to_string(idOf(rt->Actual_typespec())) + "(" +
               (rt->Actual_typespec()
                    ? std::string(rt->Actual_typespec()->VpiName())
                    : std::string("null")) +
               ")";
    else
        out += " ts#-1";
    // PARENT identity: the share is visible here — a shared object keeps the
    // parent it was minted under (the producing param_assign).
    out += " parent#" + std::to_string(idOf(a->VpiParent())) + "/" +
           (a->VpiParent() ? kindName(a->VpiParent()) : std::string("<null>"));
    return out;
}

static std::set<const void*> seenTs;

static void walkTs(const char* listing, const typespec* ts, int depth) {
    if (!ts || depth > 6) return;
    if (ts->UhdmType() != uhdmstruct_typespec) return;
    if (!seenTs.insert((const void*)ts).second) return;
    auto* st = (const struct_typespec*)ts;
    std::string nm(st->VpiName());
    if (nm.empty()) nm = "<anon>";
    if (auto* ms = st->Members())
        for (auto* m : *ms) {
            const any* v = m->Actual_value();
            std::cout << "TM " << listing << " " << nm << "." << m->VpiName()
                      << "  val#" << idOf(v) << " kind=" << kindName(v)
                      << payload(v) << "\n";
            if (auto* mrt = m->Typespec())
                walkTs(listing, mrt->Actual_typespec(), depth + 1);
        }
}

static void walkScope(const char* listing, const std::string& owner,
                      const VectorOfparam_assign* pas,
                      const VectorOftypespec* tss) {
    if (pas)
        for (auto* pa : *pas) {
            const any* r = pa->Rhs();
            std::string ln = pa->Lhs() ? std::string(pa->Lhs()->VpiName()) : "?";
            std::cout << "PA " << listing << " " << owner << "." << ln
                      << "  rhs#" << idOf(r) << " kind=" << kindName(r)
                      << payload(r) << "\n";
            // a struct-typed parameter's own typespec carries the leftovers
            if (pa->Lhs() && pa->Lhs()->UhdmType() == uhdmparameter)
                if (auto* prt = ((const parameter*)pa->Lhs())->Typespec())
                    walkTs(listing, prt->Actual_typespec(), 0);
        }
    if (tss)
        for (auto* t : *tss) walkTs(listing, t, 0);
}

static void walkMod(const char* listing, const module_inst* m) {
    walkScope(listing, std::string(m->VpiFullName()), m->Param_assigns(),
              m->Typespecs());
    if (m->Modules())
        for (auto* c : *m->Modules()) walkMod(listing, c);
}

int main(int argc, char** argv) {
    for (int i = 1; i < argc; i++) {
        Serializer s;
        auto h = s.Restore(std::filesystem::path(argv[i]));
        if (h.empty()) {
            std::cout << "## " << argv[i] << " RESTORE-FAILED\n";
            continue;
        }
        auto* d = (design*)((uhdm_handle*)h[0])->object;
        ids.clear();
        seenTs.clear();
        std::cout << "## " << argv[i] << "\n";
        if (d->AllPackages())
            for (auto* p : *d->AllPackages())
                walkScope("allPkg", std::string(p->VpiName()),
                          p->Param_assigns(), p->Typespecs());
        seenTs.clear();
        if (d->TopPackages())
            for (auto* p : *d->TopPackages())
                walkScope("topPkg", std::string(p->VpiName()),
                          p->Param_assigns(), p->Typespecs());
        seenTs.clear();
        if (d->AllModules())
            for (auto* m : *d->AllModules()) walkMod("allMod", m);
        seenTs.clear();
        if (d->TopModules())
            for (auto* m : *d->TopModules()) walkMod("topMod", m);
    }
    return 0;
}
