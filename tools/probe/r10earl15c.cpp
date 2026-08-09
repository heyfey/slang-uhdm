// r10earl15c — the FULL TYPESPEC TREE behind one parameter of one listing,
// both sides, with every node's Instance() back-edge.  r10earl14e prints the
// parameter's own typespec and its ranges but stops there; § pkgTypespecInstanceIsTop
// lives one level deeper (an unpacked-array parameter's ELEMENT typespec).
// Build: bash tools/probe/r10earl15build.sh r10earl15c
// Usage: r10earl15c <a.uhdm> <b.uhdm> <all|top|allpkg|toppkg> <Listing> <Param>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <set>
#include <string>
using namespace UHDM;

static std::string base(std::string_view f) {
    size_t p = f.rfind('/');
    return std::string(p == std::string_view::npos ? f : f.substr(p + 1));
}

static std::string at(const BaseClass* n) {
    if (!n)
        return "<null>";
    std::string s = std::string(UhdmName(n->UhdmType())) + " '" +
                    std::string(n->VpiName()) + "' " + base(n->VpiFile()) + ":" +
                    std::to_string(n->VpiLineNo()) + ":" +
                    std::to_string(n->VpiColumnNo()) +
                    " uid=" + std::to_string(n->UhdmId());
    if (n->UhdmType() == uhdmconstant) {
        auto* c = (const constant*)n;
        s += " {ct=" + std::to_string(c->VpiConstType()) +
             " sz=" + std::to_string(c->VpiSize()) + " dec=" +
             std::string(c->VpiDecompile()) + "}";
    }
    if (n->UhdmType() == uhdmoperation)
        s += " {op=" + std::to_string(((const operation*)n)->VpiOpType()) + "}";
    if (const instance* in = any_cast<const instance*>((const any*)n))
        s += " {top=" + std::to_string((int)in->VpiTop()) +
             " uid=" + std::to_string(in->UhdmId()) + "}";
    return s;
}

static const instance* tsInst(const typespec* t) {
    if (auto* x = any_cast<const int_typespec*>((const any*)t))
        return x->Instance();
    if (auto* x = any_cast<const logic_typespec*>((const any*)t))
        return x->Instance();
    if (auto* x = any_cast<const bit_typespec*>((const any*)t))
        return x->Instance();
    if (auto* x = any_cast<const packed_array_typespec*>((const any*)t))
        return x->Instance();
    if (auto* x = any_cast<const array_typespec*>((const any*)t))
        return x->Instance();
    if (auto* x = any_cast<const integer_typespec*>((const any*)t))
        return x->Instance();
    if (auto* x = any_cast<const struct_typespec*>((const any*)t))
        return x->Instance();
    if (auto* x = any_cast<const enum_typespec*>((const any*)t))
        return x->Instance();
    if (auto* x = any_cast<const union_typespec*>((const any*)t))
        return x->Instance();
    return nullptr;
}

static void tsTree(const typespec* t, const std::string& ind, int depth,
                   std::set<const BaseClass*>& seen) {
    if (!t || depth > 5)
        return;
    std::cout << ind << at(t) << "  inst=" << at(tsInst(t)) << "\n";
    if (!seen.insert(t).second) {
        std::cout << ind << "  (already seen)\n";
        return;
    }
    if (auto* al = t->Typedef_alias()) {
        std::cout << ind << "  ALIAS ref_typespec '" << al->VpiFullName()
                  << "' -> " << at(al->Actual_typespec()) << " inst="
                  << at(al->Actual_typespec()
                            ? tsInst((const typespec*)al->Actual_typespec())
                            : nullptr)
                  << "\n";
    }
    const ref_typespec* elem = nullptr;
    VectorOfrange* rgs = nullptr;
    if (auto* x = any_cast<const array_typespec*>((const any*)t)) {
        elem = x->Elem_typespec();
        rgs = x->Ranges();
    }
    else if (auto* x = any_cast<const packed_array_typespec*>((const any*)t)) {
        elem = x->Elem_typespec();
        rgs = x->Ranges();
    }
    else if (auto* x = any_cast<const logic_typespec*>((const any*)t))
        rgs = x->Ranges();
    else if (auto* x = any_cast<const bit_typespec*>((const any*)t))
        rgs = x->Ranges();
    if (rgs)
        for (size_t i = 0; i < rgs->size(); i++)
            std::cout << ind << "  rng[" << i
                      << "] L=" << at((*rgs)[i]->Left_expr())
                      << " R=" << at((*rgs)[i]->Right_expr()) << "\n";
    if (elem) {
        std::cout << ind << "  ELEM ref_typespec '" << elem->VpiFullName()
                  << "'\n";
        tsTree(elem->Actual_typespec(), ind + "    ", depth + 1, seen);
    }
    if (auto* st = any_cast<const struct_typespec*>((const any*)t))
        if (auto* ms = st->Members())
            for (auto* m : *ms) {
                std::cout << ind << "  MEM " << at(m) << "\n";
                if (m->Typespec())
                    tsTree(m->Typespec()->Actual_typespec(), ind + "    ",
                           depth + 1, seen);
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

static void one(const instance* in, const std::string& pname, const char* tag) {
    std::cout << "--- " << tag << "\n";
    if (!in)
        return;
    auto show = [&](const BaseClass* o, const ref_typespec* rt) {
        std::cout << "  " << at(o) << "\n";
        std::set<const BaseClass*> seen;
        if (rt)
            tsTree(rt->Actual_typespec(), "    ", 0, seen);
    };
    if (in->Parameters())
        for (auto* p : *in->Parameters())
            if (p->VpiName() == pname && p->UhdmType() == uhdmparameter)
                show(p, ((const parameter*)p)->Typespec());
    if (in->Nets())
        for (auto* n : *in->Nets())
            if (n->VpiName() == pname)
                show(n, n->Typespec());
    if (in->Variables())
        for (auto* v : *in->Variables())
            if (v->VpiName() == pname)
                show(v, v->Typespec());
    if (auto* m = any_cast<const module_inst*>((const any*)in))
        if (m->Ports())
            for (auto* p : *m->Ports())
                if (p->VpiName() == pname)
                    show(p, p->Typespec());
}

int main(int argc, char** argv) {
    if (argc < 6)
        return 1;
    std::string vec = argv[3], want = argv[4], pname = argv[5];
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
    one(ia, pname, "A");
    one(ib, pname, "B");
    return 0;
}
