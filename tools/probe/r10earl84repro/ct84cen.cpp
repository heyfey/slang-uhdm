// r10earl84 — MEASUREMENT-ONLY.  THE SELECT-BOUND CENSUS.
//
// The official ~/git-repos/UHDM/build/bin/uhdm-cmp remains the sole acceptance
// judge.  This instrument answers, for every SELECT (bit_select, part_select,
// indexed_part_select, var_select) in a database, what object each side put in
// each of its BOUND slots — a `ref_obj` that stayed a reference, or a folded
// `constant` — plus the enclosing `hier_path`'s VpiName, which
// § hpNameBareIdxFold69 makes a FUNCTION of those very objects.
//
// KEY (never scored) — the SELECT's own span, not the bound's, because the
// select object exists in both databases at the same place while a bound that
// folds may be re-stamped:
//   SPAN     line:col-line:col of the SELECT
//   SLOT     IDX (bit_select index) | BASE / WIDTH (indexed_part_select)
//            | LEFT / RIGHT (part_select) | VS<n> (var_select expr n)
//   SEL      the select's UHDM kind
//   INHP     1 when the select is a `hier_path` Path_elem, else 0
//   CTX      context class from the parent walk (PORTHC / PORTLC / CONTASSIGN
//            / PARAMINIT / TASKFUNC / PROCESS / TYPESPEC / OTHER)
//   PORTPAR  the port's own parent kind when CTX is PORTHC/PORTLC:
//            `module_inst` = the ELABORATED connection, `ref_module` = the DEF
//            listing (the § elabConnEmit21 split, read out of the data)
//   CALLARG  1 when a tf/sys call ancestor sits between (the
//            § connCallArgKeepsEnumRef66v carve-out)
//   PSBOUND  1 when a part_select ancestor sits between the select and its
//            context home (compilePartSelectRange hardcodes Reduce::No)
//   ROOT     where the parent walk ends (uvm97: AllObjects can name objects
//            that are not in the dump tree)
//   INST     (--inst only) the VpiFullName of the nearest enclosing
//            `module_inst`.  Two ELABORATED copies of one instantiation line
//            live at the SAME span and differ only by instance, so without it
//            a multiset join pairs a fold in one instance against golden's
//            value in another and reports a phantom.  It is a CONTEXT CLASS in
//            the KEY, never a payload field; the corpus census leaves it OFF so
//            a naming residue cannot masquerade as a fold residue.
// PAYLOAD (scored):
//   KIND  the bound object's UHDM kind (`-` = the slot is empty)
//   NAME  a ref_obj's VpiName (`-` otherwise)
//   SZ VAL CT DEC   a constant's VpiSize / VpiValue / VpiConstType / VpiDecompile
//   TS    the bound's Actual_typespec kind (`-` = NO typespec at all)
//   TSN   that typespec's VpiName
//   TSSG/TSVL/TSRG/TSAL/TSIN/TSCE  the typespec's VpiSigned / VpiValue /
//         range count / Typedef_alias / Instance / Cast_to_expr — every field
//         `typespec::Compare` and `int_typespec::Compare` actually READ, so a
//         typespec that differs only in one of them is not scored as equal
//   HPNM  the enclosing hier_path's VpiName (`-` when INHP=0) — hier_path::
//         Compare READS VpiName, so it belongs in the payload
//   CS    the select's VpiConstantSelect
//   IPT   VpiIndexedPartSelectType for an indexed_part_select
//
// TRAPS AVOIDED (each paid for elsewhere in this campaign):
//  * NESTING DEPTH is never a key (a fold changes the depth of everything
//    beneath it).
//  * `VpiParent` is not a key beyond the CONTEXT CLASS it yields; no generated
//    Compare reads it.
//  * The payload carries NO span-derived field (earl60/earl69: a span-carrying
//    payload hides a real flip).
//  * The DEF/ELAB view is IN THE KEY (via PORTPAR) and never in the payload.
//
// usage: ct84cen <db.uhdm> [--only-hp] [--only-porthc]
// build: g++ -O2 -std=c++17 ct84cen.cpp -I ~/.local/include \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct84cen
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>
#include <set>
#include <map>
#include <algorithm>
using namespace UHDM;

static std::string kindName(const BaseClass* o) {
  if (!o) return "-";
  return std::string(UHDM::UhdmName(o->UhdmType()));
}
static std::string esc(std::string_view v) {
  std::string r;
  for (char c : v) r += (c == ' ' || c == '\t' || c == '|') ? '_' : c;
  if (r.empty()) r = "-";
  return r;
}
static std::string spanOf(const BaseClass* o) {
  char b[64];
  snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(), o->VpiColumnNo(),
           o->VpiEndLineNo(), o->VpiEndColumnNo());
  return b;
}
static const typespec* actualTs(const BaseClass* o) {
  if (!o) return nullptr;
  const ref_typespec* rt = nullptr;
  switch (o->UhdmType()) {
    case uhdmoperation: rt = ((const operation*)o)->Typespec(); break;
    case uhdmconstant:  rt = ((const constant*)o)->Typespec(); break;
    case uhdmref_obj:   rt = ((const ref_obj*)o)->Typespec(); break;
    case uhdmbit_select: rt = ((const bit_select*)o)->Typespec(); break;
    case uhdmpart_select: rt = ((const part_select*)o)->Typespec(); break;
    case uhdmindexed_part_select: rt = ((const indexed_part_select*)o)->Typespec(); break;
    case uhdmhier_path: rt = ((const hier_path*)o)->Typespec(); break;
    default: break;
  }
  return rt ? rt->Actual_typespec() : nullptr;
}

struct Ctx {
  std::string cls = "OTHER";
  std::string portpar = "-";
  std::string root = "-";
  int callarg = 0, psbound = 0;
  std::string inst = "-";
  const hier_path* hp = nullptr;
};

// The walk starts at the SELECT.  `stopHp` is the select's own hier_path
// parent when it is a Path_elem; the psbound/callarg flags are counted from
// the select OUTWARD, so a select's own bounds never mark themselves.
static Ctx ctxOf(const BaseClass* o) {
  Ctx c;
  const BaseClass* prev = o;
  const BaseClass* p = o->VpiParent();
  bool fixed = false;
  const BaseClass* last = o;
  for (int i = 0; i < 128 && p; i++) {
    UHDM_OBJECT_TYPE t = p->UhdmType();
    if (t == uhdmhier_path && !c.hp && prev == o) c.hp = (const hier_path*)p;
    if (t == uhdmmodule_inst && c.inst == "-")
      c.inst = esc(((const module_inst*)p)->VpiFullName());
    if (!fixed) {
      if (t == uhdmfunc_call || t == uhdmtask_call || t == uhdmsys_func_call ||
          t == uhdmsys_task_call || t == uhdmmethod_func_call ||
          t == uhdmmethod_task_call)
        c.callarg = 1;
      if (t == uhdmpart_select || t == uhdmindexed_part_select) c.psbound = 1;
      switch (t) {
        case uhdmport: {
          const port* pt = (const port*)p;
          c.cls = (pt->High_conn() == prev) ? "PORTHC"
                : (pt->Low_conn() == prev)  ? "PORTLC"
                                            : "PORTHC?";
          c.portpar = kindName(p->VpiParent());
          fixed = true;
          break;
        }
        case uhdmcont_assign: c.cls = "CONTASSIGN"; fixed = true; break;
        case uhdmparam_assign: c.cls = "PARAMINIT"; fixed = true; break;
        case uhdmtask: case uhdmfunction: c.cls = "TASKFUNC"; fixed = true; break;
        case uhdmalways: case uhdminitial: case uhdmfinal_stmt:
          c.cls = "PROCESS"; fixed = true; break;
        case uhdmtypespec_member: c.cls = "TYPESPEC"; fixed = true; break;
        default: break;
      }
      if (!fixed) {
        std::string kn = std::string(UHDM::UhdmName(t));
        if (kn.find("_typespec") != std::string::npos) { c.cls = "TYPESPEC"; fixed = true; }
      }
    }
    prev = p;
    last = p;
    p = p->VpiParent();
  }
  c.root = kindName(last);
  return c;
}

int main(int argc, char** argv) {
  if (argc < 2) {
    fprintf(stderr, "usage: ct84cen <db.uhdm> [--only-hp] [--only-porthc]\n");
    return 2;
  }
  bool onlyHp = false, onlyHc = false, wantInst = false;
  for (int i = 2; i < argc; i++) {
    if (!strcmp(argv[i], "--only-hp")) onlyHp = true;
    else if (!strcmp(argv[i], "--only-porthc")) onlyHc = true;
    else if (!strcmp(argv[i], "--inst")) wantInst = true;
  }
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "RESTORE_FAILED %s\n", argv[1]); return 3; }
  auto all = s.AllObjects();

  long nSel = 0, nRow = 0;
  std::vector<std::string> rows;
  for (auto& pr : all) {
    const BaseClass* bo = pr.first;
    if (!bo) continue;
    UHDM_OBJECT_TYPE st = bo->UhdmType();
    if (st != uhdmbit_select && st != uhdmpart_select &&
        st != uhdmindexed_part_select && st != uhdmvar_select)
      continue;
    nSel++;
    Ctx c = ctxOf(bo);
    int inhp = c.hp ? 1 : 0;
    if (onlyHp && !inhp) continue;
    if (onlyHc && c.cls != "PORTHC") continue;
    std::string sp = spanOf(bo);
    std::string cs = "-", ipt = "-";
    std::vector<std::pair<std::string, const any*>> slots;
    if (st == uhdmbit_select) {
      const bit_select* b = (const bit_select*)bo;
      cs = b->VpiConstantSelect() ? "1" : "0";
      slots.push_back({"IDX", b->VpiIndex()});
    } else if (st == uhdmpart_select) {
      const part_select* b = (const part_select*)bo;
      cs = b->VpiConstantSelect() ? "1" : "0";
      slots.push_back({"LEFT", b->Left_range()});
      slots.push_back({"RIGHT", b->Right_range()});
    } else if (st == uhdmindexed_part_select) {
      const indexed_part_select* b = (const indexed_part_select*)bo;
      cs = b->VpiConstantSelect() ? "1" : "0";
      ipt = std::to_string(b->VpiIndexedPartSelectType());
      slots.push_back({"BASE", b->Base_expr()});
      slots.push_back({"WIDTH", b->Width_expr()});
    } else {
      const var_select* b = (const var_select*)bo;
      if (b->Exprs())
        for (size_t k = 0; k < b->Exprs()->size(); k++)
          slots.push_back({"VS" + std::to_string(k), (*b->Exprs())[k]});
    }
    std::string hpnm = c.hp ? esc(c.hp->VpiName()) : "-";
    for (auto& sl : slots) {
      const any* o = sl.second;
      std::string nm = "-", sz = "-", val = "-", ct = "-", dec = "-";
      if (o && o->UhdmType() == uhdmref_obj) nm = esc(((const ref_obj*)o)->VpiName());
      if (o && o->UhdmType() == uhdmconstant) {
        const constant* cc = (const constant*)o;
        sz = std::to_string(cc->VpiSize());
        val = esc(cc->VpiValue());
        ct = std::to_string(cc->VpiConstType());
        dec = esc(cc->VpiDecompile());
      }
      if (o && o->UhdmType() == uhdmoperation)
        nm = "op" + std::to_string(((const operation*)o)->VpiOpType());
      std::string ts = "-", tsn = "-", tssg = "-", tsvl = "-", tsrg = "-",
                  tsal = "-", tsin = "-", tsce = "-";
      if (const typespec* at = actualTs(o)) {
        ts = kindName(at); tsn = esc(at->VpiName());
        tsal = at->Typedef_alias() ? "1" : "0";
        tsin = at->Instance() ? "1" : "0";
        if (at->UhdmType() == uhdmint_typespec) {
          const int_typespec* it = (const int_typespec*)at;
          tssg = it->VpiSigned() ? "1" : "0";
          tsvl = esc(it->VpiValue());
          tsrg = it->Ranges() ? std::to_string(it->Ranges()->size()) : "0";
          tsce = it->Cast_to_expr() ? "1" : "0";
        } else if (at->UhdmType() == uhdminteger_typespec) {
          const integer_typespec* it = (const integer_typespec*)at;
          tssg = it->VpiSigned() ? "1" : "0";
          tsvl = esc(it->VpiValue());
        } else if (at->UhdmType() == uhdmlogic_typespec) {
          const logic_typespec* it = (const logic_typespec*)at;
          tssg = it->VpiSigned() ? "1" : "0";
          tsrg = it->Ranges() ? std::to_string(it->Ranges()->size()) : "0";
        }
      }
      char line[8192];
      snprintf(line, sizeof line,
               "SPAN=%s\tSLOT=%s\tSEL=%s\tINHP=%d\tCTX=%s\tPORTPAR=%s"
               "\tCALLARG=%d\tPSBOUND=%d\tROOT=%s\tINST=%s\t||"
               "\tKIND=%s\tNAME=%s\tSZ=%s\tVAL=%s\tCT=%s\tDEC=%s"
               "\tTS=%s\tTSN=%s\tTSSG=%s\tTSVL=%s\tTSRG=%s\tTSAL=%s"
               "\tTSIN=%s\tTSCE=%s\tHPNM=%s\tCS=%s\tIPT=%s",
               sp.c_str(), sl.first.c_str(), kindName(bo).c_str(), inhp,
               c.cls.c_str(), c.portpar.c_str(), c.callarg, c.psbound,
               c.root.c_str(), wantInst ? c.inst.c_str() : "-",
               kindName(o).c_str(), nm.c_str(), sz.c_str(),
               val.c_str(), ct.c_str(), dec.c_str(), ts.c_str(), tsn.c_str(),
               tssg.c_str(), tsvl.c_str(), tsrg.c_str(), tsal.c_str(),
               tsin.c_str(), tsce.c_str(), hpnm.c_str(), cs.c_str(),
               ipt.c_str());
      rows.push_back(line);
      nRow++;
    }
  }
  std::sort(rows.begin(), rows.end());
  for (auto& l : rows) printf("%s\n", l.c_str());
  fprintf(stderr, "-- selects=%ld rows=%ld\n", nSel, nRow);
  return 0;
}
