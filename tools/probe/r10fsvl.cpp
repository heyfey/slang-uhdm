// r10fsvl: EvalFunc member-LEFTOVER census.  Walks every struct_typespec in
// the file (via the serializer's whole-object listing is not available, so we
// walk design->AllPackages/TopPackages/AllModules/TopModules and recurse
// through typespec->Members) and prints, per struct typespec object, each
// typespec_member's Actual_value encoded as CMP sees a constant:
// VpiConstType / VpiSize / VpiDecompile (+ the loc, marked UNLOC when 0).
//   g++ -std=c++17 -I$HOME/.local/include r10fsvl.cpp -o r10fsvl \
//       -L$HOME/.local/lib64 -luhdm -lcapnp -lkj
//   r10fsvl <a.uhdm> [--sum]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
#include <set>
#include <string>
using namespace UHDM;

static std::map<const BaseClass*, int> g_ids;
static int oid(const BaseClass* o) {
    if (!o) return -1;
    auto it = g_ids.find(o);
    if (it != g_ids.end()) return it->second;
    int n = (int)g_ids.size();
    return g_ids[o] = n;
}
static bool g_sum = false;
static std::map<std::string, int> g_tally;

static std::string vdesc(const any* v) {
    if (!v) return "-";
    if (v->UhdmType() != uhdmconstant)
        return std::string(UhdmName(v->UhdmType())) + "#" + std::to_string(oid(v));
    auto* c = (const constant*)v;
    std::string loc = c->VpiLineNo() == 0
                          ? std::string("UNLOC")
                          : (std::to_string(c->VpiLineNo()) + ":" +
                             std::to_string(c->VpiColumnNo()) + "-" +
                             std::to_string(c->VpiEndLineNo()) + ":" +
                             std::to_string(c->VpiEndColumnNo()));
    return "const ct" + std::to_string(c->VpiConstType()) + " sz" +
           std::to_string(c->VpiSize()) + " dc'" + std::string(c->VpiDecompile()) +
           "' " + loc;
}

static std::set<const typespec*> g_seen;
static void walkTs(const std::string& tag, const typespec* t);

static void walkRt(const std::string& tag, const ref_typespec* r) {
    if (r) walkTs(tag, r->Actual_typespec());
}

static void walkTs(const std::string& tag, const typespec* t) {
    if (!t || !g_seen.insert(t).second) return;
    if (t->UhdmType() == uhdmstruct_typespec) {
        auto* st = (const struct_typespec*)t;
        int nleft = 0;
        std::string body;
        if (st->Members())
            for (auto* m : *st->Members()) {
                if (!m->Actual_value()) continue;
                nleft++;
                body += "  " + tag + "  MEM " + std::string(m->VpiName()) + " = " +
                        vdesc(m->Actual_value()) + "  [def=" +
                        vdesc(m->Default_value()) + "]\n";
                if (g_sum) {
                    auto* v = m->Actual_value();
                    std::string k;
                    if (v->UhdmType() != uhdmconstant)
                        k = UhdmName(v->UhdmType());
                    else {
                        auto* c = (const constant*)v;
                        k = "ct" + std::to_string(c->VpiConstType()) + " sz" +
                            std::to_string(c->VpiSize()) +
                            (c->VpiLineNo() == 0 ? " UNLOC" : " LOC");
                    }
                    g_tally[k]++;
                }
            }
        std::cout << tag << " struct#" << oid(t) << "/id" << t->UhdmId() << " '"
                  << t->VpiName() << "' members="
                  << (st->Members() ? st->Members()->size() : 0)
                  << " leftovers=" << nleft << "\n";
        if (!g_sum) std::cout << body;
        if (st->Members())
            for (auto* m : *st->Members()) walkRt(tag + ">", m->Typespec());
        return;
    }
    if (t->UhdmType() == uhdmlogic_typespec) {
        walkRt(tag, ((const logic_typespec*)t)->Elem_typespec());
        return;
    }
    if (t->UhdmType() == uhdmpacked_array_typespec) {
        walkRt(tag, ((const packed_array_typespec*)t)->Elem_typespec());
        return;
    }
    if (t->UhdmType() == uhdmarray_typespec) {
        walkRt(tag, ((const array_typespec*)t)->Elem_typespec());
        return;
    }
}

static void walkInst(const std::string& tag, const instance* in) {
    std::cout << tag << " INST " << in->VpiFullName() << "\n";
    if (in->Typespecs()) for (auto* t : *in->Typespecs()) {
        std::cout << tag << "   TSLIST " << UhdmName(t->UhdmType()) << "#"
                  << oid(t) << "/id" << t->UhdmId() << " '" << t->VpiName() << "'\n";
        walkTs(tag + "|ts", t);
    }
    if (in->Parameters()) for (auto* p : *in->Parameters()) {
        if (p->UhdmType() == uhdmparameter)
            walkRt(tag + "|par", ((const parameter*)p)->Typespec());
    }
    if (in->Variables()) for (auto* v : *in->Variables()) walkRt(tag + "|var", v->Typespec());
    if (in->Task_funcs()) for (auto* tf : *in->Task_funcs()) {
        if (tf->UhdmType() == uhdmfunction) {
            auto* f = (const function*)tf;
            walkRt(tag + "|fnret", f->Return()  ? f->Return()->Typespec() : nullptr);
            if (f->Variables()) for (auto* v : *f->Variables()) walkRt(tag + "|fnvar", v->Typespec());
            if (f->Io_decls()) for (auto* io : *f->Io_decls()) walkRt(tag + "|fnio", io->Typespec());
        }
    }
}

static void walkMod(const std::string& tag, const module_inst* m) {
    walkInst(tag, m);
    if (m->Modules()) for (auto* c : *m->Modules()) walkMod(tag + ">", c);
}

int main(int argc, char** argv) {
    for (int i = 2; i < argc; i++)
        if (std::string(argv[i]) == "--sum") g_sum = true;
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    if (d->AllPackages()) for (auto* p : *d->AllPackages()) walkInst("ALLPKG", p);
    if (d->TopPackages()) for (auto* p : *d->TopPackages()) walkInst("TOPPKG", p);
    if (d->AllModules()) for (auto* m : *d->AllModules()) walkMod("ALLMOD", m);
    if (d->TopModules()) for (auto* m : *d->TopModules()) walkMod("TOPMOD", m);
    if (g_sum) {
        std::cout << "--- tally ---\n";
        for (auto& [k, n] : g_tally) std::cout << "  " << k << " : " << n << "\n";
    }
    return 0;
}
