// r10sd8 — WHO OWNS A STAMPED TYPESPEC.  The census that decides the law.
//
// ct8cens's 25 OURS_ONLY keys are all PARENTLESS typespecs, so `VpiParent()`
// says nothing about where they were declared.  The only way to score them is
// the REVERSE edge: every `ref_typespec` carries `Actual_typespec()` and hangs
// off the object that uses the type, so the ref_typespec's own parent chain is
// the declaration's scope chain.
//
// For every typespec this prints, keyed and counted:
//
//     <kind> <NAMED|ANON> inst=<view>  <- refKind  in <owning scope kind>
//
// where "owning scope kind" walks the referrer's parents to the first
// `package` / `class_defn` / `task_func` / `module_inst` it meets.  That is the
// cell that separates "a package-scope DATA DECLARATION's type" from "a class
// MEMBER's type" and from "a package TYPEDEF listing entry", which are three
// different populations that all produce a parentless class_typespec.
//
// GUARD: zero ref_typespecs, or zero typespecs reached, is a hard error.
//
// build: g++ -O2 -std=c++17 ct8own.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct8own
// usage: ct8own <db.uhdm> [--kind class_typespec] [--rows]
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

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: ct8own <db> [--kind K] [--rows]\n"; return 2; }
    std::string wantKind;
    bool wantRows = false;
    for (int i = 2; i < argc; i++) {
        std::string a = argv[i];
        if (a == "--kind" && i + 1 < argc) wantKind = argv[++i];
        else if (a == "--rows") wantRows = true;
    }
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    if (h.empty()) { std::cerr << "RESTORE FAILED " << argv[1] << "\n"; return 3; }
    auto* d = (design*)((uhdm_handle*)h[0])->object;
    std::set<const BaseClass*> allp, topp;
    if (auto* v = d->AllPackages()) for (auto* p : *v) allp.insert(p);
    if (auto* v = d->TopPackages()) for (auto* p : *v) topp.insert(p);
    auto view = [&](const instance* i) {
        if (!i) return std::string("<null>");
        std::string nm(i->VpiName());
        if (topp.count(i)) return "TOP:" + nm;
        if (allp.count(i)) return "ALL:" + nm;
        return "OTHER:" + nm;
    };

    // typespec -> referrers (the object the ref_typespec hangs off).
    std::map<const BaseClass*, std::vector<const BaseClass*>> refBy;
    size_t nref = 0;
    for (const auto& [obj, id] : s.AllObjects()) {
        if (!obj || obj->UhdmType() != uhdmref_typespec) continue;
        nref++;
        auto* rt = (ref_typespec*)obj;
        if (auto* at = rt->Actual_typespec()) refBy[at].push_back(rt->VpiParent());
    }
    if (!nref) { std::cerr << "REFUSING: zero ref_typespec objects\n"; return 5; }

    // First enclosing declaration scope of an object.
    auto scopeOf = [&](const BaseClass* o) {
        for (int i = 0; i < 12 && o; i++) {
            switch (o->UhdmType()) {
                case uhdmpackage: {
                    std::string nm(o->VpiName());
                    return (topp.count(o) ? "TOPPKG:" : allp.count(o) ? "ALLPKG:" : "PKG:") + nm;
                }
                case uhdmclass_defn: return std::string("CLASS");
                case uhdmfunction:
                case uhdmtask: return std::string("ROUTINE");
                case uhdmmodule_inst: return std::string("MODULE");
                case uhdmbegin:
                case uhdmnamed_begin: return std::string("BLOCK");
                default: break;
            }
            o = o->VpiParent();
        }
        return std::string("<detached>");
    };

    std::map<std::string, int> cens;
    size_t nts = 0;
    for (const auto& [obj, id] : s.AllObjects()) {
        if (!obj) continue;
        auto* t = any_cast<const typespec*>((const any*)obj);
        if (!t) continue;
        std::string kind = UhdmName(t->UhdmType());
        if (!wantKind.empty() && kind != wantKind) continue;
        nts++;
        std::string named = t->VpiName().empty() ? "ANON" : "NAMED";
        std::string par = t->VpiParent() ? "PARENTED" : "ORPHAN";
        auto it = refBy.find(obj);
        std::string ref = "<unreferenced>";
        if (it != refBy.end()) {
            std::set<std::string> rs;
            for (auto* r : it->second)
                rs.insert(std::string(r ? UhdmName(r->UhdmType()) : "<null>") + " in " + scopeOf(r));
            ref = "";
            for (auto& r : rs) ref += (ref.empty() ? "" : " & ") + r;
        }
        std::string k = kind + " " + named + " " + par + "  inst=" + view(t->Instance()) +
                        "  <- " + ref;
        cens[k]++;
        if (wantRows)
            std::cout << "ROW " << view(t->Instance()) << "  " << kind << "(" << t->VpiName()
                      << ")@" << t->VpiLineNo() << ":" << t->VpiColumnNo() << "-"
                      << t->VpiEndLineNo() << ":" << t->VpiEndColumnNo() << "  file="
                      << t->VpiFile() << "  <- " << ref << "\n";
    }
    std::vector<std::pair<int, std::string>> v;
    for (auto& [k, c] : cens) v.push_back({c, k});
    std::sort(v.rbegin(), v.rend());
    for (auto& [c, k] : v) std::cout << c << "\t" << k << "\n";
    std::cout << "[S] TYPESPECS=" << nts << " REF_TYPESPECS=" << nref << "\n";
    if (!nts) { std::cerr << "REFUSING: zero typespecs matched\n"; return 5; }
    return 0;
}
