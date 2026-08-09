// r10earl16a — the EXPRESSION tree behind one listing member's typespec
// ranges, both sides, with every ref_obj's Actual_group and the OWNING
// package of that actual (with vpiTop).  r10earl15c stops at the range
// operands; § pkgTypespecInstanceIsTop's second half lives one level deeper:
// a module net/port range bound is an operation whose ref_obj actual is a
// PACKAGE PARAMETER, and which package COPY that parameter belongs to is the
// pointer uhdm-cmp follows.
// Build: bash tools/probe/r10earl16build.sh r10earl16a
// Usage: r10earl16a <a.uhdm> <b.uhdm> <all|top|allpkg|toppkg> <Listing> <Member>
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

// The nearest enclosing package/module of an object, by parent walk.
static std::string owner(const BaseClass* n) {
    const any* o = (const any*)n;
    for (int i = 0; i < 12 && o; i++) {
        if (o->UhdmType() == uhdmpackage || o->UhdmType() == uhdmmodule_inst)
            return at(o);
        o = o->VpiParent();
    }
    return "<no-owner>";
}

static const instance* tsInstOf(const typespec* t) {
    if (!t)
        return nullptr;
    if (auto* x = any_cast<const int_typespec*>((const any*)t))
        return x->Instance();
    if (auto* x = any_cast<const logic_typespec*>((const any*)t))
        return x->Instance();
    if (auto* x = any_cast<const bit_typespec*>((const any*)t))
        return x->Instance();
    if (auto* x = any_cast<const integer_typespec*>((const any*)t))
        return x->Instance();
    if (auto* x = any_cast<const struct_typespec*>((const any*)t))
        return x->Instance();
    if (auto* x = any_cast<const enum_typespec*>((const any*)t))
        return x->Instance();
    if (auto* x = any_cast<const array_typespec*>((const any*)t))
        return x->Instance();
    if (auto* x = any_cast<const packed_array_typespec*>((const any*)t))
        return x->Instance();
    if (auto* x = any_cast<const union_typespec*>((const any*)t))
        return x->Instance();
    return nullptr;
}

static void expTree(const any* e, const std::string& ind, int depth,
                    std::set<const any*>& seen) {
    if (!e || depth > 6)
        return;
    std::cout << ind << at(e) << "\n";
    if (!seen.insert(e).second)
        return;
    // EVERY expr carries a Typespec, and typespec::Compare recurses
    // Instance() — a range-bound CONSTANT whose int_typespec is instanced at
    // the DEF package copy drags the whole compare into that package.
    if (auto* ex = any_cast<const expr*>(e))
        if (auto* rt = ex->Typespec()) {
            auto* a = rt->Actual_typespec();
            std::cout << ind << "  TS " << at(a) << " inst="
                      << at(a ? tsInstOf(a) : nullptr) << "\n";
        }
    if (e->UhdmType() == uhdmref_obj) {
        auto* r = (const ref_obj*)e;
        const any* ag = r->Actual_group();
        std::cout << ind << "  ACTUAL " << at(ag) << "\n";
        std::cout << ind << "  OWNER  " << owner(ag) << "\n";
        return;
    }
    if (e->UhdmType() == uhdmoperation)
        if (auto* ops = ((const operation*)e)->Operands())
            for (auto* op : *ops)
                expTree(op, ind + "  ", depth + 1, seen);
}

static VectorOfrange* rangesOf(const typespec* t) {
    if (!t)
        return nullptr;
    if (auto* x = any_cast<const logic_typespec*>((const any*)t))
        return x->Ranges();
    if (auto* x = any_cast<const bit_typespec*>((const any*)t))
        return x->Ranges();
    if (auto* x = any_cast<const array_typespec*>((const any*)t))
        return x->Ranges();
    if (auto* x = any_cast<const packed_array_typespec*>((const any*)t))
        return x->Ranges();
    return nullptr;
}

static const ref_typespec* elemOf(const typespec* t) {
    if (!t)
        return nullptr;
    if (auto* x = any_cast<const array_typespec*>((const any*)t))
        return x->Elem_typespec();
    if (auto* x = any_cast<const packed_array_typespec*>((const any*)t))
        return x->Elem_typespec();
    // logic/bit typespecs carry an Elem_typespec too — `sha_word_t [7:0] d`
    // is a logic_typespec whose ELEMENT is the package typedef, and
    // logic_typespec::Compare walks it.
    if (auto* x = any_cast<const logic_typespec*>((const any*)t))
        return x->Elem_typespec();
    return nullptr;
}

static void tsWalk(const typespec* t, const std::string& ind, int depth) {
    if (!t || depth > 4)
        return;
    std::cout << ind << at(t) << " inst=" << at(tsInstOf(t)) << "\n";
    if (auto* al = t->Typedef_alias()) {
        auto* aa = al->Actual_typespec();
        std::cout << ind << "  ALIAS '" << al->VpiFullName() << "' -> " << at(aa)
                  << " inst=" << at(aa ? tsInstOf(aa) : nullptr) << "\n";
    }
    if (auto* rs = rangesOf(t))
        for (size_t i = 0; i < rs->size(); i++) {
            std::set<const any*> s1, s2;
            std::cout << ind << " rng[" << i << "] LEFT\n";
            expTree((*rs)[i]->Left_expr(), ind + "   ", 0, s1);
            std::cout << ind << " rng[" << i << "] RIGHT\n";
            expTree((*rs)[i]->Right_expr(), ind + "   ", 0, s2);
        }
    if (auto* el = elemOf(t))
        tsWalk(el->Actual_typespec(), ind + "  ", depth + 1);
    if (auto* en = any_cast<const enum_typespec*>((const any*)t)) {
        if (auto* br = en->Base_typespec()) {
            std::cout << ind << "  BASE\n";
            tsWalk(br->Actual_typespec(), ind + "    ", depth + 1);
        }
        if (auto* ecs = en->Enum_consts())
            for (auto* ec : *ecs) {
                // NOTE (pass 17): enum_const derives straight from BaseClass
                // in this UHDM — it has no Typespec accessor at all, so the
                // pass-16 source did not compile here.  enum_const::Compare
                // reads only the scalars, so there is nothing to descend.
                std::cout << ind << "  EC " << at(ec) << "\n";
            }
    }
    if (auto* st = any_cast<const struct_typespec*>((const any*)t))
        if (auto* ms = st->Members())
            for (auto* m : *ms) {
                std::cout << ind << "  MEM " << at(m) << "\n";
                if (m->Typespec())
                    tsWalk(m->Typespec()->Actual_typespec(), ind + "    ",
                           depth + 1);
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
        if (rt)
            tsWalk(rt->Actual_typespec(), "    ", 0);
        // The OBJECT's own ranges / bounds (a net carries them beside its
        // typespec, and logic_net::Compare walks them).
        if (auto* n = any_cast<const logic_net*>((const any*)o)) {
            std::set<const any*> s1, s2;
            if (n->Left_expr()) {
                std::cout << "    OWN Left_expr\n";
                expTree(n->Left_expr(), "      ", 0, s1);
            }
            if (n->Right_expr()) {
                std::cout << "    OWN Right_expr\n";
                expTree(n->Right_expr(), "      ", 0, s2);
            }
            if (auto* rs = n->Ranges())
                for (size_t i = 0; i < rs->size(); i++) {
                    std::set<const any*> a1, a2;
                    std::cout << "    OWN rng[" << i << "] LEFT\n";
                    expTree((*rs)[i]->Left_expr(), "      ", 0, a1);
                    std::cout << "    OWN rng[" << i << "] RIGHT\n";
                    expTree((*rs)[i]->Right_expr(), "      ", 0, a2);
                }
        }
        if (auto* p = any_cast<const port*>((const any*)o)) {
            if (p->High_conn()) {
                std::set<const any*> h1;
                std::cout << "    HIGH_CONN\n";
                expTree(p->High_conn(), "      ", 0, h1);
            }
            if (p->Low_conn()) {
                std::set<const any*> l1;
                std::cout << "    LOW_CONN\n";
                expTree(p->Low_conn(), "      ", 0, l1);
            }
        }
    };
    // "ts:<substr>" lists the listing's OWN Typespecs vector instead.
    if (pname.rfind("ts:", 0) == 0) {
        std::string want2 = pname.substr(3);
        if (in->Typespecs())
            for (auto* t : *in->Typespecs())
                if (want2.empty() ||
                    std::string(t->VpiName()).find(want2) != std::string::npos)
                    tsWalk(t, "  ", 0);
        return;
    }
    if (in->Nets())
        for (auto* n : *in->Nets())
            if (n->VpiName() == pname)
                show(n, n->Typespec());
    if (in->Variables())
        for (auto* v : *in->Variables())
            if (v->VpiName() == pname)
                show(v, v->Typespec());
    if (in->Parameters())
        for (auto* p : *in->Parameters())
            if (p->VpiName() == pname && p->UhdmType() == uhdmparameter)
                show(p, ((const parameter*)p)->Typespec());
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
