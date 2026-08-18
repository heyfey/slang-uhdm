// r10uvm92 — MEASUREMENT-ONLY.  The OPERATION-INDEX census.
//
// uvm89 decoded `CompileHelper::decompileHelper` (CompileHelper.cpp:2544): the
// index of every component select of a hier_path NAME renders through a CLOSED
// dispatch, and an OPERATION index renders through `ExprEval::prettyPrint`.
// THIS pass owns that second dispatch.  The census keys every hier_path whose
// NAME carries a bracket group built from an OPERATION index by
//
//   FILE:SPAN | NAME | BRK (the bracket text the NAME actually carries)
//   OP=<vpiOpType name>  OPK=<operand UHDM kinds, ','-joined>
//   POS=MID|TRAIL  LVAL=0|1|2  SITE=<kind:fullname>
//   PP=<ExprEval::prettyPrint(the index object)>      <- the GROUND TRUTH
//   PPM=Y|N   (does BRK equal "[" + PP + "]"?)
//
// PP is computed with the REAL UHDM `ExprEval::prettyPrint` off the database's
// OWN tree, so on a GOLDEN database PPM=Y is a direct, per-object proof that
// the decode of the second dispatch is right; on OUR database PP says what the
// text WOULD be if our operation tree were rendered by Surelog's rule, i.e. it
// separates "our tree is wrong" from "our renderer is wrong".
//
// modes:  --op    only rows whose bracket group came from an OPERATION index
//         --brk   every bracket-carrying hier_path row
//         --all   every hier_path row
//
// usage: ct92cen <db.uhdm> [--op|--brk|--all]
// build: g++ -O2 -std=c++17 ct92cen.cpp -I ~/.local/include \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct92cen
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/ExprEval.h>
#include <cstdio>
#include <cstring>
#include <string>
#include <map>
#include <set>
#include <vector>
#include <algorithm>
using namespace UHDM;

static std::string kindName(const BaseClass* o) {
  if (!o) return "<null>";
  return std::string(UHDM::UhdmName(o->UhdmType()));
}
static std::string base(std::string_view p) {
  size_t i = p.find_last_of('/');
  return std::string(i == std::string_view::npos ? p : p.substr(i + 1));
}
static std::string spanOf(const BaseClass* o) {
  char b[64];
  snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(), o->VpiColumnNo(),
           o->VpiEndLineNo(), o->VpiEndColumnNo());
  return std::string(b);
}
static std::string fullOf(const BaseClass* o) {
  if (!o) return "<null>";
  vpiHandle h = NewVpiHandle(o);
  const char* s = h ? vpi_get_str(vpiFullName, h) : nullptr;
  std::string r = s ? s : "";
  if (h) vpi_free_object(h);
  if (r.empty()) r = std::string(o->VpiName());
  if (r.empty()) r = "<anon>";
  return r;
}
static const BaseClass* ownerObj(const BaseClass* o) {
  const BaseClass* p = o ? o->VpiParent() : nullptr;
  for (int i = 0; i < 60 && p; i++) {
    UHDM_OBJECT_TYPE t = p->UhdmType();
    if (t == uhdmclass_defn || t == uhdmpackage || t == uhdmmodule_inst ||
        t == uhdmfunction || t == uhdmtask || t == uhdmgen_scope)
      return p;
    p = p->VpiParent();
  }
  return nullptr;
}
static std::string ownerStr(const BaseClass* o) {
  const BaseClass* p = ownerObj(o);
  if (!p) return "<unparented>";
  return kindName(p) + ":" + fullOf(p);
}
static void indicesOf(const any* e, std::vector<const any*>& out) {
  if (auto* bs = any_cast<const bit_select*>(e)) { out.push_back(bs->VpiIndex()); return; }
  if (auto* ps = any_cast<const part_select*>(e)) {
    out.push_back(ps->Left_range()); out.push_back(ps->Right_range()); return; }
  if (auto* ip = any_cast<const indexed_part_select*>(e)) {
    out.push_back(ip->Base_expr()); out.push_back(ip->Width_expr()); return; }
  if (auto* vs = any_cast<const var_select*>(e)) {
    if (vs->Exprs()) for (auto* x : *vs->Exprs()) out.push_back(x);
    return; }
}
// The bracket text ONE path element contributes, cut out of the PATH NAME with
// a running cursor.  TWO traps this census paid for, both of which read as
// "this object has no brackets" and therefore as a false REFUTATION:
//   * the component name must sit on BOTH boundaries -- start-of-string or '.'
//     before, and '.'/'['/end after -- or `memory` matches inside
//     `i_memory_tb.memory[start + 3]` and `data` inside `data_o.data[...]`;
//   * a SECOND-DIMENSION element carries NO VpiName at all
//     (`rw.value[idx][i0 * 8+:8]`), so a name-anchored scrape finds nothing and
//     a greedy one hands the first element BOTH groups.  The cursor therefore
//     consumes EXACTLY the number of bracket groups the element's own
//     `decompileHelper` row emits: one per select, one per `var_select` expr.
static std::string brkTextFor(const std::string& pathName,
                              const std::string& elemName, size_t groups,
                              size_t& from) {
  size_t q = from;
  if (!elemName.empty()) {
    size_t p = from;
    for (;;) {
      p = pathName.find(elemName, p);
      // NOT FOUND AHEAD OF THE CURSOR is not "no brackets": a second-dimension
      // element repeats the FIRST one's VpiName (`rw.value[idx][i0 * 8+:8]`
      // names both elements `value`), so the name has already been consumed and
      // the cursor is already standing on this element's own group.
      if (p == std::string::npos) { q = from; break; }
      size_t q0 = p + elemName.size();
      bool lb = (p == 0 || pathName[p - 1] == '.');
      bool rb = (q0 == pathName.size() || pathName[q0] == '.' ||
                 pathName[q0] == '[');
      if (lb && rb) { q = q0; break; }
      p++;
    }
  }
  std::string r;
  for (size_t g = 0; g < groups && q < pathName.size() && pathName[q] == '['; g++) {
    int d = 0; size_t st = q;
    while (q < pathName.size()) {
      if (pathName[q] == '[') d++;
      else if (pathName[q] == ']') { d--; if (!d) { q++; break; } }
      q++;
    }
    r += pathName.substr(st, q - st);
  }
  from = q;
  return r.empty() ? "-" : r;
}
static int lvalFlag(const BaseClass* o) {
  const BaseClass* p = o->VpiParent();
  if (!p) return -1;
  if (auto* a = any_cast<const assignment*>((const any*)p))
    return a->Lhs() == (const any*)o ? 1 : 0;
  if (auto* a = any_cast<const assign_stmt*>((const any*)p))
    return a->Lhs() == (const any*)o ? 1 : 0;
  if (auto* a = any_cast<const cont_assign*>((const any*)p))
    return a->Lhs() == (const any*)o ? 1 : 0;
  return 2;
}
// vpiOpType -> spelling, for the KEY only (not a model of prettyPrint).
static std::string opName(int t) {
  switch (t) {
#define R(x) case x: return #x;
    R(vpiMinusOp) R(vpiPlusOp) R(vpiNotOp) R(vpiBitNegOp) R(vpiUnaryAndOp)
    R(vpiUnaryNandOp) R(vpiUnaryOrOp) R(vpiUnaryNorOp) R(vpiUnaryXorOp)
    R(vpiUnaryXNorOp) R(vpiSubOp) R(vpiDivOp) R(vpiModOp) R(vpiEqOp) R(vpiNeqOp)
    R(vpiCaseEqOp) R(vpiCaseNeqOp) R(vpiGtOp) R(vpiGeOp) R(vpiLtOp) R(vpiLeOp)
    R(vpiLShiftOp) R(vpiRShiftOp) R(vpiAddOp) R(vpiMultOp) R(vpiLogAndOp)
    R(vpiLogOrOp) R(vpiBitAndOp) R(vpiBitOrOp) R(vpiBitXorOp) R(vpiBitXNorOp)
    R(vpiConditionOp) R(vpiConcatOp) R(vpiMultiConcatOp) R(vpiEventOrOp)
    R(vpiNullOp) R(vpiListOp) R(vpiMinTypMaxOp) R(vpiPosedgeOp) R(vpiNegedgeOp)
    R(vpiArithLShiftOp) R(vpiArithRShiftOp) R(vpiPowerOp) R(vpiImplyOp)
    R(vpiNonOverlapImplyOp) R(vpiOverlapImplyOp) R(vpiPostIncOp) R(vpiPostDecOp)
    R(vpiPreIncOp) R(vpiPreDecOp) R(vpiInsideOp) R(vpiAssignmentPatternOp)
    R(vpiMultiAssignmentPatternOp) R(vpiCastOp) R(vpiIffOp) R(vpiWildEqOp)
    R(vpiWildNeqOp) R(vpiStreamLROp) R(vpiStreamRLOp) R(vpiAssignmentOp)
    R(vpiTypeOp)
#undef R
    default: break;
  }
  char b[32]; snprintf(b, sizeof b, "op%d", t); return b;
}
// The operand kinds of an operation, one level deep, with a nested operation's
// own optype spelled out so the key separates `i + 1` from `i + (j * 2)`.
static std::string operandKinds(const any* o, int depth = 0) {
  auto* op = any_cast<const operation*>(o);
  if (!op || !op->Operands()) return "";
  std::string r;
  for (auto* x : *op->Operands()) {
    if (!r.empty()) r += ",";
    r += kindName(x);
    if (x->UhdmType() == uhdmoperation) {
      r += "(" + opName(((const operation*)x)->VpiOpType());
      if (depth < 2) { std::string in = operandKinds(x, depth + 1);
                       if (!in.empty()) r += ":" + in; }
      r += ")";
    }
  }
  return r;
}
// A FAITHFUL transcription of Surelog's `CompileHelper::decompileHelper`
// (CompileHelper.cpp:2544) -- the FIRST closed dispatch -- calling the REAL
// `ExprEval::prettyPrint` for its OPERATION row.  Applied to a PATH ELEMENT it
// yields the exact bracket text Surelog's convention-A caller appends, so
// comparing it to the text the NAME actually carries is a per-object oracle for
// BOTH dispatches at once, computed off the database's OWN tree.
static std::string decompileHelper92(const any* sel, ExprEval& eval) {
  if (!sel) return "";
  std::string r;
  UHDM_OBJECT_TYPE t = sel->UhdmType();
  if (t == uhdmconstant) return std::string(((const expr*)sel)->VpiDecompile());
  if (t == uhdmref_obj)  return std::string(((const expr*)sel)->VpiName());
  if (t == uhdmoperation) return eval.prettyPrint(sel);
  if (t == uhdmbit_select) {
    const expr* ix = ((const bit_select*)sel)->VpiIndex();
    if (!ix) return "";
    UHDM_OBJECT_TYPE it = ix->UhdmType();
    if (it == uhdmconstant) return "[" + std::string(ix->VpiDecompile()) + "]";
    if (it == uhdmref_obj)  return "[" + std::string(ix->VpiName()) + "]";
    if (it == uhdmoperation) return "[" + eval.prettyPrint(ix) + "]";
    return "";
  }
  if (auto* ps = any_cast<const part_select*>(sel))
    return "[" + decompileHelper92(ps->Left_range(), eval) + ":" +
           decompileHelper92(ps->Right_range(), eval) + "]";
  if (auto* ip = any_cast<const indexed_part_select*>(sel))
    return "[" + decompileHelper92(ip->Base_expr(), eval) +
           (ip->VpiIndexedPartSelectType() == vpiPosIndexed ? "+" : "-") + ":" +
           decompileHelper92(ip->Width_expr(), eval) + "]";
  if (auto* vs = any_cast<const var_select*>(sel)) {
    if (vs->Exprs()) for (auto* ex : *vs->Exprs()) {
      std::string tmp = decompileHelper92(ex, eval);
      if (!tmp.empty() && tmp[0] != '[') r += "[" + tmp + "]"; else r += tmp;
    }
    return r;
  }
  return "";
}

// ---------------------------------------------------------------- r10uvm94
// The SELECT-ELEMENT census.  uvm92 counted EXPM only over path elements whose
// index is an OPERATION; this pass owns the `indexed_part_select` ROW of
// `decompileHelper` itself, so the oracle is widened to EVERY select-bearing
// path element (bit_select / part_select / indexed_part_select / var_select),
// whatever kind its index/base/width objects are.  On a GOLDEN database a
// single EXPM=N anywhere REFUTES the transcription.
//
// modes:  --sel   rows for hier_paths carrying a part_select / indexed_part_select
//         --op    uvm92 compatibility: rows whose bracket came from an OPERATION
//         --brk   every bracket-carrying hier_path row
//         --all   every hier_path row
// EXPM is counted over ALL select-bearing elements in ALL modes.
static std::string kindOf(const any* o) {
  if (!o) return "<null>";
  std::string k = kindName(o);
  if (o->UhdmType() == uhdmoperation)
    k += "(" + opName(((const operation*)o)->VpiOpType()) + ")";
  if (o->UhdmType() == uhdmsys_func_call)
    k += "(" + std::string(((const sys_func_call*)o)->VpiName()) + ")";
  if (o->UhdmType() == uhdmconstant) {
    const constant* c = (const constant*)o;
    k += "(" + std::to_string(c->VpiConstType()) + ")";
  }
  return k;
}
int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: ct94cen <db.uhdm> [--sel|--op|--brk|--all]\n"); return 2; }
  const std::string mode = argc > 2 ? argv[2] : "--sel";
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "RESTORE_FAILED %s\n", argv[1]); return 3; }
  auto all = s.AllObjects();
  ExprEval eval;

  long nPath = 0, nBrk = 0, nOp = 0, nSel = 0, nY = 0, nN = 0;
  long nIps = 0, nPs = 0, nBs = 0, nVs = 0;
  long nYR = 0, nNR = 0;  // EXPM restricted to the RANGE family (ps/ips)
  long nYI = 0, nNI = 0;  // EXPM restricted to indexed_part_select -- THIS pass's row
  std::vector<std::string> rows;
  for (auto& pr : all) {
    const BaseClass* o = pr.first;
    if (!o || o->UhdmType() != uhdmhier_path) continue;
    auto* hp = (const hier_path*)o;
    nPath++;
    std::string name(hp->VpiName());
    bool brk = name.find('[') != std::string::npos;
    if (brk) nBrk++;
    auto* elems = hp->Path_elems();
    size_t n = elems ? elems->size() : 0;
    size_t from = 0;
    bool anyOp = false, anySel = false;
    std::string cells;
    for (size_t i = 0; i < n; i++) {
      const any* e = elems->at(i);
      std::string en(e->VpiName());
      std::vector<const any*> ix; indicesOf(e, ix);
      if (ix.empty()) { size_t f0 = from; brkTextFor(name, en, 0, f0); from = f0; continue; }
      size_t grp = 1;
      if (auto* vsg = any_cast<const var_select*>(e))
        grp = vsg->Exprs() ? vsg->Exprs()->size() : 0;
      std::string bt = brkTextFor(name, en, grp, from);
      std::string exp = decompileHelper92(e, eval);
      bool expm = (bt == exp);
      // EXPM over EVERY select-bearing element -- the widened oracle.
      if (expm) nY++; else nN++;
      UHDM_OBJECT_TYPE et = e->UhdmType();
      if (et == uhdmindexed_part_select) nIps++;
      else if (et == uhdmpart_select) nPs++;
      else if (et == uhdmbit_select) nBs++;
      else if (et == uhdmvar_select) nVs++;
      bool isRange = (et == uhdmindexed_part_select || et == uhdmpart_select);
      if (isRange) { anySel = true; if (expm) nYR++; else nNR++; }
      if (et == uhdmindexed_part_select) { if (expm) nYI++; else nNI++; }
      std::string key = std::string(i + 1 < n ? "MID" : "TRAIL") +
                        ":ELEM=" + kindName(e);
      if (auto* ip = any_cast<const indexed_part_select*>(e))
        key += ":PST=" + std::string(ip->VpiIndexedPartSelectType() == vpiPosIndexed ? "+:" : "-:") +
               ":BASEK=" + kindOf(ip->Base_expr()) + ":WIDK=" + kindOf(ip->Width_expr());
      else if (auto* ps = any_cast<const part_select*>(e))
        key += ":LK=" + kindOf(ps->Left_range()) + ":RK=" + kindOf(ps->Right_range());
      else {
        std::string ks;
        for (auto* x : ix) { if (!ks.empty()) ks += ","; ks += kindOf(x); }
        key += ":IXK=" + ks;
      }
      for (size_t k = 0; k < ix.size(); k++)
        if (ix[k] && ix[k]->UhdmType() == uhdmoperation) anyOp = true;
      if (!cells.empty()) cells += ";";
      cells += key + ":BRK=" + bt + ":EXP=" + exp + ":EXPM=" + (expm ? "Y" : "N");
    }
    if (anyOp) nOp++;
    if (anySel) nSel++;
    if (mode == "--op" && !anyOp) continue;
    if (mode == "--sel" && !anySel) continue;
    if (mode == "--brk" && !brk) continue;
    char line[16384];
    snprintf(line, sizeof line,
             "%s|%s\tNAME=%s\tNELEM=%zu\tLVAL=%d\tCELLS=%s\tSITE=%s",
             base(o->VpiFile()).c_str(), spanOf(o).c_str(), name.c_str(), n,
             lvalFlag(o), cells.empty() ? "-" : cells.c_str(),
             ownerStr(o).c_str());
    rows.push_back(line);
  }
  std::sort(rows.begin(), rows.end());
  for (auto& l : rows) printf("%s\n", l.c_str());
  fprintf(stderr,
          "-- hier_path=%ld brk=%ld with-op-index=%ld with-range-sel=%ld  "
          "elems ips=%ld ps=%ld bs=%ld vs=%ld  EXPM_Y=%ld EXPM_N=%ld  RNG_Y=%ld RNG_N=%ld  IPS_Y=%ld IPS_N=%ld  rows=%zu\n",
          nPath, nBrk, nOp, nSel, nIps, nPs, nBs, nVs, nY, nN, nYR, nNR, nYI, nNI, rows.size());
  return 0;
}
