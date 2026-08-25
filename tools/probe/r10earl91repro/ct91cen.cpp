// r10earl91 — MEASUREMENT-ONLY.  THE hier_path CENSUS.
//
// The official ~/git-repos/UHDM/build/bin/uhdm-cmp remains the sole acceptance
// judge.  This instrument answers, for EVERY `hier_path` in a database, what
// each side put in the fields `hier_path::Compare` actually reads:
//   expr::Compare  ->  VpiDecompile, **VpiSize**, Typespec
//   hier_path      ->  Path_elems (vector), Root_value, VpiName
// and nothing else.  (`~/git-repos/UHDM/build/generated/src/hier_path.cpp:110`
// delegates to `basetype_t::Compare` FIRST, and that chain reaches
// `expr::Compare` at `expr.cpp:85`, whose scored lines are VpiDecompile,
// VpiSize, Typespec — in that order, all BEFORE Path_elems.)
//
// KEY (never scored):
//   SPAN     line:col-line:col of the hier_path itself
//   PKIND    the VpiParent's UHDM kind
//   POP      the parent operation's VpiOpType (`-` when the parent is not an
//            operation) — an assignment pattern is 96 (vpiAssignmentPatternOp),
//            a concat 30, a multi-assignment pattern 97
//   OPIDX    the hier_path's index inside that parent operation's Operands
//            (`-` otherwise) — "the FIRST operand" is a POSITION law, so the
//            position has to be in the key
//   CTX      context class from the parent walk (PORTHC / PORTLC / CONTASSIGN
//            / PARAMINIT / TASKFUNC / PROCESS / TYPESPEC / OTHER)
//   PORTPAR  the port's own parent kind when CTX is PORTHC/PORTLC
//            (`module_inst` = the ELABORATED connection, `ref_module` = the
//            DEF listing — the § elabConnEmit21 split, read out of the data)
//   LHSK     the enclosing cont_assign's Lhs kind  (`-` otherwise)
//   LHSTS    the enclosing cont_assign's Lhs Actual_typespec kind — THE
//            PATTERN TARGET'S DECLARED TYPE, which is what Surelog's
//            `adjustOpSize` dispatches on
//   CALLARG  1 when a tf/sys call ancestor sits between
//   INSEL    1 when the hier_path is itself inside a select's bound
//   ROOT     where the parent walk ends
//   INST     (--inst only) VpiFullName of the nearest enclosing module_inst
// PAYLOAD (scored — every field a generated Compare reads):
//   SZ    VpiSize  (`0` is UNSET; that is the whole point of this pass)
//   DEC   VpiDecompile
//   NAME  VpiName
//   NEL   Path_elems size            ELEMS  their kinds:names, joined by '/'
//   RV    Root_value kind
//   TS    Actual_typespec kind / TSN its VpiName / TSRG its range count
//
// TRAPS AVOIDED: no span-derived field in the PAYLOAD (earl60's attrv60
// lesson); VpiParent only as a CONTEXT CLASS; nesting depth never a key.
//
// usage: ct91cen <db.uhdm> [--inst]
// build: g++ -O2 -std=c++17 ct91cen.cpp -I ~/.local/include \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct91cen
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>
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
    case uhdmhier_path: rt = ((const hier_path*)o)->Typespec(); break;
    case uhdmbit_select: rt = ((const bit_select*)o)->Typespec(); break;
    case uhdmpart_select: rt = ((const part_select*)o)->Typespec(); break;
    case uhdmindexed_part_select: rt = ((const indexed_part_select*)o)->Typespec(); break;
    case uhdmvar_select: rt = ((const var_select*)o)->Typespec(); break;
    case uhdmlogic_net: rt = ((const logic_net*)o)->Typespec(); break;
    case uhdmlogic_var: rt = ((const logic_var*)o)->Typespec(); break;
    case uhdmarray_net: rt = ((const array_net*)o)->Typespec(); break;
    case uhdmarray_var: rt = ((const array_var*)o)->Typespec(); break;
    case uhdmstruct_net: rt = ((const struct_net*)o)->Typespec(); break;
    case uhdmstruct_var: rt = ((const struct_var*)o)->Typespec(); break;
    case uhdmpacked_array_net: rt = ((const packed_array_net*)o)->Typespec(); break;
    case uhdmpacked_array_var: rt = ((const packed_array_var*)o)->Typespec(); break;
    default: break;
  }
  return rt ? rt->Actual_typespec() : nullptr;
}

struct Ctx {
  std::string cls = "OTHER";
  std::string portpar = "-";
  std::string root = "-";
  std::string lhsk = "-";
  std::string lhsts = "-";
  int callarg = 0, insel = 0;
  std::string inst = "-";
};

static Ctx ctxOf(const BaseClass* o) {
  Ctx c;
  const BaseClass* prev = o;
  const BaseClass* p = o->VpiParent();
  bool fixed = false;
  const BaseClass* last = o;
  for (int i = 0; i < 128 && p; i++) {
    UHDM_OBJECT_TYPE t = p->UhdmType();
    if (t == uhdmmodule_inst && c.inst == "-")
      c.inst = esc(((const module_inst*)p)->VpiFullName());
    if (!fixed) {
      if (t == uhdmfunc_call || t == uhdmtask_call || t == uhdmsys_func_call ||
          t == uhdmsys_task_call || t == uhdmmethod_func_call ||
          t == uhdmmethod_task_call)
        c.callarg = 1;
      if (t == uhdmpart_select || t == uhdmindexed_part_select ||
          t == uhdmbit_select || t == uhdmvar_select)
        c.insel = 1;
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
        case uhdmcont_assign: {
          c.cls = "CONTASSIGN";
          const cont_assign* ca = (const cont_assign*)p;
          c.lhsk = kindName(ca->Lhs());
          if (const typespec* lt = actualTs(ca->Lhs())) c.lhsts = kindName(lt);
          fixed = true;
          break;
        }
        case uhdmparam_assign: c.cls = "PARAMINIT"; fixed = true; break;
        case uhdmtask: case uhdmfunction: c.cls = "TASKFUNC"; fixed = true; break;
        case uhdmalways: case uhdminitial: case uhdmfinal_stmt:
          c.cls = "PROCESS"; fixed = true; break;
        case uhdmassignment: case uhdmassign_stmt:
          c.cls = "PROCASSIGN"; fixed = true; break;
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
  if (argc < 2) { fprintf(stderr, "usage: ct91cen <db.uhdm> [--inst]\n"); return 2; }
  bool wantInst = false;
  for (int i = 2; i < argc; i++) if (!strcmp(argv[i], "--inst")) wantInst = true;
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "RESTORE_FAILED %s\n", argv[1]); return 3; }
  auto all = s.AllObjects();
  long nHp = 0;
  std::vector<std::string> rows;
  for (auto& pr : all) {
    const BaseClass* bo = pr.first;
    if (!bo || bo->UhdmType() != uhdmhier_path) continue;
    nHp++;
    const hier_path* hp = (const hier_path*)bo;
    Ctx c = ctxOf(bo);
    const BaseClass* par = bo->VpiParent();
    std::string pkind = kindName(par);
    std::string pop = "-", opidx = "-";
    if (par && par->UhdmType() == uhdmoperation) {
      const operation* po = (const operation*)par;
      pop = std::to_string(po->VpiOpType());
      if (po->Operands())
        for (size_t k = 0; k < po->Operands()->size(); k++)
          if ((*po->Operands())[k] == bo) { opidx = std::to_string(k); break; }
    }
    std::string elems = "-";
    int nel = 0;
    if (hp->Path_elems()) {
      elems.clear();
      nel = (int)hp->Path_elems()->size();
      for (auto* e : *hp->Path_elems()) {
        if (!elems.empty()) elems += "/";
        elems += kindName(e);
        elems += ":";
        elems += esc(e->VpiName());
      }
      if (elems.empty()) elems = "-";
    }
    std::string ts = "-", tsn = "-", tsrg = "-";
    if (const typespec* at = actualTs(bo)) {
      ts = kindName(at); tsn = esc(at->VpiName());
      if (at->UhdmType() == uhdmlogic_typespec)
        tsrg = ((const logic_typespec*)at)->Ranges()
                   ? std::to_string(((const logic_typespec*)at)->Ranges()->size()) : "0";
    }
    char line[16384];
    snprintf(line, sizeof line,
             "SPAN=%s\tPKIND=%s\tPOP=%s\tOPIDX=%s\tCTX=%s\tPORTPAR=%s"
             "\tLHSK=%s\tLHSTS=%s\tCALLARG=%d\tINSEL=%d\tROOT=%s\tINST=%s\t||"
             "\tSZ=%d\tDEC=%s\tNAME=%s\tNEL=%d\tELEMS=%s\tRV=%s"
             "\tTS=%s\tTSN=%s\tTSRG=%s",
             spanOf(bo).c_str(), pkind.c_str(), pop.c_str(), opidx.c_str(),
             c.cls.c_str(), c.portpar.c_str(), c.lhsk.c_str(), c.lhsts.c_str(),
             c.callarg, c.insel, c.root.c_str(),
             wantInst ? c.inst.c_str() : "-",
             hp->VpiSize(), esc(hp->VpiDecompile()).c_str(),
             esc(hp->VpiName()).c_str(), nel, elems.c_str(),
             kindName(hp->Root_value()).c_str(), ts.c_str(), tsn.c_str(),
             tsrg.c_str());
    rows.push_back(line);
  }
  std::sort(rows.begin(), rows.end());
  for (auto& l : rows) printf("%s\n", l.c_str());
  fprintf(stderr, "-- hier_paths=%ld\n", nHp);
  return 0;
}
