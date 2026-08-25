// r10earl91 — MEASUREMENT-ONLY.  THE ASSIGNMENT-PATTERN OPERAND CENSUS.
//
// Companion to ct91cen (which keys on hier_paths).  This one enumerates EVERY
// operand of EVERY `operation` whose VpiOpType is an assignment-pattern or a
// concat, and prints the fields `expr::Compare` reads on the OPERAND
// (VpiDecompile / **VpiSize** / Typespec) plus the operand's kind and index —
// so "which operand does golden SIZE, and at what?" is a table, not a guess.
//
// KEY:  SPAN of the parent operation | POP its VpiOpType | IDX the operand
//       index | NOPS the operand count | CTX / LHSK / LHSTS as in ct91cen |
//       INST (--inst)
// PAYLOAD: KIND SZ DEC VAL CT NAME TS
//
// usage: ct91pat <db.uhdm> [--inst]
// build: g++ -O2 -std=c++17 ct91pat.cpp -I ~/.local/include \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct91pat
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>
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
    case uhdmvar_select: rt = ((const var_select*)o)->Typespec(); break;
    case uhdmlogic_net: rt = ((const logic_net*)o)->Typespec(); break;
    case uhdmlogic_var: rt = ((const logic_var*)o)->Typespec(); break;
    case uhdmarray_net: rt = ((const array_net*)o)->Typespec(); break;
    case uhdmarray_var: rt = ((const array_var*)o)->Typespec(); break;
    case uhdmstruct_net: rt = ((const struct_net*)o)->Typespec(); break;
    case uhdmstruct_var: rt = ((const struct_var*)o)->Typespec(); break;
    default: break;
  }
  return rt ? rt->Actual_typespec() : nullptr;
}
int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: ct91pat <db.uhdm> [--inst]\n"); return 2; }
  bool wantInst = false;
  for (int i = 2; i < argc; i++) if (!strcmp(argv[i], "--inst")) wantInst = true;
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "RESTORE_FAILED %s\n", argv[1]); return 3; }
  auto all = s.AllObjects();
  std::vector<std::string> rows;
  long nOp = 0;
  for (auto& pr : all) {
    const BaseClass* bo = pr.first;
    if (!bo || bo->UhdmType() != uhdmoperation) continue;
    const operation* op = (const operation*)bo;
    int t = op->VpiOpType();
    if (t != vpiAssignmentPatternOp && t != vpiMultiAssignmentPatternOp &&
        t != vpiConcatOp)
      continue;
    if (!op->Operands()) continue;
    nOp++;
    // context walk (cont_assign target type is what adjustOpSize dispatches on)
    std::string cls = "OTHER", lhsk = "-", lhsts = "-", inst = "-";
    {
      const BaseClass* p = bo->VpiParent();
      bool fixed = false;
      for (int i = 0; i < 128 && p; i++) {
        if (p->UhdmType() == uhdmmodule_inst && inst == "-")
          inst = esc(((const module_inst*)p)->VpiFullName());
        if (!fixed) {
          if (p->UhdmType() == uhdmcont_assign) {
            cls = "CONTASSIGN";
            const cont_assign* ca = (const cont_assign*)p;
            lhsk = kindName(ca->Lhs());
            if (const typespec* lt = actualTs(ca->Lhs())) lhsts = kindName(lt);
            fixed = true;
          } else if (p->UhdmType() == uhdmparam_assign) { cls = "PARAMINIT"; fixed = true; }
          else if (p->UhdmType() == uhdmport) { cls = "PORT"; fixed = true; }
          else if (p->UhdmType() == uhdmassignment) { cls = "PROCASSIGN"; fixed = true; }
          else if (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask) { cls = "TASKFUNC"; fixed = true; }
        }
        p = p->VpiParent();
      }
    }
    size_t n = op->Operands()->size();
    std::string psp = spanOf(bo);
    std::string pts = "-";
    if (const typespec* at = actualTs(bo)) pts = kindName(at);
    for (size_t k = 0; k < n; k++) {
      const any* o = (*op->Operands())[k];
      std::string nm = "-", sz = "-", val = "-", ct = "-", dec = "-";
      if (o) {
        if (const expr* e = any_cast<const expr*>(o)) {
          sz = std::to_string(e->VpiSize());
          dec = esc(e->VpiDecompile());
        }
        nm = esc(o->VpiName());
        if (o->UhdmType() == uhdmconstant) {
          const constant* cc = (const constant*)o;
          val = esc(cc->VpiValue());
          ct = std::to_string(cc->VpiConstType());
        }
      }
      std::string ts = "-";
      if (const typespec* at = actualTs(o)) ts = kindName(at);
      char line[8192];
      snprintf(line, sizeof line,
               "PSPAN=%s\tPOP=%d\tNOPS=%zu\tIDX=%zu\tCTX=%s\tLHSK=%s\tLHSTS=%s"
               "\tPTS=%s\tINST=%s\t||\tKIND=%s\tSZ=%s\tDEC=%s\tVAL=%s\tCT=%s\tNAME=%s\tTS=%s",
               psp.c_str(), t, n, k, cls.c_str(), lhsk.c_str(), lhsts.c_str(),
               pts.c_str(), wantInst ? inst.c_str() : "-",
               kindName(o).c_str(), sz.c_str(), dec.c_str(), val.c_str(),
               ct.c_str(), nm.c_str(), ts.c_str());
      rows.push_back(line);
    }
  }
  std::sort(rows.begin(), rows.end());
  for (auto& l : rows) printf("%s\n", l.c_str());
  fprintf(stderr, "-- pattern/concat ops=%ld\n", nOp);
  return 0;
}
