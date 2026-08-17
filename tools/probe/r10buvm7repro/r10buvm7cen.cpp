// r10buvm7cen — THE CENSUS INSTRUMENT for § lvIncDecSelMemberCollapse7.
//
// Reads one .uhdm database and reports EVERY inc/dec operation the serializer
// holds (Serializer::AllObjects(), so orphaned objects are counted too: the
// dump only prints what a parent points at, and reprints an object at every
// reference, so a shape census over dump TEXT multiplies).
//
// An inc/dec operation is vpiOpType 62/63/64/65 (post/pre inc, post/pre dec).
// For each one we print its single OPERAND's shape, keyed by line:col so that
// GOLDEN and OURS can be JOINED on the source position:
//
//   INCDEC <line>:<col>-<endline>:<endcol> op=<62|63|64|65> \
//          opnd=<uhdm kind> name=<vpiName> full=<vpiFullName> \
//          nelem=<hier_path path-element count> idx=<index kind or -> \
//          file=<the operand's VpiFile>
//
// The FILE is printed so that a line-number-keyed attribution can be CHECKED
// for collisions: two files of one design can share a line number, and a
// line-only key would then strip more than the law's own statements.
//
// and a classification of the operand as one of
//   PLAIN   — ref_obj whose span is the NAME only            (i++)
//   SEL     — bit_select / var_select / part_select           (q[i]++)
//   PATH    — hier_path                                      (a.b++, ours)
//   WIDEREF — ref_obj whose span is WIDER than its own name   ← THE COLLAPSE
//   WIDESEL — a select whose span is WIDER than name+"[...]"  ← the b5 twin
//   OTHER   — anything else, printed so it is never silent
//
// WIDEREF/WIDESEL are golden's collapse of an inc/dec lvalue whose FIRST step
// after the base is an element SELECT followed by at least one MEMBER: golden
// keeps only the base name (plus the lvalue's TRAILING bracket, if any) and
// spans it over the whole lvalue text.  Ours emits PATH there.
//
// usage: r10buvm7cen <file.uhdm> [tag]
//   R10BUVM7_LIST=1  print every inc/dec row (default prints all rows anyway;
//                    with LIST unset the per-row lines are still printed —
//                    this instrument is small enough that silence is the only
//                    real risk).
// A TOTALS line is printed ALWAYS, including on RESTORE_FAIL, because a run
// that reached nothing must never read as perfection.

#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdlib>
#include <iostream>
#include <string>

using namespace UHDM;

static std::string nameOf(const any* o) {
    if (!o) return "-";
    if (auto* r = dynamic_cast<const ref_obj*>(o)) return std::string(r->VpiName());
    if (auto* b = dynamic_cast<const bit_select*>(o)) return std::string(b->VpiName());
    if (auto* p = dynamic_cast<const part_select*>(o)) return std::string(p->VpiName());
    if (auto* i = dynamic_cast<const indexed_part_select*>(o)) return std::string(i->VpiName());
    if (auto* v = dynamic_cast<const var_select*>(o)) return std::string(v->VpiName());
    if (auto* h = dynamic_cast<const hier_path*>(o)) return std::string(h->VpiName());
    return "-";
}
static std::string fullOf(const any* o) {
    if (!o) return "-";
    if (auto* r = dynamic_cast<const ref_obj*>(o)) return std::string(r->VpiFullName());
    if (auto* b = dynamic_cast<const bit_select*>(o)) return std::string(b->VpiFullName());
    if (auto* h = dynamic_cast<const hier_path*>(o)) return std::string(h->VpiFullName());
    return "-";
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: r10buvm7cen <file.uhdm> [tag]\n"; return 2; }
    std::string tag = argc > 2 ? argv[2] : argv[1];

    Serializer s;
    const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
    if (restored.empty()) {
        std::cout << "RESTORE_FAIL " << tag << "\n";
        std::cout << "TOTALS " << tag << " incdec=0 PLAIN=0 SEL=0 PATH=0 WIDEREF=0 WIDESEL=0 OTHER=0\n";
        return 3;
    }
    long n = 0, plain = 0, sel = 0, path = 0, wideref = 0, widesel = 0, other = 0;
    for (auto& kv : s.AllObjects()) {
        {
            const any* o = kv.first;
            if (!o || o->UhdmType() != uhdmoperation) continue;
            auto* op = (const operation*)o;
            int t = op->VpiOpType();
            if (t != vpiPostIncOp && t != vpiPreIncOp && t != vpiPostDecOp &&
                t != vpiPreDecOp)
                continue;
            const any* a = nullptr;
            if (auto* v = op->Operands()) if (!v->empty()) a = (*v)[0];
            n++;
            std::string kind = a ? std::string(UhdmName(a->UhdmType())) : "<null>";
            std::string nm = nameOf(a);
            std::string cls = "OTHER";
            long nelem = -1;
            std::string ik = "-";
            if (a) {
                uint32_t c0 = a->VpiColumnNo(), c1 = a->VpiEndColumnNo();
                uint32_t l0 = a->VpiLineNo(), l1 = a->VpiEndLineNo();
                bool oneline = (l0 == l1);
                size_t span = oneline && c1 > c0 ? (c1 - c0) : 0;
                if (auto* h = dynamic_cast<const hier_path*>(a)) {
                    cls = "PATH";
                    nelem = h->Path_elems() ? (long)h->Path_elems()->size() : 0;
                }
                else if (a->UhdmType() == uhdmref_obj) {
                    cls = (span > nm.size()) ? "WIDEREF" : "PLAIN";
                }
                else if (a->UhdmType() == uhdmbit_select ||
                         a->UhdmType() == uhdmvar_select ||
                         a->UhdmType() == uhdmpart_select ||
                         a->UhdmType() == uhdmindexed_part_select) {
                    // A plain q[i] spans name + "[" + idxtext + "]"; a collapse
                    // spans MORE than that.  The index text length is unknown
                    // here, so use the index object's OWN span when it is on
                    // the same line: name + 2 + idxspan is the plain width.
                    size_t idxw = 0;
                    const any* ix = nullptr;
                    if (auto* b = dynamic_cast<const bit_select*>(a)) ix = b->VpiIndex();
                    if (ix) {
                        ik = std::string(UhdmName(ix->UhdmType()));
                        if (ix->VpiLineNo() == ix->VpiEndLineNo() &&
                            ix->VpiEndColumnNo() > ix->VpiColumnNo())
                            idxw = ix->VpiEndColumnNo() - ix->VpiColumnNo();
                    }
                    cls = (span > nm.size() + 2 + idxw) ? "WIDESEL" : "SEL";
                }
            }
            if (cls == "PLAIN") plain++;
            else if (cls == "SEL") sel++;
            else if (cls == "PATH") path++;
            else if (cls == "WIDEREF") wideref++;
            else if (cls == "WIDESEL") widesel++;
            else other++;
            std::cout << "INCDEC " << tag << " " << a->VpiLineNo() << ":"
                      << (a ? a->VpiColumnNo() : 0) << "-" << (a ? a->VpiEndLineNo() : 0)
                      << ":" << (a ? a->VpiEndColumnNo() : 0)
                      << " op=" << t << " " << cls << " opnd=" << kind
                      << " name=" << nm << " nelem=" << nelem << " idx=" << ik
                      << " full=" << fullOf(a)
                      << " file=" << (a ? a->VpiFile() : "-") << "\n";
        }
    }
    std::cout << "TOTALS " << tag << " incdec=" << n << " PLAIN=" << plain
              << " SEL=" << sel << " PATH=" << path << " WIDEREF=" << wideref
              << " WIDESEL=" << widesel << " OTHER=" << other << "\n";
    return 0;
}
