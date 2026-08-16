// r10uvm79cen — the pass's CENSUS INSTRUMENT.
//
// Reads one .uhdm database and reports, for EVERY hier_path the serializer
// holds (Serializer::AllObjects(), so unreachable/orphaned objects are counted
// too — the dump only prints what some parent points at, and it reprints an
// object at every reference, so a shape census over dump text multiplies):
//
//   E1  the hier_path's own NAME carries an index text that is NOT what
//       Surelog's decompileHelper (CompileHelper.cpp:2544) would render.
//       decompileHelper's dispatch is CLOSED and has no default:
//         constant -> VpiDecompile   ref_obj -> VpiName   operation -> pretty
//         bit_select -> "[" + (its constant|ref_obj|operation index) + "]",
//                       and the EMPTY STRING for any other index kind
//         part_select -> "[l:r]"     indexed_part_select -> "[b+:w]"
//         var_select -> the concatenation
//         EVERY OTHER OBJECT KIND -> the EMPTY STRING
//       so a rendered index group is decompile-shaped iff it is empty, or a
//       single complete bracket group with no nesting, or contains no
//       bracket / dot / paren at all.  GOLDEN IS EXPECTED TO SHOW ZERO.
//
//   E2  a hier_path path-element select's NON-TRIVIAL INDEX object (anything
//       but a bare ref_obj or a constant) whose vpiParent is not the
//       hier_path.  TRIVIAL indices are EXCLUDED because golden puts them
//       BOTH ways and the split is a Surelog code-site artifact, not a rule:
//       arm a1 c3 parents a ref_obj index at the path, arm a2 d6's INNER
//       `h.idx[i]` parents its ref_obj index at the bit_select.  A detector
//       that fires on golden is a broken detector.
//
//   E3  a NAMED DESCENDANT of a non-trivial index whose cached fullname does
//       not contain the hier_path's name — i.e. the ComputeFullName chain
//       through the path was not taken.  Checked on the DESCENDANTS, not on
//       the index object itself: an operation and a func_call have no
//       fullname at all, and an index that is itself a hier_path carries its
//       own dotted text (`h.idx[i]`), so the index object is the wrong place
//       to look.  A bare ref_obj index is EXCLUDED because BaseClass.cpp:132
//       skips a hier_path parent for a ref_obj child — plain scope is CORRECT
//       there (arm a1 c3, golden).
//
//   E4  a hier_path path-element ref_obj whose cached fullname joins its last
//       step with `.` inside a `::`-first scope (the hier-path TAIL joint).
//
//   E5  a SELECT index anchored at its own inner index (same line:col) — the
//       span proxy for "we put the nested select where its selector is".
//
//   E6  the NAMING law's exact firing set: a path-element select that is
//       FOLLOWED BY FURTHER PATH ELEMENTS and whose index is neither a
//       constant, nor a ref_obj, nor an operation — i.e. the three kinds
//       decompileHelper renders as themselves.  Every other index kind
//       renders EMPTY or as its own bracket group, so the enclosing name
//       MUST change.  A TRAILING select is excluded on purpose: golden's
//       trailing sites are a DIFFERENT Surelog code path with their own
//       rules (uvm_reg_map.svh 771 renders NO brackets while 772 renders
//       `[]` for the same index expression), and this pass does not own it.
//
//   E7  the STRUCTURAL law's exact firing set: a NON-TRAILING path-element
//       select whose index is itself a SELECT object.
//
// usage: r10uvm79cen <file.uhdm> [tag]
//   R10UVM79_LIST=1   raw inventory of every hier_path index, no predicate, so
//                     a claim about golden is READ OFF the artifact.
// Prints one line per flagged object, then a TOTALS line ALWAYS — including on
// RESTORE_FAIL, because a run that reached nothing must never read as
// perfection.

#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdlib>
#include <iostream>
#include <string>
#include <vector>

using namespace UHDM;

static std::string fullOf(const any* o) {
    if (!o) return "";
    if (auto* r = dynamic_cast<const ref_obj*>(o)) return std::string(r->VpiFullName());
    if (auto* b = dynamic_cast<const bit_select*>(o)) return std::string(b->VpiFullName());
    if (auto* p = dynamic_cast<const part_select*>(o)) return std::string(p->VpiFullName());
    if (auto* i = dynamic_cast<const indexed_part_select*>(o)) return std::string(i->VpiFullName());
    if (auto* v = dynamic_cast<const var_select*>(o)) return std::string(v->VpiFullName());
    if (auto* h = dynamic_cast<const hier_path*>(o)) return std::string(h->VpiFullName());
    return "";
}

static std::string loc(const any* o) {
    if (!o) return "-";
    return std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo());
}

// The index object a hier_path path element carries, whatever the element is.
static const any* idxOf(const any* elem) {
    if (auto* b = dynamic_cast<const bit_select*>(elem)) return b->VpiIndex();
    return nullptr;
}

// Every named descendant of an index expression, for E3.
static void descend(const any* o, std::vector<const any*>& out, int d) {
    if (!o || d > 10) return;
    out.push_back(o);
    if (auto* op = dynamic_cast<const operation*>(o))
        if (auto* v = op->Operands()) for (auto* e : *v) descend(e, out, d + 1);
    if (auto* b = dynamic_cast<const bit_select*>(o)) descend(b->VpiIndex(), out, d + 1);
    if (auto* h = dynamic_cast<const hier_path*>(o))
        if (auto* v = h->Path_elems()) for (auto* e : *v) descend(e, out, d + 1);
    if (auto* f = dynamic_cast<const tf_call*>(o))
        if (auto* v = f->Tf_call_args()) for (auto* e : *v) descend(e, out, d + 1);
    if (auto* v2 = dynamic_cast<const var_select*>(o))
        if (auto* v = v2->Exprs()) for (auto* e : *v) descend(e, out, d + 1);
    if (auto* p = dynamic_cast<const part_select*>(o)) {
        descend(p->Left_range(), out, d + 1); descend(p->Right_range(), out, d + 1);
    }
    if (auto* p = dynamic_cast<const indexed_part_select*>(o)) {
        descend(p->Base_expr(), out, d + 1); descend(p->Width_expr(), out, d + 1);
    }
}

static bool isTrivialIdx(const any* ix) {
    if (!ix) return true;
    UHDM_OBJECT_TYPE t = ix->UhdmType();
    return t == uhdmref_obj || t == uhdmconstant;
}

// A rendered index group is decompile-shaped iff it is EMPTY, or a single
// complete bracket group with no further nesting, or free of [ ] . ( entirely.
static bool decompileShaped(const std::string& c) {
    if (c.empty()) return true;
    // A PAREN is NOT a marker: golden renders `[$clog2(5'h8) - 1:0]` in 70
    // objects across 13 databases (Ariane/Opentitan/Nyuzi/Earlgrey/Azadi),
    // because there the index object is a PART_SELECT whose bound is an
    // OPERATION and decompileHelper's part_select branch pretty-prints it.
    // The predicate was written with `(` in it and it FIRED ON GOLDEN — a
    // detector that fires on golden is a broken detector.  The cost is that a
    // BARE call index (`iarr[fn(i)]`, arm a2 d7, which golden renders EMPTY)
    // is missed here; E2/E3 still catch it, and the NAMES join below is the
    // authoritative instrument for the naming law.
    if (c.front() == '[') {
        if (c.back() != ']') return false;
        std::string in = c.substr(1, c.size() - 2);
        return in.find('[') == std::string::npos &&
               in.find(']') == std::string::npos;
    }
    return c.find('[') == std::string::npos && c.find(']') == std::string::npos;
}

// Split a path name into its TOP-LEVEL bracket groups' contents.
static std::vector<std::string> idxGroups(const std::string& n) {
    std::vector<std::string> out;
    int depth = 0;
    size_t start = 0;
    for (size_t i = 0; i < n.size(); ++i) {
        if (n[i] == '[') {
            if (depth == 0) start = i + 1;
            depth++;
        } else if (n[i] == ']') {
            depth--;
            if (depth == 0) out.push_back(n.substr(start, i - start));
            if (depth < 0) return out;  // malformed; stop
        }
    }
    return out;
}

// pass 78's regime test, unchanged: a prefix whose first `::` precedes its
// first `.` is a package/class scope and joins with `::`.
static bool colonRegime(const std::string& p) {
    size_t c = p.find("::"), d = p.find('.');
    if (c == std::string::npos) return false;
    if (d == std::string::npos) return true;
    return c < d;
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: r10uvm79cen <file.uhdm> [tag]\n"; return 2; }
    std::string tag = argc > 2 ? argv[2] : argv[1];
    bool list = getenv("R10UVM79_LIST") != nullptr;
    // R10UVM79_NAMES=1: emit one NAME row per hier_path, keyed by
    // file:line:col, so GOLDEN and OURS can be JOINED and the naming law
    // checked against the artifact instead of against a text predicate.
    bool names = getenv("R10UVM79_NAMES") != nullptr;

    Serializer s;
    long hp = 0, elems = 0, idxs = 0;
    long e1 = 0, e2 = 0, e3 = 0, e4 = 0, e5 = 0, e6 = 0, e7 = 0;
    const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
    if (restored.empty()) {
        std::cout << "RESTORE_FAIL " << tag << "\n";
        std::cout << "TOTALS " << tag
                  << " hp=0 elems=0 idxs=0 e1=0 e2=0 e3=0 e4=0 e5=0 e6=0 e7=0\n";
        return 3;
    }
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o) continue;
        auto* path = dynamic_cast<const hier_path*>(o);
        if (!path) continue;
        hp++;
        std::string pname(path->VpiName());
        if (names)
            std::cout << "NAME\t" << tag << "\t" << path->VpiFile() << "\t"
                      << path->VpiLineNo() << ":" << path->VpiColumnNo() << "\t"
                      << pname << "\n";
        // ---- E1: the name's index groups
        for (auto& g : idxGroups(pname)) {
            if (!decompileShaped(g)) {
                e1++;
                std::cout << "E1 " << tag << " hier_path @" << loc(path)
                          << " group=[" << g << "] name=" << pname << "\n";
                break;  // one E1 per hier_path: the name is one object
            }
        }
        auto* pe = path->Path_elems();
        if (!pe) continue;
        size_t nel = pe->size(), eli = 0;
        for (auto* el : *pe) {
            elems++;
            bool trailing = (++eli == nel);
            // ---- E4: the TAIL joint on a plain ref_obj element
            if (auto* r = dynamic_cast<const ref_obj*>(el)) {
                std::string f = fullOf(r);
                std::string nm(r->VpiName());
                if (f.size() > nm.size() + 1 &&
                    f.compare(f.size() - nm.size() - 1, nm.size() + 1, "." + nm) == 0) {
                    std::string scope = f.substr(0, f.size() - nm.size() - 1);
                    if (colonRegime(scope)) {
                        e4++;
                        std::cout << "E4 " << tag << " ref_obj @" << loc(r)
                                  << " full=" << f << "\n";
                    }
                }
            }
            const any* ix = idxOf(el);
            if (!ix) continue;
            idxs++;
            if (list)
                std::cout << "LIST " << tag << " path=" << pname << " @" << loc(path)
                          << " elem=" << UhdmName(el->UhdmType())
                          << " idx=" << UhdmName(ix->UhdmType()) << " @" << loc(ix)
                          << " idxfull=" << fullOf(ix) << "\n";
            if (!isTrivialIdx(ix)) {
                // ---- E2: the index's parent
                const any* ip = ix->VpiParent();
                if (ip != (const any*)path) {
                    e2++;
                    std::cout << "E2 " << tag << " " << UhdmName(ix->UhdmType()) << " @"
                              << loc(ix) << " parent="
                              << (ip ? UhdmName(ip->UhdmType()) : "<null>")
                              << " path=" << pname << " @" << loc(path) << "\n";
                }
                // ---- E3: the scope of every NAMED descendant
                std::vector<const any*> ds;
                descend(ix, ds, 0);
                for (auto* d : ds) {
                    if (d == ix) continue;
                    std::string f = fullOf(d);
                    if (f.empty()) continue;
                    if (f.find("::") == std::string::npos &&
                        f.find('.') == std::string::npos)
                        continue;  // a bare dotted path text, not a scoped name
                    if (!pname.empty() && f.find(pname) == std::string::npos) {
                        e3++;
                        std::cout << "E3 " << tag << " " << UhdmName(d->UhdmType())
                                  << " @" << loc(d) << " full=" << f
                                  << " path=" << pname << "\n";
                    }
                }
            }
            // ---- E6 / E7: the two laws' exact firing sets
            if (!trailing) {
                UHDM_OBJECT_TYPE it = ix->UhdmType();
                bool renderedAsItself = (it == uhdmconstant || it == uhdmref_obj ||
                                         it == uhdmoperation);
                bool isSel = (it == uhdmbit_select || it == uhdmpart_select ||
                              it == uhdmindexed_part_select || it == uhdmvar_select);
                if (!renderedAsItself) {
                    e6++;
                    std::cout << "E6 " << tag << " " << UhdmName(it) << " @" << loc(ix)
                              << " path=" << pname << " @" << loc(path) << "\n";
                }
                if (isSel) {
                    e7++;
                    std::cout << "E7 " << tag << " " << UhdmName(it) << " @" << loc(ix)
                              << " path=" << pname << " @" << loc(path) << "\n";
                }
            }
            // ---- E5: the index's span, proxied by its own index's anchor
            const any* inner = idxOf(ix);
            if (inner && ix->VpiLineNo() == inner->VpiLineNo() &&
                ix->VpiColumnNo() == inner->VpiColumnNo()) {
                e5++;
                std::cout << "E5 " << tag << " " << UhdmName(ix->UhdmType()) << " @"
                          << loc(ix) << " == inner @" << loc(inner)
                          << " path=" << pname << "\n";
            }
        }
    }
    std::cout << "TOTALS " << tag << " hp=" << hp << " elems=" << elems
              << " idxs=" << idxs << " e1=" << e1 << " e2=" << e2 << " e3=" << e3
              << " e4=" << e4 << " e5=" << e5 << " e6=" << e6 << " e7=" << e7 << "\n";
    return 0;
}
