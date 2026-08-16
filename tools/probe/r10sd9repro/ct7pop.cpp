// r10sd7 — THE POPULATION CENSUS THAT DECIDES.  Every typespec in the WHOLE
// TYPESPEC SUBTREE of every class-listing variable, on both sides, with its
// DEPTH and its `vpiInstance` view.
//
// `ct5cls` (sd5) and `ct6clsref` (sd6) both stop at DEPTH 0 — the variable's own
// actual typespec — and at depth 0 the two sides already agree (63 stamped
// entries each, `ct7own`).  The head this pass closes is at DEPTH 1: the
// `Index_typespec` of an associative array's `array_typespec`.  A census that
// cannot see depth 1 reports the listing as converged, which is exactly what
// sd6 R1 inherited.
//
// DEPTH 0 IS PRINTED TOO, AND MUST NOT MOVE.  Golden stamps 63 depth-0
// class-listing typespecs and we stamp the same 63; those are the classes' OWN
// variables and a blanket null would destroy all of them.  That row is the
// control that forbids the tempting phrasing "a class-listing typespec has no
// instance".
//
// GUARD: zero rows is a hard error.
//
// build: g++ -O2 -std=c++17 ct7pop.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct7pop
// usage: ct7pop <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <set>
#include <string>
#include <vector>
#include <algorithm>

using namespace UHDM;

static std::set<const BaseClass*> g_all, g_top;
static std::string span(const BaseClass* p) {
    return std::to_string(p->VpiLineNo()) + ":" + std::to_string(p->VpiColumnNo()) + "-" +
           std::to_string(p->VpiEndLineNo()) + ":" + std::to_string(p->VpiEndColumnNo());
}
static std::string ident(const BaseClass* p) {
    if (!p) return "<null>";
    std::string s = UhdmName(p->UhdmType());
    std::string nm(p->VpiName());
    if (!nm.empty()) s += "(" + nm + ")";
    return s + "@" + span(p);
}
static std::string view(const instance* i) {
    if (!i) return "<null>";
    std::string nm(i->VpiName());
    if (g_top.count(i)) return "TOP:" + nm;
    if (g_all.count(i)) return "ALL:" + nm;
    return "OTHER:" + nm;
}

static std::vector<std::string> g_rows;
static std::map<std::string, int> g_sum;

static void walk(const std::string& owner, const std::string& path, const typespec* t,
                 int depth) {
    if (!t || depth > 5) return;
    g_rows.push_back(owner + " | d" + std::to_string(depth) + " " + path + " | " +
                     ident(t) + " | inst=" + view(t->Instance()));
    g_sum["d" + std::to_string(depth) + "  inst=" + (t->Instance() ? "SET" : "<null>")]++;
    auto sub = [&](const char* lbl, const ref_typespec* r) {
        if (r) walk(owner, path + "/" + lbl, r->Actual_typespec(), depth + 1);
    };
    switch (t->UhdmType()) {
        case uhdmarray_typespec: {
            auto* a = (const array_typespec*)t;
            sub("index", a->Index_typespec());
            sub("elem", a->Elem_typespec());
            break;
        }
        case uhdmpacked_array_typespec: {
            auto* a = (const packed_array_typespec*)t;
            sub("elem", a->Elem_typespec());
            break;
        }
        default: break;
    }
    sub("alias", t->Typedef_alias());
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: ct7pop <db>\n"; return 2; }
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    if (h.empty()) { std::cerr << "RESTORE FAILED\n"; return 3; }
    auto* d = (design*)((uhdm_handle*)h[0])->object;
    if (auto* v = d->AllPackages()) for (auto* p : *v) g_all.insert(p);
    if (auto* v = d->TopPackages()) for (auto* p : *v) g_top.insert(p);
    size_t ncls = 0;
    for (const auto& [obj, id] : s.AllObjects()) {
        if (!obj || obj->UhdmType() != uhdmclass_defn) continue;
        auto* cd = (class_defn*)obj;
        ncls++;
        if (!cd->Variables()) continue;
        std::string cn(cd->VpiFullName().empty() ? cd->VpiName() : cd->VpiFullName());
        for (auto* v : *cd->Variables()) {
            if (!v || !v->Typespec()) continue;
            walk(cn + "@" + span(cd) + " :: " + std::string(v->VpiName()), "ts",
                 v->Typespec()->Actual_typespec(), 0);
        }
    }
    // MULTISET, sorted: the join between two databases is by CONTENT, and the
    // vector order is already proved equal at depth 0 by ct7own.
    std::sort(g_rows.begin(), g_rows.end());
    for (auto& r : g_rows) std::cout << r << "\n";
    std::cout << "[S] class_defns=" << ncls << " rows=" << g_rows.size() << "\n";
    for (auto& [k, n] : g_sum) std::cout << "    " << n << "\t" << k << "\n";
    if (g_rows.empty()) { std::cerr << "REFUSING TO REPORT: empty population\n"; return 5; }
    return 0;
}
