// r10sd2 — REFLECTIVE LOCALIZER: which FIELD, on which OBJECT, produces
// `LHS:<null>` / `RHS: package uvm_pkg`?
//
// `uhdm-cmp` prints the failing PAIR and nothing else, and CompareContext keeps
// only two pointers, so neither instrument can name the SLOT.  `ct2pkgv.cpp`
// ruled out every vector `package::Compare` walks (identical, NULL-ness
// included, both views, both modes), which leaves BaseClass.h's SINGULAR arm
//     } else if ((lhs == nullptr) && (rhs != nullptr)) {
//         context->m_failedRhs = rhs;  return -1;      // -> "LHS: <null>"
// i.e. SOME object holds a singular pointer to `package uvm_pkg` that golden
// leaves NULL.  This tool finds it WITHOUT a hand-written field table: it walks
// the object graph through the generic VPI relation API (`vpi_handle` /
// `vpi_iterate` over every relation constant), and at each step keeps the child
// pair whose own `Compare` REPRODUCES the head.  When no child reproduces, the
// slot is on the current object and is printed by relation number.
//
// build: g++ -O2 -std=c++17 ct2find.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct2find
// usage: ct2find <golden.uhdm> <ours.uhdm> <targetPkgName> [maxrelation]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/sv_vpi_user.h>
#include <uhdm/vhpi_user.h>

#include <filesystem>
#include <iostream>
#include <set>
#include <string>
#include <utility>

using namespace UHDM;

static std::string g_target;
static int g_maxrel = 3100;

static std::string ident(const BaseClass* p) {
    if (!p) return "<null>";
    std::string s = UhdmName(p->UhdmType());
    std::string nm(p->VpiName());
    if (!nm.empty()) s += "(" + nm + ")";
    s += "@" + std::to_string(p->VpiLineNo()) + ":" +
         std::to_string(p->VpiColumnNo());
    return s;
}

static bool isTarget(const BaseClass* p) {
    return p && p->UhdmType() == UHDM_OBJECT_TYPE::uhdmpackage &&
           std::string(p->VpiName()) == g_target;
}

// The head's signature, tested with a FRESH context so m_visited never masks it.
static bool reproduces(const BaseClass* g, const BaseClass* o) {
    if (!g || !o) return false;
    CompareContext c;
    int r = g->Compare(o, &c);
    return r != 0 && c.m_failedLhs == nullptr && isTarget(c.m_failedRhs);
}

static const BaseClass* obj(vpiHandle h) {
    return h ? (const BaseClass*)((uhdm_handle*)h)->object : nullptr;
}

static std::set<std::pair<const BaseClass*, const BaseClass*>> seen;

static void descend(const BaseClass* g, const BaseClass* o, int depth) {
    if (depth > 40) { std::cout << "DEPTH_CAP\n"; return; }
    if (!seen.insert({g, o}).second) { std::cout << "CYCLE\n"; return; }
    std::cout << std::string(depth * 2, ' ') << "at golden=" << ident(g)
              << "  ours=" << ident(o) << "\n";
    vpiHandle gh = NewVpiHandle(g), oh = NewVpiHandle(o);
    for (int rel = 1; rel <= g_maxrel; rel++) {
        // vpiParent (81) is a BACK-pointer that NO `Compare` body reads; left in,
        // the walk climbs straight back to the design and reports CYCLE.  This is
        // the one relation that must be excluded on principle, not on symptom.
        if (rel == vpiParent) continue;
        // --- singular relation
        vpiHandle a = vpi_handle(rel, gh), b = vpi_handle(rel, oh);
        const BaseClass* ga = obj(a);
        const BaseClass* ob = obj(b);
        if (!ga && isTarget(ob)) {
            std::cout << std::string(depth * 2, ' ')
                      << ">>> FOUND singular relation " << rel
                      << ": golden=<null>  ours=" << ident(ob) << "\n"
                      << std::string(depth * 2, ' ') << ">>> OWNER: " << ident(o)
                      << "   (owner type " << UhdmName(o->UhdmType()) << ")\n";
            return;
        }
        if (ga && ob && !seen.count({ga, ob}) && reproduces(ga, ob)) {
            std::cout << std::string(depth * 2, ' ') << "-> via singular rel "
                      << rel << "\n";
            descend(ga, ob, depth + 1);
            return;
        }
        // --- iterated relation
        vpiHandle ig = vpi_iterate(rel, gh), io = vpi_iterate(rel, oh);
        if (!ig && io) {
            while (vpiHandle e = vpi_scan(io)) {
                if (isTarget(obj(e))) {
                    std::cout << std::string(depth * 2, ' ')
                              << ">>> FOUND iterated relation " << rel
                              << " NULL in golden, ours holds " << ident(obj(e))
                              << "\n"
                              << std::string(depth * 2, ' ')
                              << ">>> OWNER: " << ident(o) << "\n";
                    return;
                }
            }
            continue;
        }
        if (!ig || !io) continue;
        int i = 0;
        while (true) {
            vpiHandle eg = vpi_scan(ig);
            vpiHandle eo = vpi_scan(io);
            if (!eg || !eo) break;
            if (!seen.count({obj(eg), obj(eo)}) &&
                reproduces(obj(eg), obj(eo))) {
                std::cout << std::string(depth * 2, ' ') << "-> via iterated rel "
                          << rel << "[" << i << "]\n";
                descend(obj(eg), obj(eo), depth + 1);
                return;
            }
            i++;
        }
    }
    std::cout << std::string(depth * 2, ' ')
              << "!!! NO CHILD REPRODUCES — head is a field of THIS object, "
                 "unreachable through the VPI relation API: "
              << ident(o) << "\n";
    // The VPI relation API does not expose `vpiInstance` on every class that
    // carries it, so the last step is read off the C++ accessors directly —
    // these are the SIX singular `Instance()` fields a `Compare` body reads.
    const BaseClass *gi = nullptr, *oi = nullptr;
    const char* which = nullptr;
#define TRY(T, LBL)                                     \
    if (!which) {                                       \
        const T* a = any_cast<const T*>(g);             \
        const T* b = any_cast<const T*>(o);             \
        if (a || b) {                                   \
            gi = a ? a->Instance() : nullptr;           \
            oi = b ? b->Instance() : nullptr;           \
            which = LBL;                                \
        }                                               \
    }
    TRY(typespec, "typespec::Instance")
    TRY(variables, "variables::Instance")
    TRY(task_func, "task_func::Instance")
    TRY(ports, "ports::Instance")
    TRY(clocking_block, "clocking_block::Instance")
    TRY(instance, "instance::Instance")
#undef TRY
    if (which)
        std::cout << std::string(depth * 2, ' ') << ">>> " << which
                  << ":  golden=" << ident(gi) << "   ours=" << ident(oi)
                  << (!gi && isTarget(oi) ? "   *** THE HEAD ***" : "") << "\n";
}

int main(int argc, char** argv) {
    if (argc < 4) {
        std::cerr << "usage: ct2find <golden.uhdm> <ours.uhdm> <pkg> [maxrel]\n";
        return 2;
    }
    g_target = argv[3];
    if (argc > 4) g_maxrel = atoi(argv[4]);
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    auto* da = (design*)((uhdm_handle*)ha[0])->object;
    auto* db = (design*)((uhdm_handle*)hb[0])->object;
    CompareContext c0;
    int r = da->Compare(db, &c0);
    std::cout << "DESIGN Compare r=" << r
              << " failedLhs=" << ident(c0.m_failedLhs)
              << " failedRhs=" << ident(c0.m_failedRhs) << "\n";
    if (!reproduces(da, db)) {
        std::cout << "WHOLE-DESIGN COMPARE DOES NOT SHOW THE HEAD SIGNATURE; "
                     "nothing to localize with this target\n";
        return 1;
    }
    descend(da, db, 0);
    return 0;
}
