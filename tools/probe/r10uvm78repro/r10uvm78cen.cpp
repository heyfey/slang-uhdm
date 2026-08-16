// r10uvm78cen — the pass's CENSUS INSTRUMENT.
//
// Reads one .uhdm database and reports, for EVERY part_select and
// indexed_part_select the serializer holds (Serializer::AllObjects(), so
// unreachable/orphaned objects are counted too — the dump only shows what a
// parent points at):
//
//   D2  vpiConstantSelect is FALSE           (residue R2 of pass 77)
//   D4  the select's OWN cached fullname uses `.` in a `::` scope
//   D3  a bound ref under this select carries a fullname whose joint to the
//       select's OWN base name is a `.` where the select's own fullname uses
//       `::`                                  (residue R3 of pass 77)
//
// D3 is detected WITHOUT assuming the emitter: the select's effective fullname
// F (explicit VpiFullName, else UHDM's lazily computed one) is split at its
// LAST separator into scope S and base N; a descendant ref whose fullname
// begins with S + "." + N + <sep> when F begins with S + "::" + N is the
// defect.  Golden is expected to show ZERO of both.
//
// usage: r10uvm78cen <file.uhdm> [tag]
// prints one line per defective object, then a TOTALS line ALWAYS (a run that
// reached nothing must never read as perfection).

#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdlib>
#include <iostream>
#include <string>
#include <vector>

using namespace UHDM;

static std::string effFull(const any* o) {
    // VpiFullName() on these classes returns the explicit value when set and
    // the lazily computed parent-chain name otherwise.
    if (auto* ps = dynamic_cast<const part_select*>(o))
        return std::string(ps->VpiFullName());
    if (auto* ip = dynamic_cast<const indexed_part_select*>(o))
        return std::string(ip->VpiFullName());
    return "";
}

// Collect every descendant expression of the two bound slots.
static void collectRefs(const any* root, std::vector<const any*>& out,
                        int depth) {
    if (!root || depth > 12) return;
    out.push_back(root);
    if (auto* op = dynamic_cast<const operation*>(root)) {
        if (auto* ops = op->Operands())
            for (auto* e : *ops) collectRefs(e, out, depth + 1);
    }
    if (auto* bs = dynamic_cast<const bit_select*>(root)) {
        (void)bs;
    }
    if (auto* vs = dynamic_cast<const var_select*>(root)) {
        if (auto* ex = vs->Exprs())
            for (auto* e : *ex) collectRefs(e, out, depth + 1);
    }
    if (auto* ps = dynamic_cast<const part_select*>(root)) {
        collectRefs(ps->Left_range(), out, depth + 1);
        collectRefs(ps->Right_range(), out, depth + 1);
    }
    if (auto* ip = dynamic_cast<const indexed_part_select*>(root)) {
        collectRefs(ip->Base_expr(), out, depth + 1);
        collectRefs(ip->Width_expr(), out, depth + 1);
    }
}

static std::string refFull(const any* o) {
    if (auto* r = dynamic_cast<const ref_obj*>(o))
        return std::string(r->VpiFullName());
    if (auto* b = dynamic_cast<const bit_select*>(o))
        return std::string(b->VpiFullName());
    if (auto* v = dynamic_cast<const var_select*>(o))
        return std::string(v->VpiFullName());
    return "";
}

static std::string loc(const any* o) {
    return std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo());
}

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "usage: r10uvm78cen <file.uhdm> [tag]\n";
        return 2;
    }
    std::string tag = argc > 2 ? argv[2] : argv[1];
    Serializer s;
    auto restored = s.Restore(std::string(argv[1]));
    if (restored.empty()) {
        std::cout << "TOTALS " << tag << " RESTORE_FAIL sel=0 d2=0 d3=0 d4=0 d5=0\n";
        return 3;
    }
    auto all = s.AllObjects();
    long nsel = 0, d2 = 0, d3 = 0, d4 = 0, d5 = 0;
    for (auto& kv : all) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        UHDM_OBJECT_TYPE t = o->UhdmType();
        // D5 — the SAME `.`-for-`::` joint one family over: a BIT_SELECT
        // whose index is an OPERATION re-scopes its nested refs through the
        // select's base name too (ExprEmit.cpp `idxPrefix`).  Counted, never
        // fixed by this pass — it is residue R5 and its population is the
        // next pass's brief.
        if (t == uhdmbit_select) {
            auto* bsx = (const bit_select*)o;
            std::string bn(bsx->VpiName());
            std::string bf(bsx->VpiFullName());
            if (!bn.empty() && bf.size() > bn.size() + 2 &&
                bf.compare(bf.size() - bn.size(), bn.size(), bn) == 0 &&
                bf.compare(bf.size() - bn.size() - 2, 2, "::") == 0) {
                std::string S5 = bf.substr(0, bf.size() - bn.size() - 2);
                std::string w5 = S5 + "." + bn;
                std::vector<const any*> ik;
                collectRefs(bsx->VpiIndex(), ik, 0);
                for (auto* k : ik) {
                    std::string rf = refFull(k);
                    if (rf.size() > w5.size() &&
                        rf.compare(0, w5.size(), w5) == 0 &&
                        (rf[w5.size()] == ':' || rf[w5.size()] == '.')) {
                        d5++;
                        std::cout << "D5 " << tag << " bit_select " << bn
                                  << " @" << loc((const any*)o)
                                  << " selfull=" << bf << " reffull=" << rf
                                  << "\n";
                    }
                }
            }
        }
        if (t != uhdmpart_select && t != uhdmindexed_part_select) continue;
        nsel++;
        bool cs = false;
        std::vector<const any*> kids;
        std::string base;
        if (t == uhdmpart_select) {
            auto* ps = (const part_select*)o;
            cs = ps->VpiConstantSelect();
            collectRefs(ps->Left_range(), kids, 0);
            collectRefs(ps->Right_range(), kids, 0);
            base = std::string(ps->VpiName());
        }
        else {
            auto* ip = (const indexed_part_select*)o;
            cs = ip->VpiConstantSelect();
            collectRefs(ip->Base_expr(), kids, 0);
            collectRefs(ip->Width_expr(), kids, 0);
            base = std::string(ip->VpiName());
        }
        std::string F = effFull((const any*)o);
        // R10UVM78_LIST=1 dumps the RAW joint inventory (select + every bound
        // ref) with no predicate at all, so a claim about golden's joints can
        // be read off the artifact instead of inferred from a detector.
        if (getenv("R10UVM78_LIST")) {
            std::cout << "SEL " << tag << " " << UhdmName(t) << " " << base
                      << " @" << loc((const any*)o) << " full=" << F << "\n";
            for (auto* k : kids) {
                std::string rf = refFull(k);
                if (!rf.empty())
                    std::cout << "  REF " << tag << " @"
                              << loc((const any*)o) << " " << rf << "\n";
            }
        }
        // D4 — the select's OWN cached fullname joins its base name with a `.`
        // while the scope it hangs in is `::`-regime (first `::` precedes any
        // `.`).  UHDM's ComputeFullName uses ONE separator for the WHOLE chain
        // (`::` iff a package/class_defn is an ancestor), so a `.` there is the
        // SAME defect as D3 spelt on the select instead of on its bound ref.
        if (!base.empty() && F.size() > base.size() + 1 &&
            F.compare(F.size() - base.size(), base.size(), base) == 0 &&
            F[F.size() - base.size() - 1] == '.') {
            std::string S = F.substr(0, F.size() - base.size() - 1);
            size_t c = S.find("::"), d = S.find('.');
            if (c != std::string::npos && (d == std::string::npos || c < d)) {
                d4++;
                std::cout << "D4 " << tag << " " << UhdmName(t) << " " << base
                          << " @" << loc((const any*)o) << " full=" << F << "\n";
            }
        }
        if (!cs) {
            d2++;
            std::cout << "D2 " << tag << " " << UhdmName(t) << " " << base
                      << " @" << loc((const any*)o) << " full=" << F << "\n";
        }
        // D3: F must end in "::" + base for the defect to be POSSIBLE.
        if (!base.empty() && F.size() > base.size() + 2 &&
            F.compare(F.size() - base.size(), base.size(), base) == 0 &&
            F.compare(F.size() - base.size() - 2, 2, "::") == 0) {
            std::string S = F.substr(0, F.size() - base.size() - 2);
            std::string wrong = S + "." + base;
            for (auto* k : kids) {
                std::string rf = refFull(k);
                if (rf.size() > wrong.size() &&
                    rf.compare(0, wrong.size(), wrong) == 0 &&
                    (rf[wrong.size()] == ':' || rf[wrong.size()] == '.')) {
                    d3++;
                    std::cout << "D3 " << tag << " " << UhdmName(t) << " "
                              << base << " @" << loc((const any*)o)
                              << " selfull=" << F << " reffull=" << rf << "\n";
                }
            }
        }
    }
    std::cout << "TOTALS " << tag << " sel=" << nsel << " d2=" << d2
              << " d3=" << d3 << " d4=" << d4 << " d5=" << d5 << "\n";
    return 0;
}
