// r10earl5ts: FIELD-BY-FIELD typespec compare inside one named package
// listing.  r10earl4pc says "typespec N DIFF, failLhs ref_typespec '' 0:0 vs
// <null>" and stops there — a parentless, fileless ref_typespec is invisible
// in a dump AND its owner is not named by CompareContext.  This probe walks
// the typespec's OWN ref_typespec-valued fields (Typedef_alias, and for a
// struct/enum its members / base) on BOTH sides and prints which one is the
// null.
// Usage: r10earl5ts <a.uhdm> <b.uhdm> <PkgName> [top|all] [tsIndex]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string rt(const ref_typespec* r) {
    if (!r) return "<null>";
    std::string s = "ref_typespec '" + std::string(r->VpiName()) + "' " +
                    std::to_string(r->VpiLineNo()) + ":" +
                    std::to_string(r->VpiColumnNo());
    const typespec* a = r->Actual_typespec();
    s += " -> " + (a ? std::string(UhdmName(a->UhdmType())) + " '" +
                           std::string(a->VpiName()) + "' " +
                           std::to_string(a->VpiLineNo())
                     : std::string("<null actual>"));
    s += r->VpiParent() ? " (parented)" : " (PARENTLESS)";
    return s;
}

static std::string tsn(const typespec* t) {
    if (!t) return "<null>";
    return std::string(UhdmName(t->UhdmType())) + " '" +
           std::string(t->VpiName()) + "' " + std::to_string(t->VpiLineNo()) +
           ":" + std::to_string(t->VpiColumnNo());
}

static std::string ex(const any* e) {
    if (!e) return "<null>";
    std::string s = std::string(UhdmName(e->UhdmType())) + " '" +
                    std::string(e->VpiName()) + "' " +
                    std::to_string(e->VpiLineNo()) + ":" +
                    std::to_string(e->VpiColumnNo());
    if (e->UhdmType() == uhdmconstant) {
        auto* c = (const constant*)e;
        s += " {ct=" + std::to_string(c->VpiConstType()) +
             " sz=" + std::to_string(c->VpiSize()) + " dec='" +
             std::string(c->VpiDecompile()) + "' val='" +
             std::string(c->VpiValue()) + "'}";
    }
    if (auto* xe = any_cast<const expr*>(e)) s += " ts=" + rt(xe->Typespec());
    return s;
}

static void one(const typespec* t, const char* tag, int depth = 0);

static void ts_detail(const typespec* t, const std::string& ind, int depth) {
    if (t->UhdmType() == uhdmstruct_typespec) {
        auto* m = ((const struct_typespec*)t)->Members();
        std::cout << ind << "members=" << (m ? m->size() : 0) << "\n";
        if (m)
            for (auto* mm : *m) {
                std::cout << ind << "  '" << mm->VpiName() << "' ts=" << rt(mm->Typespec())
                          << "\n";
                if (depth > 0 && mm->Typespec() && mm->Typespec()->Actual_typespec()) {
                    const typespec* at = mm->Typespec()->Actual_typespec();
                    std::cout << ind << "    alias=" << rt(at->Typedef_alias())
                              << " inst="
                              << (at->Instance() ? std::string(at->Instance()->VpiName())
                                                 : std::string("<null>"))
                              << "\n";
                    ts_detail(at, ind + "    ", depth - 1);
                }
            }
    }
    else if (t->UhdmType() == uhdmenum_typespec) {
        auto* e = (const enum_typespec*)t;
        std::cout << ind << "base=" << rt(e->Base_typespec()) << "\n";
        if (depth > 0 && e->Base_typespec() && e->Base_typespec()->Actual_typespec())
            ts_detail(e->Base_typespec()->Actual_typespec(), ind + "    ", depth - 1);
        auto* c = e->Enum_consts();
        std::cout << ind << "consts=" << (c ? c->size() : 0) << "\n";
        if (c)
            for (auto* cc : *c) std::cout << ind << "  " << ex(cc) << "\n";
    }
    else if (t->UhdmType() == uhdmlogic_typespec) {
        auto* r = ((const logic_typespec*)t)->Ranges();
        std::cout << ind << "ranges=" << (r ? r->size() : 0) << "\n";
        if (r)
            for (auto* rr : *r)
                std::cout << ind << "  L " << ex(rr->Left_expr()) << "\n"
                          << ind << "  R " << ex(rr->Right_expr()) << "\n";
    }
    else if (t->UhdmType() == uhdmarray_typespec) {
        auto* a = (const array_typespec*)t;
        std::cout << ind << "elem=" << rt(a->Elem_typespec()) << "\n";
        auto* r = a->Ranges();
        std::cout << ind << "ranges=" << (r ? r->size() : 0) << "\n";
        if (r)
            for (auto* rr : *r)
                std::cout << ind << "  L " << ex(rr->Left_expr()) << "\n"
                          << ind << "  R " << ex(rr->Right_expr()) << "\n";
    }
}

static void one(const typespec* t, const char* tag, int depth) {
    std::cout << "    " << tag << " " << tsn(t) << "\n";
    if (!t) return;
    std::cout << "      alias=" << rt(t->Typedef_alias())
              << " inst=" << (t->Instance() ? std::string(t->Instance()->VpiName()) +
                                                  " top=" +
                                                  std::to_string(
                                                      (int)t->Instance()->VpiTop())
                                            : std::string("<null>"))
              << "\n";
    ts_detail(t, "      ", depth);
}

static const package* find(const design* d, const std::string& nm, bool top) {
    auto* v = top ? d->TopPackages() : d->AllPackages();
    if (v)
        for (auto* p : *v)
            if (std::string(p->VpiName()) == nm) return p;
    return nullptr;
}

int main(int argc, char** argv) {
    if (argc < 4) return 1;
    bool top = argc > 4 && std::string(argv[4]) == "top";
    long only = argc > 5 ? std::stol(argv[5]) : -1;
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    if (ha.empty() || hb.empty()) return 2;
    const design* da = (const design*)((uhdm_handle*)ha[0])->object;
    const design* db = (const design*)((uhdm_handle*)hb[0])->object;
    const package* pa = find(da, argv[3], top);
    const package* pb = find(db, argv[3], top);
    if (!pa || !pb) { std::cout << "package not found\n"; return 3; }
    auto* ta = pa->Typespecs();
    auto* tb = pb->Typespecs();
    std::cout << "typespecs " << (ta ? ta->size() : 0) << " vs "
              << (tb ? tb->size() : 0) << "\n";
    if (!ta || !tb) return 0;
    for (size_t i = 0; i < std::min(ta->size(), tb->size()); i++) {
        if (only >= 0 && (long)i != only) continue;
        CompareContext ctx;
        int r = (*ta)[i]->Compare((*tb)[i], &ctx);
        std::cout << (r ? "  DIFF " : "  ok   ") << i << " " << tsn((*ta)[i]) << "\n";
        one((*ta)[i], "A", 3);
        one((*tb)[i], "B", 3);
    }
    return 0;
}
