// Corpus-wide scan for param ORDER anomalies in a golden database: a
// module_inst whose Param_assigns vector is NOT in source declaration order
// (per source file — see orderedPerFile). The rp32_r5p_mdu blocker is exactly
// this shape in the elaborated view (a parameter-port-list entry demoted
// BEHIND the body localparams), so views are reported separately and the
// offending sequence is printed for correlation with the source's port-list
// syntax.
//   usage: w4rord [-top] [-pa] <golden.uhdm>...
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstring>
#include <filesystem>
#include <iostream>
#include <map>
#include <sstream>
#include <string>
#include <vector>
using namespace UHDM;

static bool onlyTop = false, onlyPa = false;

struct Ent {
    std::string name;
    unsigned line, col;
    bool local;
    std::string file;
};

static bool ordered(const std::vector<Ent>& v) {
    for (size_t i = 1; i < v.size(); i++)
        if (v[i].line < v[i - 1].line ||
            (v[i].line == v[i - 1].line && v[i].col < v[i - 1].col))
            return false;
    return true;
}

static std::string fmt(const std::vector<Ent>& v) {
    std::ostringstream o;
    for (auto& e : v)
        o << " " << (e.local ? "L:" : "P:") << e.name << "@" << e.line << ":"
          << e.col;
    return o.str();
}

// Out-of-order WITHIN any single source file: params materialized from an
// imported package carry that package's lines and interleave legitimately, so
// each file's own subsequence is what must be monotonic. (Grouping by the
// MODULE's file misses elaborated submodule instances, whose VpiFile is the
// instantiation site — jeras_tcb_gpio's demoted GW lives in tcb_gpio.sv.)
static bool orderedPerFile(const std::vector<Ent>& v) {
    std::map<std::string, std::vector<Ent>> byFile;
    for (auto& e : v)
        byFile[e.file].push_back(e);
    for (auto& [f, g] : byFile)
        if (!ordered(g))
            return false;
    return true;
}

static void scan(const module_inst* m, const char* tag, const char* db) {
    std::string mf(m->VpiFile());
    std::vector<Ent> pa, pp;
    if (auto* v = m->Param_assigns())
        for (auto* p : *v) {
            Ent e{"", p->VpiLineNo(), p->VpiColumnNo(), false,
                  std::string(p->VpiFile())};
            if (auto* l = p->Lhs()) {
                e.name = l->VpiName();
                if (l->UhdmType() == uhdmparameter)
                    e.local = ((const parameter*)l)->VpiLocalParam();
            }
            pa.push_back(e);
        }
    if (auto* v = m->Parameters())
        for (auto* p : *v) {
            Ent e{std::string(p->VpiName()), p->VpiLineNo(), p->VpiColumnNo(),
                  false, std::string(p->VpiFile())};
            if (p->UhdmType() == uhdmparameter)
                e.local = ((const parameter*)p)->VpiLocalParam();
            pp.push_back(e);
        }
    bool bpa = pa.size() > 1 && !orderedPerFile(pa);
    bool bpp = !onlyPa && pp.size() > 1 && !orderedPerFile(pp);
    if (!bpa && !bpp)
        return;
    std::cout << "ANOM " << tag << " def=" << m->VpiDefName()
              << " name=" << m->VpiName() << " file=" << mf << " db=" << db
              << "\n";
    if (bpa)
        std::cout << "   PA" << fmt(pa) << "\n";
    if (bpp)
        std::cout << "   PP" << fmt(pp) << "\n";
}

static void scanRec(const module_inst* m, const char* tag, const char* db,
                    int depth) {
    scan(m, tag, db);
    if (depth > 8)
        return;
    if (auto* v = m->Modules())
        for (auto* c : *v)
            scanRec(c, tag, db, depth + 1);
}

int main(int argc, char** argv) {
    for (int i = 1; i < argc; i++) {
        if (!strcmp(argv[i], "-top")) { onlyTop = true; continue; }
        if (!strcmp(argv[i], "-pa")) { onlyPa = true; continue; }
        Serializer s;
        std::vector<vpiHandle> h;
        try {
            h = s.Restore(std::filesystem::path(argv[i]));
        } catch (...) {
            std::cerr << "RESTORE_FAIL " << argv[i] << "\n";
            continue;
        }
        if (h.empty())
            continue;
        auto* d = (design*)((uhdm_handle*)h[0])->object;
        if (!d)
            continue;
        if (!onlyTop)
            if (auto* v = d->AllModules())
                for (auto* m : *v)
                    scan(m, "DEF", argv[i]);
        if (auto* v = d->TopModules())
            for (auto* m : *v)
                scanRec(m, "TOP", argv[i], 0);
        std::cout.flush();
    }
    return 0;
}
