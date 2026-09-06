// r10v181 — THE FOREACH LOOP-VARIABLE OBJECT GRAPH.  MEASUREMENT ONLY.
//
// `ctv181id.cpp` labels a body reference's target RELATIVE to the loop's
// listing entry (SHARED / LISTING-REF / OTHER), which is only meaningful once
// the graph around that listing entry is known.  This prints the graph itself,
// with LOCAL ids (dense, assigned in walk order inside one foreach) so a
// golden dump and a slang dump are comparable as text:
//
//   FE <pkg>|<tf>|<EMPTYTF|HASLOCALS>@<L>:<C>
//     LV#<i> ref_var <name>@<L>:<C> id=L0 -> actual=L1 (<kind> <name>@<L>:<C>)
//        L1 -> actual=<...>            (the shared object's OWN vpiActual)
//     REF <kind>@<L>:<C> -> L<n> | NEW<k> | BARE
//
// usage: ctv181graph <db.uhdm> <tag> [substring-of-tf-name]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <map>
#include <string>
#include <vector>

using namespace UHDM;

static const BaseClass* actualOf(const BaseClass* o) {
    if (!o) return nullptr;
    if (auto* r = any_cast<const ref_obj*>(o)) return r->Actual_group();
    if (auto* r = any_cast<const ref_var*>(o)) return r->Actual_group();
    if (auto* r = any_cast<const bit_select*>(o)) return r->Actual_group();
    return nullptr;
}
static std::string face(const BaseClass* o) {
    if (!o) return "<null>";
    char b[300];
    snprintf(b, sizeof b, "%s:%s@%u:%u", UhdmName(o->UhdmType()).data(),
             std::string(o->VpiName()).c_str(), o->VpiLineNo(),
             (unsigned)o->VpiColumnNo());
    return b;
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ctv181graph <db> <tag> [tf]\n"); return 2; }
    const std::string tag = argv[2];
    const std::string want = argc > 3 ? argv[3] : "";
    Serializer S;
    if (S.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
    std::vector<const BaseClass*> objs;
    for (auto& kv : S.AllObjects())
        if (kv.first) objs.push_back(kv.first);
    std::sort(objs.begin(), objs.end(), [](const BaseClass* a, const BaseClass* b) {
        return a->UhdmId() < b->UhdmId();
    });
    // Every foreach, with its owning tf and package.
    std::vector<std::string> blocks;
    for (const BaseClass* o : objs) {
        if (o->UhdmType() != uhdmforeach_stmt) continue;
        const task_func* tf = nullptr;
        std::string pkg = "-";
        for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
            if (!tf && (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask))
                tf = (const task_func*)p;
            if (p->UhdmType() == uhdmpackage) { pkg = std::string(p->VpiName()); break; }
            if (p->UhdmType() == uhdmmodule_inst) { pkg = "MOD:" + std::string(p->VpiName()); break; }
        }
        std::string tfn = tf ? std::string(tf->VpiName()) : "-";
        if (!want.empty() && tfn.find(want) == std::string::npos) continue;
        bool io = tf && tf->Io_decls() && !tf->Io_decls()->empty();
        bool vs = tf && tf->Variables() && !tf->Variables()->empty();
        auto* fe = (const foreach_stmt*)o;
        std::map<const BaseClass*, std::string> lid;
        auto name = [&](const BaseClass* p) -> std::string {
            if (!p) return "BARE";
            auto it = lid.find(p);
            if (it != lid.end()) return it->second;
            std::string n = "N" + std::to_string(lid.size());
            lid[p] = n;
            return n;
        };
        char hdr[600];
        snprintf(hdr, sizeof hdr, "%s FE %s|%s|%s@%u:%u", tag.c_str(), pkg.c_str(),
                 tfn.c_str(), (!io && !vs) ? "EMPTYTF" : "HASLOCALS",
                 o->VpiLineNo(), (unsigned)o->VpiColumnNo());
        std::string blk = hdr;
        blk += "\n";
        if (auto* lvs = fe->VpiLoopVars()) {
            int i = 0;
            for (auto* v : *lvs) {
                if (!v) { blk += "  LV#" + std::to_string(i++) + " <null>\n"; continue; }
                const BaseClass* act = actualOf(v);
                blk += "  LV#" + std::to_string(i++) + " " + face(v) + " id=" +
                       name(v) + " -> " + name(act) + " " + face(act) + "\n";
                blk += "     " + name(act) + " -> " + name(actualOf(act)) + " " +
                       face(actualOf(act)) + "\n";
            }
        }
        // Body references (everything under the foreach that is not a loop var
        // listing entry), in source order.
        std::vector<std::string> refs;
        for (const BaseClass* r : objs) {
            auto t = r->UhdmType();
            if (t != uhdmref_obj && t != uhdmref_var && t != uhdmbit_select) continue;
            bool under = false, listing = false;
            for (const BaseClass* p = r; p; p = p->VpiParent())
                if (p == o) { under = true; break; }
            if (!under) continue;
            if (auto* lvs = fe->VpiLoopVars())
                for (auto* v : *lvs)
                    if (v == r) listing = true;
            if (listing) continue;
            refs.push_back("  REF " + face(r) + " -> " + name(actualOf(r)) + " " +
                           face(actualOf(r)));
        }
        std::sort(refs.begin(), refs.end());
        for (auto& s : refs) blk += s + "\n";
        blocks.push_back(blk);
    }
    std::sort(blocks.begin(), blocks.end());
    for (auto& b : blocks) fputs(b.c_str(), stdout);
    return 0;
}
