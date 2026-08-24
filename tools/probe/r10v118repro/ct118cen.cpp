// r10uvm118 — MEASUREMENT-ONLY.  The OPERATION-TYPESPEC census.
//
// The official ~/git-repos/UHDM/build/bin/uhdm-cmp remains the sole judge; this
// instrument only says WHERE the two databases disagree about an operation and
// its typespec, keyed so golden and ours join on the SAME cell.
//
// ONE ROW PER `operation` object.  Key fields (never scored):
//   SPAN   the operation's own line:col-line:col  (VpiFile is EMPTY on our
//          operations AND on golden's, so the file is not a key)
//   OPT    vpiOpType             NOPS  operand count
//   HOME   the nearest ancestor that is a task/function/process/cont_assign/
//          param_assign/scope, printed kind + vpiFullName
//   REGION the home CLASS this pass splits on: MODPROC / INITFINAL / GENSCOPE /
//          CLASSMETHOD_INBODY / CLASSMETHOD_OOB_FUNC / CLASSMETHOD_OOB_TASK /
//          PKGFUNC / PKGTASK / FREEFUNC / CONTASSIGN / PARAMINIT / OTHER
//   MACRO  1 when the operation's LINE falls outside its HOME's line range,
//          i.e. the span comes from a MACRO DEFINITION file
//   PAR    the parent object's kind (+ its vpiOpType when it is an operation)
// Payload (scored):
//   TS     the Actual_typespec's UHDM kind, or `-` when the operation carries
//          no typespec at all
//   TSLOC  1 when that typespec has a location, 0 when it is loc-less
//   TSNAME its VpiName
//
// KEYING TRAPS AVOIDED (each one cost a measurement elsewhere in this campaign):
//  * VpiParent is NOT part of the key beyond its KIND: no generated Compare
//    reads it, and a re-parented fold would manufacture a phantom cell.
//  * The NESTING DEPTH is not in the key.  This pass's whole subject is an
//    operation WE INSERT and golden does not, which shifts the depth of
//    everything under it; a depth-keyed census would report the entire subtree
//    as moved.  SPAN+OPT+NOPS+HOME joins the surviving cells correctly and
//    leaves the inserted one as a clean ours-only row.
//  * Serializer::AllObjects can name objects that are NOT in the dump tree
//    (uvm97's lesson).  ROOT= records where the parent walk ends, so an
//    unreachable object is visible as such and never silently scored.
//
// modes: --all (every operation)  --ts (only operations carrying a typespec)
//        --cast (only vpiCastOp operations)
// usage: ct118cen <db.uhdm> [--all|--ts|--cast]
// build: g++ -O2 -std=c++17 ct118cen.cpp -I ~/.local/include \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct118cen
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>
#include <algorithm>
using namespace UHDM;

static std::string kindName(const BaseClass* o) {
  if (!o) return "<null>";
  return std::string(UHDM::UhdmName(o->UhdmType()));
}
static std::string esc(std::string_view v) {
  std::string r;
  for (char c : v) r += (c == ' ' || c == '\t' || c == '|') ? '_' : c;
  if (r.empty()) r = "-";
  return r;
}
static std::string fullOf(const BaseClass* o) {
  if (!o) return "-";
  vpiHandle h = NewVpiHandle(o);
  const char* s = h ? vpi_get_str(vpiFullName, h) : nullptr;
  std::string r = s ? s : "";
  if (h) vpi_free_object(h);
  if (r.empty()) r = std::string(o->VpiName());
  return esc(r);
}
static int countSep(const std::string& s) {
  int n = 0;
  for (size_t i = 0; i + 1 < s.size(); i++)
    if (s[i] == ':' && s[i + 1] == ':') { n++; i++; }
  return n;
}

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: ct118cen <db.uhdm> [--all|--ts|--cast]\n"); return 2; }
  const std::string mode = argc > 2 ? argv[2] : "--all";
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "RESTORE_FAILED %s\n", argv[1]); return 3; }
  auto all = s.AllObjects();

  long nOp = 0, nTs = 0, nCast = 0, nCastBareLogic = 0;
  std::vector<std::string> rows;
  for (auto& pr : all) {
    const BaseClass* bo = pr.first;
    if (!bo || bo->UhdmType() != uhdmoperation) continue;
    const operation* op = (const operation*)bo;
    nOp++;
    // ---- typespec payload
    std::string ts = "-", tsname = "-";
    int tsloc = -1;
    if (auto* rt = op->Typespec()) {
      ts = "REF_NO_ACTUAL";
      if (auto* at = rt->Actual_typespec()) {
        ts = kindName(at);
        tsname = esc(at->VpiName());
        tsloc = (at->VpiLineNo() != 0) ? 1 : 0;
      }
    }
    if (ts != "-") nTs++;
    if (op->VpiOpType() == vpiCastOp) {
      nCast++;
      if (ts == "logic_typespec" && tsloc == 0 && tsname == "-") nCastBareLogic++;
    }
    if (mode == "--ts" && ts == "-") continue;
    if (mode == "--cast" && op->VpiOpType() != vpiCastOp) continue;
    // ---- HOME / REGION / ROOT, from the parent walk
    std::string home = "-", homeKind = "-", region = "OTHER", root = "-";
    int homeLine = 0, homeEnd = 0;
    bool genScope = false;
    const BaseClass* p = op->VpiParent();
    const BaseClass* homeObj = nullptr;
    const BaseClass* last = op;
    for (int i = 0; i < 64 && p; i++) {
      UHDM_OBJECT_TYPE t = p->UhdmType();
      if (t == uhdmgen_scope || t == uhdmgen_scope_array) genScope = true;
      if (!homeObj) {
        switch (t) {
          case uhdmtask: case uhdmfunction:
          case uhdmalways: case uhdminitial: case uhdmfinal_stmt:
          case uhdmcont_assign: case uhdmparam_assign:
          case uhdmmodule_inst: case uhdmpackage: case uhdmclass_defn:
            homeObj = p; break;
          default: break;
        }
      }
      last = p;
      p = p->VpiParent();
    }
    root = kindName(last);
    if (homeObj) {
      homeKind = kindName(homeObj);
      home = fullOf(homeObj);
      homeLine = (int)homeObj->VpiLineNo();
      homeEnd = (int)homeObj->VpiEndLineNo();
      UHDM_OBJECT_TYPE ht = homeObj->UhdmType();
      const BaseClass* hp = homeObj->VpiParent();
      UHDM_OBJECT_TYPE pt = hp ? hp->UhdmType() : uhdmdesign;
      if (ht == uhdmtask || ht == uhdmfunction) {
        bool isTask = (ht == uhdmtask);
        if (pt == uhdmclass_defn)
          region = "CLASSMETHOD_INBODY";
        else if (pt == uhdmpackage) {
          // an OUT-OF-BODY class method lands under the PACKAGE in both
          // databases; its fullname carries TWO `::` (pkg::class::method)
          // while a plain package subroutine carries one.
          if (countSep(home) >= 2)
            region = isTask ? "CLASSMETHOD_OOB_TASK" : "CLASSMETHOD_OOB_FUNC";
          else
            region = isTask ? "PKGTASK" : "PKGFUNC";
        }
        else if (pt == uhdmmodule_inst) region = isTask ? "MODTASK" : "MODFUNC";
        else region = isTask ? "FREETASK" : "FREEFUNC";
      }
      else if (ht == uhdmalways) region = "MODPROC";
      else if (ht == uhdminitial || ht == uhdmfinal_stmt) region = "INITFINAL";
      else if (ht == uhdmcont_assign) region = "CONTASSIGN";
      else if (ht == uhdmparam_assign) region = "PARAMINIT";
      else if (ht == uhdmmodule_inst) region = "MODBODY";
      else if (ht == uhdmpackage) region = "PKGBODY";
      else if (ht == uhdmclass_defn) region = "CLASSBODY";
    }
    if (genScope) region = "GENSCOPE_" + region;
    int macro = 0;
    if (homeLine && homeEnd) {
      int l = (int)op->VpiLineNo();
      if (l < homeLine || l > homeEnd) macro = 1;
    }
    const BaseClass* par = op->VpiParent();
    std::string ps = kindName(par);
    if (par && par->UhdmType() == uhdmoperation)
      ps += ":" + std::to_string(((const operation*)par)->VpiOpType());
    char line[8192];
    snprintf(line, sizeof line,
             "OPT=%d\tNOPS=%zu\tSPAN=%u:%u-%u:%u\tREGION=%s\tHOMEK=%s\tHOME=%s"
             "\tMACRO=%d\tPAR=%s\tROOT=%s\t||\tTS=%s\tTSLOC=%d\tTSNAME=%s",
             op->VpiOpType(), op->Operands() ? op->Operands()->size() : 0,
             op->VpiLineNo(), op->VpiColumnNo(), op->VpiEndLineNo(),
             op->VpiEndColumnNo(), region.c_str(), homeKind.c_str(),
             home.c_str(), macro, ps.c_str(), root.c_str(),
             ts.c_str(), tsloc, tsname.c_str());
    rows.push_back(line);
  }
  std::sort(rows.begin(), rows.end());
  for (auto& l : rows) printf("%s\n", l.c_str());
  fprintf(stderr, "-- operations=%ld with-typespec=%ld cast=%ld cast-bare-logic-ts=%ld rows=%zu\n",
          nOp, nTs, nCast, nCastBareLogic, rows.size());
  return 0;
}
