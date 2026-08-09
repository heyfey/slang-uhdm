// r10earl14f — the TYPESPEC BEHIND EVERY EXPRESSION of a listing's param_assign
// rows, with that typespec's own Instance() / Cast_to_expr() / ranges.
// UhdmListener does NOT follow a typespec's Instance() back-edge but Compare
// DOES, so the pass-14 "golden points at X, we point at nothing" heads are
// invisible to every listener probe: the owning object is a typespec reached
// only through an expression's ref_typespec.  This is the projection that shows
// it.
// Build: bash tools/probe/r10earl14build.sh r10earl14f
// Usage: r10earl14f <a.uhdm> <b.uhdm> <all|top|allpkg|toppkg> <Name> [row]
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
    if (const instance* in = any_cast<const instance*>((const any*)n))
        s += " {top=" + std::to_string((int)in->VpiTop()) + "}";
    return s;
}

static void tsInfo(const typespec* t, const std::string& ind) {
    if (!t)
        return;
    const instance* inst = nullptr;
    const expr* cast = nullptr;
    VectorOfrange* rgs = nullptr;
    if (auto* x = any_cast<const int_typespec*>((const any*)t)) {
        inst = x->Instance();
        cast = x->Cast_to_expr();
        rgs = x->Ranges();
    }
    else if (auto* x = any_cast<const logic_typespec*>((const any*)t)) {
        inst = x->Instance();
        rgs = x->Ranges();
    }
    else if (auto* x = any_cast<const bit_typespec*>((const any*)t)) {
        inst = x->Instance();
        rgs = x->Ranges();
    }
    else if (auto* x = any_cast<const packed_array_typespec*>((const any*)t)) {
        inst = x->Instance();
        rgs = x->Ranges();
    }
    else if (auto* x = any_cast<const array_typespec*>((const any*)t)) {
        inst = x->Instance();
        rgs = x->Ranges();
    }
    else if (auto* x = any_cast<const integer_typespec*>((const any*)t))
        inst = x->Instance();
    else if (auto* x = any_cast<const struct_typespec*>((const any*)t))
        inst = x->Instance();
    else if (auto* x = any_cast<const enum_typespec*>((const any*)t))
        inst = x->Instance();
    std::cout << ind << "  ts=" << at(t) << " inst=" << at(inst)
              << " cast=" << at(cast) << "\n";
    if (rgs)
        for (size_t i = 0; i < rgs->size(); i++)
            std::cout << ind << "    rng[" << i << "] L=" << at((*rgs)[i]->Left_expr())
                      << " R=" << at((*rgs)[i]->Right_expr()) << "\n";
}

static void walk(const any* n, const std::string& ind) {
    if (!n) {
        std::cout << ind << "<null>\n";
        return;
    }
    std::cout << ind << at(n) << "\n";
    if (auto* e = any_cast<const expr*>(n))
        if (e->Typespec())
            tsInfo(e->Typespec()->Actual_typespec(), ind);
    if (n->UhdmType() == uhdmoperation) {
        if (auto* ops = ((const operation*)n)->Operands())
            for (auto* o : *ops)
                walk(o, ind + "  ");
    }
    else if (n->UhdmType() == uhdmsys_func_call) {
        if (auto* as = ((const sys_func_call*)n)->Tf_call_args())
            for (auto* o : *as)
                walk(o, ind + "  ");
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
    auto* va = ia->Param_assigns();
    auto* vb = ib->Param_assigns();
    if (!va || !vb)
        return 4;
    for (size_t i = 0; i < va->size() && i < vb->size(); i++) {
        if (only >= 0 && (long)i != only)
            continue;
        std::cout << "[" << i << "] "
                  << ((*va)[i]->Lhs() ? (*va)[i]->Lhs()->VpiName() : "?") << "\n";
        std::cout << " --- A\n";
        walk((*va)[i]->Rhs(), "   ");
        std::cout << " --- B\n";
        walk((*vb)[i]->Rhs(), "   ");
    }
    return 0;
}
