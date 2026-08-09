// r10earl14g — a listing's Typespecs() vector expanded: for a struct/union
// typespec, every typespec_member with its own typespec's ranges and default
// value; for a ranged typespec, its bounds.  Pass 14's § cutInstance bisect
// (r10earl14a --cut) points at struct_typespec members as the owner of the
// "golden points at an expression, we point at nothing" pointers, and no other
// probe prints them.
// Build: bash tools/probe/r10earl14build.sh r10earl14g
// Usage: r10earl14g <a.uhdm> <b.uhdm> <all|top|allpkg|toppkg> <Name> [tsIndex]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string at(const BaseClass* n) {
    if (!n)
        return "<null>";
    std::string s = std::string(UhdmName(n->UhdmType())) + " '" +
                    std::string(n->VpiName()) + "' " + std::to_string(n->VpiLineNo()) +
                    ":" + std::to_string(n->VpiColumnNo()) + " uid=" +
                    std::to_string(n->UhdmId());
    if (n->UhdmType() == uhdmconstant) {
        auto* c = (const constant*)n;
        s += " {ct=" + std::to_string(c->VpiConstType()) +
             " sz=" + std::to_string(c->VpiSize()) + " dec=" +
             std::string(c->VpiDecompile()) + "}";
    }
    if (n->UhdmType() == uhdmoperation)
        s += " {op=" + std::to_string(((const operation*)n)->VpiOpType()) + "}";
    if (n->UhdmType() == uhdmref_obj)
        s += " full='" + std::string(((const ref_obj*)n)->VpiFullName()) + "'";
    return s;
}

static void expr1(const any* e, const std::string& ind) {
    std::cout << ind << at(e) << "\n";
    if (e && e->UhdmType() == uhdmoperation)
        if (auto* ops = ((const operation*)e)->Operands())
            for (auto* o : *ops)
                std::cout << ind << "   op: " << at(o) << "\n";
}

static void showTs(const typespec* t, const std::string& ind, int depth);

static void showRanges(const typespec* t, const std::string& ind) {
    VectorOfrange* rgs = nullptr;
    if (auto* x = any_cast<const logic_typespec*>((const any*)t))
        rgs = x->Ranges();
    else if (auto* x = any_cast<const bit_typespec*>((const any*)t))
        rgs = x->Ranges();
    else if (auto* x = any_cast<const int_typespec*>((const any*)t))
        rgs = x->Ranges();
    else if (auto* x = any_cast<const packed_array_typespec*>((const any*)t))
        rgs = x->Ranges();
    else if (auto* x = any_cast<const array_typespec*>((const any*)t))
        rgs = x->Ranges();
    if (!rgs)
        return;
    for (size_t i = 0; i < rgs->size(); i++) {
        std::cout << ind << "rng[" << i << "] L:\n";
        expr1((*rgs)[i]->Left_expr(), ind + "  ");
        std::cout << ind << "rng[" << i << "] R:\n";
        expr1((*rgs)[i]->Right_expr(), ind + "  ");
    }
}

static void showTs(const typespec* t, const std::string& ind, int depth) {
    if (!t) {
        std::cout << ind << "<null ts>\n";
        return;
    }
    std::cout << ind << at(t) << "\n";
    showRanges(t, ind + "  ");
    if (depth <= 0)
        return;
    if (auto* st = any_cast<const struct_typespec*>((const any*)t)) {
        if (auto* ms = st->Members())
            for (auto* m : *ms) {
                std::cout << ind << "  member '" << m->VpiName() << "' "
                          << m->VpiLineNo() << ":" << m->VpiColumnNo() << "\n";
                showTs(m->Typespec() ? m->Typespec()->Actual_typespec() : nullptr,
                       ind + "    ", depth - 1);
            }
    }
}

template <class V>
static const instance* pick(V* v, const std::string& want) {
    if (v)
        for (auto* x : *v) {
            std::string n(x->VpiName()), dn(x->VpiDefName());
            if (n == want || dn == want || ("def:" + dn) == want)
                return x;
        }
    return nullptr;
}

int main(int argc, char** argv) {
    if (argc < 5)
        return 1;
    std::string vec = argv[3], want = argv[4];
    long only = argc > 5 ? std::stol(argv[5]) : -1;
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    if (ha.empty() || hb.empty())
        return 2;
    const design* da = (const design*)((uhdm_handle*)ha[0])->object;
    const design* db = (const design*)((uhdm_handle*)hb[0])->object;
    const instance* ia = nullptr;
    const instance* ib = nullptr;
    if (vec == "all") {
        ia = pick(da->AllModules(), want);
        ib = pick(db->AllModules(), want);
    }
    else if (vec == "top") {
        ia = pick(da->TopModules(), want);
        ib = pick(db->TopModules(), want);
    }
    else if (vec == "allpkg") {
        ia = pick(da->AllPackages(), want);
        ib = pick(db->AllPackages(), want);
    }
    else {
        ia = pick(da->TopPackages(), want);
        ib = pick(db->TopPackages(), want);
    }
    if (!ia || !ib) {
        std::cout << "not found\n";
        return 3;
    }
    auto* ta = ia->Typespecs();
    auto* tb = ib->Typespecs();
    size_t na = ta ? ta->size() : 0, nb = tb ? tb->size() : 0;
    for (size_t i = 0; i < na || i < nb; i++) {
        if (only >= 0 && (long)i != only)
            continue;
        std::cout << "TS[" << i << "]\n --- A\n";
        showTs(i < na ? (*ta)[i] : nullptr, "   ", 3);
        std::cout << " --- B\n";
        showTs(i < nb ? (*tb)[i] : nullptr, "   ", 3);
    }
    return 0;
}
