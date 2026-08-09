// r10earl14e — the TYPESPEC-side fields of a listing's parameters: Instance(),
// Cast_to_expr() and the range bounds.  § pkgTypespecInstanceIsTop and the
// "golden points at an expression where we point at nothing" heads both live on
// a typespec member that no param_assign / expression probe prints.
// Build: bash tools/probe/r10earl14build.sh r10earl14e
// Usage: r10earl14e <a.uhdm> <b.uhdm> <all|top|allpkg|toppkg> <Name>
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

static void showTs(const char* tag, const typespec* t) {
    if (!t) {
        std::cout << "    " << tag << " <null>\n";
        return;
    }
    std::cout << "    " << tag << " " << at(t);
    const instance* inst = nullptr;
    const expr* cast = nullptr;
    VectorOfrange* rgs = nullptr;
    auto grabInst = [&](auto* x) { inst = x->Instance(); };
    auto grabCast = [&](auto* x) { cast = x->Cast_to_expr(); };
    auto grabRgs = [&](auto* x) { rgs = x->Ranges(); };
    if (auto* x = any_cast<const int_typespec*>((const any*)t)) {
        grabInst(x);
        grabCast(x);
        grabRgs(x);
    }
    else if (auto* x = any_cast<const integer_typespec*>((const any*)t))
        grabInst(x);
    else if (auto* x = any_cast<const logic_typespec*>((const any*)t)) {
        grabInst(x);
        grabRgs(x);
    }
    else if (auto* x = any_cast<const bit_typespec*>((const any*)t)) {
        grabInst(x);
        grabRgs(x);
    }
    else if (auto* x = any_cast<const byte_typespec*>((const any*)t))
        grabInst(x);
    else if (auto* x = any_cast<const packed_array_typespec*>((const any*)t)) {
        grabInst(x);
        grabRgs(x);
    }
    else if (auto* x = any_cast<const array_typespec*>((const any*)t)) {
        grabInst(x);
        grabRgs(x);
    }
    else if (auto* x = any_cast<const struct_typespec*>((const any*)t))
        grabInst(x);
    else if (auto* x = any_cast<const enum_typespec*>((const any*)t))
        grabInst(x);
    std::cout << " inst=" << at(inst) << " cast=" << at(cast) << "\n";
    if (rgs)
        for (size_t i = 0; i < rgs->size(); i++)
            std::cout << "      range[" << i << "] L=" << at((*rgs)[i]->Left_expr())
                      << " R=" << at((*rgs)[i]->Right_expr()) << "\n";
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
    auto* va = ia->Parameters();
    auto* vb = ib->Parameters();
    size_t na = va ? va->size() : 0, nb = vb ? vb->size() : 0;
    for (size_t i = 0; i < na || i < nb; i++) {
        const parameter* pa = i < na ? any_cast<const parameter*>((*va)[i]) : nullptr;
        const parameter* pb = i < nb ? any_cast<const parameter*>((*vb)[i]) : nullptr;
        std::cout << "[" << i << "] " << (pa ? pa->VpiName() : "?") << "\n";
        if (pa) {
            CompareContext c;
            int r = pb ? pa->Compare(pb, &c) : -9;
            std::cout << "    cmp r=" << r << " failLhs=" << at(c.m_failedLhs)
                      << " failRhs=" << at(c.m_failedRhs) << "\n";
        }
        // parameter carries its OWN Left_range/Right_range/Expr pointers, which
        // no param_assign probe prints; these are the SafeCompare-null suspects.
        if (pa)
            std::cout << "    A.LR=" << at(pa->Left_range())
                      << " RR=" << at(pa->Right_range()) << " Expr=" << at(pa->Expr())
                      << "\n";
        if (pb)
            std::cout << "    B.LR=" << at(pb->Left_range())
                      << " RR=" << at(pb->Right_range()) << " Expr=" << at(pb->Expr())
                      << "\n";
        showTs("A.ts", pa && pa->Typespec() ? pa->Typespec()->Actual_typespec() : nullptr);
        showTs("B.ts", pb && pb->Typespec() ? pb->Typespec()->Actual_typespec() : nullptr);
    }
    // The listing's own Typespecs() vector, same projection.
    auto* ta = ia->Typespecs();
    auto* tb = ib->Typespecs();
    size_t ma = ta ? ta->size() : 0, mb = tb ? tb->size() : 0;
    for (size_t i = 0; i < ma || i < mb; i++) {
        std::cout << "TS[" << i << "]\n";
        showTs("A", i < ma ? (*ta)[i] : nullptr);
        showTs("B", i < mb ? (*tb)[i] : nullptr);
    }
    return 0;
}
