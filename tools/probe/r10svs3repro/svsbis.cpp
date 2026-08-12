// r10svs3repro/svsbis.cpp — THE DESIGN-ROOTED BISECTOR.
//
// r10earl17c (the campaign's generic bisector) can only be ENTERED at a
// module/package listing through a hand-written `select` that has no case for a
// CLASS METHOD, which is exactly where this pass's head lives
// (`begin: (work@packet::byte_unpack)` inside `class_defn work@packet`).  This
// variant keeps r10earl17c's four hard-won invariants verbatim —
//   * children enumerated GENERICALLY over the VPI relation ids, no per-type code
//   * vpiParent (81) skipped: it is a pure back-edge Compare never follows
//   * the seen-set keyed on the PAIR, not on the golden node
//   * every child context PRE-SEEDED with the ancestor path, so a back-edge that
//     the real Compare short-circuits through m_visited cannot fake a failure
// — and changes only the ENTRY: it roots at the `design` pair, i.e. exactly
// where uhdm-cmp roots, so the walk reproduces uhdm-cmp's own descent and needs
// no selector at all.
//
// It also does the thing uhdm-cmp structurally CANNOT report.  When
// SafeCompare's vector overload sees a SIZE mismatch it sets
// m_failedLhs/m_failedRhs to the two CONTAINERS and returns — so the head
// uhdm-cmp prints is the container, with no hint of WHICH relation's list was
// the wrong length.  Here every size mismatch is printed with its relation id
// AND both element lists, and when no child pair reproduces the failure the
// size table is the verdict.
//
// Build: bash tools/probe/r10svs3repro/svsbuild.sh svsbis
// Usage: svsbis <golden.uhdm> <ours.uhdm> [maxdepth]
//   LHS/A is ALWAYS golden (Surelog); RHS/B is ALWAYS ours.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/vpi_visitor.h>

#include <filesystem>
#include <iostream>
#include <set>
#include <string>
#include <vector>
using namespace UHDM;

static const int MAXREL = 3000;
static int maxDepth = 60;

static std::string base(std::string_view f) {
    size_t p = f.rfind('/');
    return std::string(p == std::string_view::npos ? f : f.substr(p + 1));
}

static std::string at(const BaseClass* n) {
    if (!n) return "<null>";
    std::string s = std::string(UhdmName(n->UhdmType())) + " '" +
                    std::string(n->VpiName()) + "' " + base(n->VpiFile()) + ":" +
                    std::to_string(n->VpiLineNo()) + ":" +
                    std::to_string(n->VpiColumnNo()) + "-" +
                    std::to_string(n->VpiEndLineNo()) + ":" +
                    std::to_string(n->VpiEndColumnNo()) +
                    " uid=" + std::to_string(n->UhdmId());
    if (!n->VpiDefName().empty()) s += " def=" + std::string(n->VpiDefName());
    if (n->UhdmType() == uhdmconstant) {
        auto* c = (const constant*)n;
        s += " {ct=" + std::to_string(c->VpiConstType()) +
             " sz=" + std::to_string(c->VpiSize()) +
             " dec=" + std::string(c->VpiDecompile()) + "}";
    }
    if (n->UhdmType() == uhdmoperation)
        s += " {op=" + std::to_string(((const operation*)n)->VpiOpType()) + "}";
    if (const auto* tf = any_cast<const task_func*>((const any*)n))
        s += " {method=" + std::to_string((int)tf->VpiMethod()) +
             " virt=" + std::to_string((int)tf->VpiVirtual()) +
             " vis=" + std::to_string(tf->VpiVisibility()) +
             " acc=" + std::to_string(tf->VpiAccessType()) + "}";
    return s;
}

static const BaseClass* obj(vpiHandle h) {
    return h ? (const BaseClass*)((uhdm_handle*)h)->object : nullptr;
}

struct Child {
    int rel;
    int idx;
    const BaseClass* a;
    const BaseClass* b;
};

struct SizeMiss {
    int rel;
    std::vector<const BaseClass*> va, vb;
};
static std::vector<SizeMiss> lastSizeMiss;

static std::vector<Child> childrenOf(const BaseClass* a, const BaseClass* b,
                                    std::vector<SizeMiss>* miss) {
    std::vector<Child> out;
    if (miss) miss->clear();
    vpiHandle ha = NewVpiHandle((const any*)a);
    vpiHandle hb = NewVpiHandle((const any*)b);
    for (int rel = 1; rel < MAXREL; rel++) {
        if (rel == vpiParent) continue;
        vpiHandle ca = vpi_handle(rel, ha);
        vpiHandle cb = vpi_handle(rel, hb);
        if (ca || cb) {
            out.push_back({rel, -1, obj(ca), obj(cb)});
            if (ca) vpi_release_handle(ca);
            if (cb) vpi_release_handle(cb);
        }
        vpiHandle ia = vpi_iterate(rel, ha);
        vpiHandle ib = vpi_iterate(rel, hb);
        if (ia || ib) {
            std::vector<const BaseClass*> va, vb;
            if (ia) {
                while (vpiHandle x = vpi_scan(ia)) {
                    va.push_back(obj(x));
                    vpi_release_handle(x);
                }
                vpi_release_handle(ia);
            }
            if (ib) {
                while (vpiHandle x = vpi_scan(ib)) {
                    vb.push_back(obj(x));
                    vpi_release_handle(x);
                }
                vpi_release_handle(ib);
            }
            if (va.size() != vb.size() && miss) miss->push_back({rel, va, vb});
            for (size_t i = 0; i < va.size() && i < vb.size(); i++)
                out.push_back({rel, (int)i, va[i], vb[i]});
        }
    }
    vpi_release_handle(ha);
    vpi_release_handle(hb);
    return out;
}

static std::set<std::pair<const BaseClass*, const BaseClass*>> seen;
static std::vector<const BaseClass*> ancestors;

static int cmpSeeded(const BaseClass* a, const BaseClass* b,
                     CompareContext& ctx) {
    for (const BaseClass* p : ancestors) ctx.m_visited.insert((const any*)p);
    return a->Compare(b, &ctx);
}

static std::string line(const Child& c, int r, const BaseClass* a,
                        const BaseClass* b) {
    return "rel=" + std::to_string(c.rel) +
           (c.idx >= 0 ? "[" + std::to_string(c.idx) + "]" : "") +
           " r=" + std::to_string(r) + "\n      A(golden) " + at(a) +
           "\n      B(ours)   " + at(b);
}

static void bisect(const BaseClass* a, const BaseClass* b, int depth) {
    if (depth > maxDepth) {
        std::cout << "  (depth cap)\n";
        return;
    }
    std::vector<SizeMiss> miss;
    std::vector<Child> kids = childrenOf(a, b, &miss);
    ancestors.push_back(a);
    std::vector<std::string> cyc;
    for (const Child& c : kids) {
        if (!c.a || !c.b) {
            std::cout << "  [" << depth << "] rel=" << c.rel
                      << (c.idx >= 0 ? "[" + std::to_string(c.idx) + "]" : "")
                      << " NULLNESS  A(golden)=" << at(c.a)
                      << "  B(ours)=" << at(c.b)
                      << "\n  *** THE MISSING POINTER ***\n      ownerA "
                      << at(a) << "\n      ownerB " << at(b) << "\n";
            ancestors.pop_back();
            return;
        }
        CompareContext ctx;
        int r = cmpSeeded(c.a, c.b, ctx);
        if (r == 0) continue;
        if (!seen.insert({c.a, c.b}).second) {
            cyc.push_back(line(c, r, c.a, c.b));
            continue;
        }
        std::cout << "  [" << depth << "] " << line(c, r, c.a, c.b) << "\n";
        bisect(c.a, c.b, depth + 1);
        ancestors.pop_back();
        return;
    }
    ancestors.pop_back();
    // No child pair reproduces it => the failure is a FIELD OF THIS PAIR, i.e.
    // either a scalar/string field or a vector SIZE.  Print both.
    std::cout << "  [" << depth << "] *** NO CHILD REPRODUCES IT — the failing "
                 "field is ON THIS PAIR ***\n      A(golden) "
              << at(a) << "\n      B(ours)   " << at(b) << "\n";
    if (miss.empty()) {
        std::cout << "      NO VECTOR SIZE MISMATCH — the field is a SCALAR or "
                     "STRING on this pair\n";
    }
    for (const SizeMiss& m : miss) {
        std::cout << "      *** VECTOR SIZE MISMATCH rel=" << m.rel
                  << "  golden=" << m.va.size() << " ours=" << m.vb.size()
                  << " ***\n";
        for (size_t i = 0; i < m.va.size(); i++)
            std::cout << "        golden[" << i << "] " << at(m.va[i]) << "\n";
        for (size_t i = 0; i < m.vb.size(); i++)
            std::cout << "        ours  [" << i << "] " << at(m.vb[i]) << "\n";
    }
    for (const std::string& l : cyc)
        std::cout << "      CYCLE (fails only unseeded) " << l << "\n";
}

int main(int argc, char** argv) {
    if (argc < 3) {
        std::cout << "usage: svsbis <golden.uhdm> <ours.uhdm> [maxdepth]\n";
        return 1;
    }
    if (argc > 3) maxDepth = std::stoi(argv[3]);
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    if (ha.empty() || hb.empty()) {
        std::cout << "RESTORE FAILED a=" << ha.size() << " b=" << hb.size()
                  << "\n";
        return 2;
    }
    const design* da = (const design*)((uhdm_handle*)ha[0])->object;
    const design* db = (const design*)((uhdm_handle*)hb[0])->object;
    // Reproduce uhdm-cmp's own verdict FIRST, so the walk below is known to be
    // chasing the same failure the gate reports.
    CompareContext ctx;
    int r = da->Compare(db, &ctx);
    std::cout << "DESIGN Compare r=" << r << "\n  uhdm-cmp HEAD failLhs "
              << at(ctx.m_failedLhs) << "\n  uhdm-cmp HEAD failRhs "
              << at(ctx.m_failedRhs) << "\n";
    if (r == 0) return 0;
    seen.insert({(const BaseClass*)da, (const BaseClass*)db});
    bisect(da, db, 1);
    return 0;
}
