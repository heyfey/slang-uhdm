// r10sd8 — THE POPULATION CENSUS THAT DECIDES, EXTENDED TO THE ELEMENT VARIABLE.
//
// sd7's `ct7pop` walks a class-listing variable's TYPESPEC subtree
// (`Index_typespec` / `Elem_typespec` / `Typedef_alias`) and stops there.  That
// is not the whole subtree an UNPACKED ARRAY variable owns: `array_var` also
// carries `Variables()` — one ELEMENT VARIABLE per array — and the element
// variable has a typespec of its own, with its own `vpiInstance`.  `ct8head
// --brute` names exactly that object as the head:
//
//   class_typespec(uvm_seed_map)@328:1-328:13
//     < ref_typespec < class_var@328:14-328:42
//     < array_var(uvm_random_seed_table_lookup)@328:14-328:42
//     < class_defn(adpcm_seq_item) < package(adpcm_pkg)
//
// sd7 §2.1 concluded "the Elem_typespec arm never fires — no `ts/elem` row
// exists on either side", and that is TRUE and MISLEADING: an associative
// array's element TYPE is not reached through `array_typespec::Elem_typespec`
// in these databases at all, it is reached through the element VARIABLE.  This
// census prints both spellings so the two can never be confused again.
//
// PATHS printed:
//   ts, ts/index, ts/elem, ts/alias           <- sd7's subtree (depth 0..n)
//   var/ts, var/ts/index, var/ts/elem, ...    <- THIS pass's: the element var
//
// DEPTH 0 IS PRINTED AS THE CONTROL and must not move: golden stamps 63
// depth-0 class-listing typespecs and we stamp the same 63.
//
// GUARD: zero rows is a hard error.
//
// build: g++ -O2 -std=c++17 ct8pop.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct8pop
// usage: ct8pop <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <map>
#include <set>
#include <string>
#include <vector>

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

static void walkTs(const std::string& owner, const std::string& path, const typespec* t,
                   int depth) {
    if (!t || depth > 5) return;
    g_rows.push_back(owner + " | d" + std::to_string(depth) + " " + path + " | " + ident(t) +
                     " | inst=" + view(t->Instance()));
    g_sum["d" + std::to_string(depth) + " " + path + "  inst=" +
          (t->Instance() ? "SET" : "<null>")]++;
    auto sub = [&](const char* lbl, const ref_typespec* r) {
        if (r) walkTs(owner, path + "/" + lbl, r->Actual_typespec(), depth + 1);
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

static void walkVar(const std::string& owner, const std::string& path, const variables* v,
                    int depth) {
    if (!v || depth > 3) return;
    if (v->Typespec())
        walkTs(owner, path + "ts", v->Typespec()->Actual_typespec(), depth);
    if (v->UhdmType() == uhdmarray_var) {
        auto* av = (const array_var*)v;
        if (av->Variables())
            for (auto* ev : *av->Variables()) walkVar(owner, path + "var/", ev, depth + 1);
    }
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: ct8pop <db>\n"; return 2; }
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
            if (!v) continue;
            walkVar(cn + "@" + span(cd) + " :: " + std::string(v->VpiName()), "", v, 0);
        }
    }
    std::sort(g_rows.begin(), g_rows.end());
    for (auto& r : g_rows) std::cout << r << "\n";
    std::cout << "[S] class_defns=" << ncls << " rows=" << g_rows.size() << "\n";
    for (auto& [k, n] : g_sum) std::cout << "    " << n << "\t" << k << "\n";
    if (g_rows.empty()) { std::cerr << "REFUSING TO REPORT: empty population\n"; return 5; }
    return 0;
}
