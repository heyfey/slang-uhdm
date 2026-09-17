// r11u65 NET CENSUS + SHAPE LISTER.
//
// Prints ONE LINE PER NET object reachable from the design root, keyed on
//   view (DEF = design->AllModules/AllInterfaces/AllPackages,
//         ELAB = design->TopModules, walked recursively)
//   x scope path x net name x net UHDM kind,
// and carrying the COMPARE-VISIBLE payload `nets::Compare` reads for the net
// type -- `VpiNetType` -- beside the SHAPE that decides it: the net's own
// typespec chain (ref_typespec -> actual typespec kind, its VpiName when it
// carries one, and, for an array typespec, the element typespec kind).
//
// The shape is a PROXY for the source-level declared type: a net declared with
// an UNPACKED-ARRAY typedef carries an `array_typespec` (or a packed-array /
// logic typespec named after the typedef).  The census reads the database only;
// it runs no binary and reads no source.
//
// modes:
//   --list          one line per net (the SHAPE LISTER)
//   --shape         golden-vs-golden SHAPE CENSUS: (view, scope kind, net kind,
//                   ts kind, elem ts kind, named?) -> histogram of VpiNetType
//   --join A B      ours-vs-golden join on (view, path, name, kind):
//                   MATCH / NT-DIFF / ONLY-GOLDEN / ONLY-OURS
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <map>
#include <set>
#include <sstream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string kindName(const BaseClass* b) {
    return b ? std::string(UhdmName(b->UhdmType())) : std::string("-");
}

struct Row {
    std::string view, path, name, netkind, tskind, elemkind, tsname, scopekind;
    int32_t nt = 0;
    int line = 0;
    std::string key() const {
        return view + "|" + path + "|" + name + "|" + netkind;
    }
    std::string shape() const {
        return view + "|" + scopekind + "|" + netkind + "|" + tskind + "|" +
               elemkind + "|" + (tsname.empty() ? "-" : "named");
    }
};

static void tsShape(const nets* n, Row& r) {
    r.tskind = "-";
    r.elemkind = "-";
    r.tsname.clear();
    const ref_typespec* rt = n->Typespec();
    if (!rt)
        return;
    const typespec* at = rt->Actual_typespec();
    if (!at)
        return;
    r.tskind = kindName(at);
    r.tsname = std::string(at->VpiName());
    if (at->UhdmType() == uhdmarray_typespec) {
        auto* a = (const array_typespec*)at;
        const ref_typespec* er = a->Elem_typespec();
        const typespec* et = er ? er->Actual_typespec() : nullptr;
        r.elemkind = kindName(et);
    } else if (at->UhdmType() == uhdmpacked_array_typespec) {
        auto* a = (const packed_array_typespec*)at;
        const ref_typespec* er = a->Elem_typespec();
        const typespec* et = er ? er->Actual_typespec() : nullptr;
        r.elemkind = kindName(et);
    }
}

static void addNets(const instance* inst, const std::string& view,
                    const std::string& path, std::vector<Row>& out) {
    std::string sk = kindName(inst);
    if (inst->Nets())
        for (auto* n : *inst->Nets()) {
            if (!n) continue;
            Row r;
            r.view = view; r.path = path; r.scopekind = sk;
            r.name = std::string(n->VpiName());
            r.netkind = kindName(n);
            r.nt = n->VpiNetType();
            r.line = n->VpiLineNo();
            tsShape(n, r);
            out.push_back(r);
        }
    if (inst->Array_nets())
        for (auto* n : *inst->Array_nets()) {
            if (!n) continue;
            Row r;
            r.view = view; r.path = path; r.scopekind = sk;
            r.name = std::string(n->VpiName());
            r.netkind = kindName(n);
            r.nt = n->VpiNetType();
            r.line = n->VpiLineNo();
            tsShape(n, r);
            out.push_back(r);
        }
}

static void addScopeNets(const scope* sc, const std::string& view,
                         const std::string& path, std::vector<Row>& out) {
    std::string sk = kindName(sc);
    if (sc->UhdmType() == uhdmgen_scope) {
        auto* g = (const gen_scope*)sc;
        if (g->Nets())
            for (auto* n : *g->Nets()) {
                if (!n) continue;
                Row r;
                r.view = view; r.path = path; r.scopekind = sk;
                r.name = std::string(n->VpiName());
                r.netkind = kindName(n);
                r.nt = n->VpiNetType();
                r.line = n->VpiLineNo();
                tsShape(n, r);
                out.push_back(r);
            }
        if (g->Array_nets())
            for (auto* n : *g->Array_nets()) {
                if (!n) continue;
                Row r;
                r.view = view; r.path = path; r.scopekind = sk;
                r.name = std::string(n->VpiName());
                r.netkind = kindName(n);
                r.nt = n->VpiNetType();
                r.line = n->VpiLineNo();
                tsShape(n, r);
                out.push_back(r);
            }
    }
}

static void walkGenScope(const gen_scope* g, const std::string& view,
                         std::string path, std::vector<Row>& out, int depth);

static void walkInstance(const instance* inst, const std::string& view,
                         std::string path, std::vector<Row>& out, int depth) {
    if (!inst || depth > 24) return;
    std::string nm(inst->VpiName());
    if (nm.empty()) nm = std::string(inst->VpiDefName());
    path = path.empty() ? nm : path + "/" + nm;
    addNets(inst, view, path, out);
    if (inst->UhdmType() == uhdmmodule_inst) {
        auto* m = (const module_inst*)inst;
        if (m->Modules())
            for (auto* c : *m->Modules()) walkInstance(c, view, path, out, depth + 1);
        if (m->Module_arrays())
            for (auto* a : *m->Module_arrays())
                if (a->Modules())
                    for (auto* c : *a->Modules()) walkInstance(c, view, path, out, depth + 1);
        if (m->Interfaces())
            for (auto* c : *m->Interfaces()) walkInstance(c, view, path, out, depth + 1);
        if (m->Interface_arrays())
            for (auto* a : *m->Interface_arrays())
                if (a->Instances())
                    for (auto* c : *a->Instances()) walkInstance(c, view, path, out, depth + 1);
        if (m->Gen_scope_arrays())
            for (auto* ga : *m->Gen_scope_arrays())
                if (ga->Gen_scopes())
                    for (auto* g : *ga->Gen_scopes()) walkGenScope(g, view, path, out, depth + 1);
    } else if (inst->UhdmType() == uhdminterface_inst) {
        auto* m = (const interface_inst*)inst;
        if (m->Interfaces())
            for (auto* c : *m->Interfaces()) walkInstance(c, view, path, out, depth + 1);
        if (m->Gen_scope_arrays())
            for (auto* ga : *m->Gen_scope_arrays())
                if (ga->Gen_scopes())
                    for (auto* g : *ga->Gen_scopes()) walkGenScope(g, view, path, out, depth + 1);
    }
}

static void walkGenScope(const gen_scope* g, const std::string& view,
                         std::string path, std::vector<Row>& out, int depth) {
    if (!g || depth > 24) return;
    path = path + "/" + std::string(g->VpiName());
    addScopeNets(g, view, path, out);
    if (g->Modules())
        for (auto* c : *g->Modules()) walkInstance(c, view, path, out, depth + 1);
    if (g->Module_arrays())
        for (auto* a : *g->Module_arrays())
            if (a->Modules())
                for (auto* c : *a->Modules()) walkInstance(c, view, path, out, depth + 1);
    if (g->Interfaces())
        for (auto* c : *g->Interfaces()) walkInstance(c, view, path, out, depth + 1);
    if (g->Gen_scope_arrays())
        for (auto* ga : *g->Gen_scope_arrays())
            if (ga->Gen_scopes())
                for (auto* gg : *ga->Gen_scopes()) walkGenScope(gg, view, path, out, depth + 1);
}

static std::vector<Row> collect(const std::string& file) {
    std::vector<Row> out;
    Serializer s;
    auto h = s.Restore(std::filesystem::path(file));
    (void)h;
    for (auto& [obj, id] : s.AllObjects()) {
        if (!obj || obj->UhdmType() != uhdmdesign) continue;
        auto* d = (const design*)obj;
        if (d->AllModules())
            for (auto* m : *d->AllModules()) walkInstance(m, "DEF", "", out, 0);
        if (d->AllInterfaces())
            for (auto* m : *d->AllInterfaces()) walkInstance(m, "DEF", "", out, 0);
        if (d->AllPackages())
            for (auto* m : *d->AllPackages()) walkInstance(m, "DEF", "", out, 0);
        if (d->TopModules())
            for (auto* m : *d->TopModules()) walkInstance(m, "ELAB", "", out, 0);
    }
    return out;
}

static std::string rowline(const Row& r) {
    std::ostringstream o;
    o << r.view << "|" << r.path << "|" << r.name << "|" << r.netkind << "|"
      << r.tskind << "|" << r.elemkind << "|" << (r.tsname.empty() ? "-" : r.tsname)
      << "|NT=" << r.nt;
    return o.str();
}

int main(int argc, char** argv) {
    std::string mode = "--list", tag;
    std::vector<std::string> files;
    for (int i = 1; i < argc; i++) {
        std::string a(argv[i]);
        if (a.rfind("--tag=", 0) == 0) tag = a.substr(6);
        else if (a.rfind("--", 0) == 0) mode = a;
        else files.push_back(a);
    }
    if (files.empty()) { std::cerr << "usage: netcen65 [--list|--shape|--join] <db> [db2]\n"; return 2; }

    if (mode == "--join") {
        if (files.size() < 2) { std::cerr << "--join needs golden and ours\n"; return 2; }
        auto g = collect(files[0]);
        auto o = collect(files[1]);
        // MULTISET join: a key can repeat (two copies of one net).  Collect
        // the sorted multiset of NT values per key on each side and compare
        // the multisets -- a last-writer map would drop rows.
        std::map<std::string, std::vector<int32_t>> gm, om;
        std::map<std::string, Row> gr;
        for (auto& r : g) { gm[r.key()].push_back(r.nt); gr[r.key()] = r; }
        for (auto& r : o) om[r.key()].push_back(r.nt);
        for (auto& [k, v] : gm) std::sort(v.begin(), v.end());
        for (auto& [k, v] : om) std::sort(v.begin(), v.end());
        int match = 0, ntdiff = 0, onlyg = 0, onlyo = 0;
        for (auto& [k, v] : gm) {
            auto it = om.find(k);
            if (it == om.end()) { onlyg++; std::cout << "ONLY-GOLDEN " << tag << " " << k << " NT=" << v[0] << "\n"; continue; }
            if (it->second == v) { match++; continue; }
            ntdiff++;
            std::ostringstream gv, ov;
            for (auto x : v) gv << x << ",";
            for (auto x : it->second) ov << x << ",";
            std::cout << "NT-DIFF " << tag << " " << k << " golden=[" << gv.str()
                      << "] ours=[" << ov.str() << "] shape=" << gr[k].tskind << "/"
                      << gr[k].elemkind << " tsname=" << (gr[k].tsname.empty() ? "-" : gr[k].tsname) << "\n";
        }
        for (auto& [k, v] : om)
            if (!gm.count(k)) { onlyo++; std::cout << "ONLY-OURS " << tag << " " << k << " NT=" << v[0] << "\n"; }
        std::cout << "JOIN " << tag << " goldenKeys=" << gm.size() << " oursKeys=" << om.size()
                  << " MATCH=" << match << " NT-DIFF=" << ntdiff
                  << " ONLY-GOLDEN=" << onlyg << " ONLY-OURS=" << onlyo << "\n";
        return 0;
    }

    auto rows = collect(files[0]);
    if (mode == "--shape") {
        std::map<std::string, std::map<int32_t, int>> h;
        for (auto& r : rows) h[r.shape()][r.nt]++;
        for (auto& [sh, hist] : h) {
            std::ostringstream o;
            for (auto& [nt, c] : hist) o << " NT" << nt << "=" << c;
            std::cout << "SHAPE " << tag << " " << sh << o.str() << "\n";
        }
        std::cout << "SHAPES " << tag << " distinct=" << h.size() << " nets=" << rows.size() << "\n";
        return 0;
    }
    std::vector<std::string> ls;
    for (auto& r : rows) ls.push_back(rowline(r));
    std::sort(ls.begin(), ls.end());
    for (auto& l : ls) std::cout << (tag.empty() ? "" : tag + " ") << l << "\n";
    std::cout << "NETS " << tag << " count=" << rows.size() << "\n";
    return 0;
}
