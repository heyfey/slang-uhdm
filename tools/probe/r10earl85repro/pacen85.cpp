// r10earl85 — MEASUREMENT-ONLY.  THE param_assign CENSUS.
//
// The official ~/git-repos/UHDM/build/bin/uhdm-cmp remains the sole acceptance
// judge.  This instrument reads a `.uhdm` DIRECTLY (never a whole-dump diff --
// Earlgrey's dump is >1 GB; earl61's direct-reader pattern) and enumerates
// EVERY `param_assign` in the database, so a Rhs that FOLDED on one side and
// stayed an operation on the other is found under the SAME key, and so is a
// `vpiOverriden` that only one side stamps.
//
// `param_assign::Compare` (UHDM/build/generated/src/param_assign.cpp:94) reads,
// IN THIS ORDER: VpiConnByName, VpiOverriden, Rhs, Lhs, Attributes.  So
// VpiOverriden is decided BEFORE the Rhs is ever looked at -- both are in the
// payload and both are scored.
//
// KEY (never scored):
//   SPAN  the param_assign's own line:col-line:col
//   VIEW  DEF when the nearest enclosing instance's VpiFullName equals its
//         VpiDefName (the definition copy) else ELAB
//   HOME  MODULE | GENSCOPE | PACKAGE | IFACE | CLASS | PROGRAM | OTHER,
//         from the nearest enclosing scope kind
//   PNAME the Lhs parameter's VpiName
//   INST  (--inst only) the nearest enclosing instance's VpiFullName.  Two
//         ELABORATED copies of one declaration live at the SAME span and differ
//         only by instance; it is a CONTEXT CLASS in the KEY, never a payload.
// PAYLOAD (scored -- only fields a generated Compare actually reads):
//   OV    VpiOverriden      CBN   VpiConnByName
//   RK    Rhs UHDM kind ('-' when the slot is empty)
//   ROP   Rhs VpiOpType when RK is an operation, else '-'
//   RN    Rhs VpiName ('-' unless a ref_obj/named object)
//   RSZ RVAL RCT RDEC   a Rhs constant's VpiSize / VpiValue / VpiConstType /
//         VpiDecompile (constant::Compare reads all four)
//   RTS RTSSG RTSRG     the Rhs's Actual_typespec kind, VpiSigned, range count
//   NOPD  Rhs operand count when RK is an operation
//   O0K O0OP O0SZ O0VAL O0CT   the FIRST operand's kind / opType / size /
//         value / const type -- the fold state of the thing the unary sits on
//   LTS LTSRG LTSREF    the Lhs parameter's Actual_typespec kind, its range
//         count, and the NAMES any ref_obj inside those ranges carries
//         (Surelog's CompileHelper::isOverloaded walks exactly that and stamps
//         VpiOverriden when one of them is an overridden parameter of the
//         instance -- CompileType.cpp:2230-2330)
//   LLP   the Lhs parameter's VpiLocalParam
//
// TRAPS AVOIDED: no span-derived field in the PAYLOAD (earl60/earl69: a
// span-carrying payload hides a real flip); VpiParent is never a key beyond the
// context class it yields (no generated Compare reads it); NESTING DEPTH is
// never a key (a fold changes the depth of everything beneath it); rows are
// emitted for EVERY param_assign, not only the unary ones, so a cell moved BY
// ACCIDENT is still visible (earl66's lesson).
//
// usage: pacen85 <db.uhdm> [--inst] [--only-unary]
// build: g++ -O2 -std=c++17 pacen85.cpp -I ~/.local/include \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o pacen85
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
static const typespec* actualTs(const ref_typespec* rt) {
  return rt ? rt->Actual_typespec() : nullptr;
}
static const typespec* tsOfExpr(const BaseClass* o) {
  if (!o) return nullptr;
  switch (o->UhdmType()) {
    case uhdmoperation: return actualTs(((const operation*)o)->Typespec());
    case uhdmconstant:  return actualTs(((const constant*)o)->Typespec());
    case uhdmref_obj:   return actualTs(((const ref_obj*)o)->Typespec());
    default: return nullptr;
  }
}
static int rangeCount(const typespec* t) {
  if (!t) return -1;
  switch (t->UhdmType()) {
    case uhdmlogic_typespec: {
      auto* r = ((const logic_typespec*)t)->Ranges(); return r ? (int)r->size() : 0; }
    case uhdmbit_typespec: {
      auto* r = ((const bit_typespec*)t)->Ranges(); return r ? (int)r->size() : 0; }
    case uhdmarray_typespec: {
      auto* r = ((const array_typespec*)t)->Ranges(); return r ? (int)r->size() : 0; }
    case uhdmpacked_array_typespec: {
      auto* r = ((const packed_array_typespec*)t)->Ranges(); return r ? (int)r->size() : 0; }
    default: return 0;
  }
}
// Mirror of CompileHelper::isOverloaded's walk (CompileType.cpp:2230): collect
// the NAMES of every ref_obj/parameter reachable from the typespec's ranges.
static void collectRefNames(const BaseClass* o, std::set<std::string>& out, int d) {
  if (!o || d > 12) return;
  switch (o->UhdmType()) {
    case uhdmrange: {
      const range* r = (const range*)o;
      collectRefNames(r->Left_expr(), out, d + 1);
      collectRefNames(r->Right_expr(), out, d + 1);
      break;
    }
    case uhdmoperation: {
      const operation* op = (const operation*)o;
      if (op->Operands()) for (auto* a : *op->Operands()) collectRefNames(a, out, d + 1);
      break;
    }
    case uhdmref_obj: case uhdmparameter: case uhdmtype_parameter:
      out.insert(std::string(o->VpiName()));
      break;
    case uhdmconstant:
      break;
    default: break;
  }
}
static void tsRefNames(const typespec* t, std::set<std::string>& out) {
  if (!t) return;
  const VectorOfrange* rs = nullptr;
  switch (t->UhdmType()) {
    case uhdmlogic_typespec: rs = ((const logic_typespec*)t)->Ranges(); break;
    case uhdmbit_typespec: rs = ((const bit_typespec*)t)->Ranges(); break;
    case uhdmarray_typespec: rs = ((const array_typespec*)t)->Ranges(); break;
    case uhdmpacked_array_typespec: rs = ((const packed_array_typespec*)t)->Ranges(); break;
    default: break;
  }
  if (rs) for (auto* r : *rs) collectRefNames(r, out, 0);
}

struct Home { std::string cls; std::string inst; std::string view; };
static Home homeOf(const BaseClass* o) {
  Home h{"OTHER", "-", "ELAB"};
  const BaseClass* p = o ? o->VpiParent() : nullptr;
  int guard = 0;
  while (p && guard++ < 64) {
    UHDM_OBJECT_TYPE t = p->UhdmType();
    if (t == uhdmmodule_inst) {
      const module_inst* m = (const module_inst*)p;
      h.inst = std::string(m->VpiFullName());
      h.cls = "MODULE";
      if (!m->VpiDefName().empty() && m->VpiFullName() == m->VpiDefName())
        h.view = "DEF";
      return h;
    }
    if (t == uhdmgen_scope || t == uhdmgen_scope_array) { h.cls = "GENSCOPE"; }
    else if (t == uhdmpackage) { h.cls = "PACKAGE"; h.inst = std::string(p->VpiName()); h.view = "DEF"; return h; }
    else if (t == uhdminterface_inst) { h.cls = "IFACE"; h.inst = std::string(((const interface_inst*)p)->VpiFullName()); return h; }
    else if (t == uhdmclass_defn) { h.cls = "CLASS"; h.inst = std::string(p->VpiName()); h.view = "DEF"; return h; }
    else if (t == uhdmprogram) { h.cls = "PROGRAM"; h.inst = std::string(p->VpiName()); return h; }
    p = p->VpiParent();
  }
  return h;
}

static bool isUnaryOp(int op) {
  switch (op) {
    case vpiMinusOp: case vpiPlusOp: case vpiNotOp: case vpiBitNegOp:
    case vpiUnaryAndOp: case vpiUnaryNandOp: case vpiUnaryOrOp:
    case vpiUnaryNorOp: case vpiUnaryXorOp: case vpiUnaryXNorOp:
      return true;
    default: return false;
  }
}

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: pacen85 <db.uhdm> [--inst] [--only-unary]\n"); return 2; }
  bool wantInst = false, onlyUnary = false;
  for (int i = 2; i < argc; i++) {
    if (!strcmp(argv[i], "--inst")) wantInst = true;
    else if (!strcmp(argv[i], "--only-unary")) onlyUnary = true;
  }
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "RESTORE_FAILED %s\n", argv[1]); return 3; }
  auto all = s.AllObjects();

  std::vector<std::string> rows;
  long nPa = 0;
  for (auto& pr : all) {
    const BaseClass* bo = pr.first;
    if (!bo || bo->UhdmType() != uhdmparam_assign) continue;
    nPa++;
    const param_assign* pa = (const param_assign*)bo;
    const any* rhs = pa->Rhs();
    const any* lhs = pa->Lhs();

    std::string rk = kindName(rhs);
    std::string rop = "-", rn = "-", rsz = "-", rval = "-", rct = "-", rdec = "-";
    std::string nopd = "-", o0k = "-", o0op = "-", o0sz = "-", o0val = "-", o0ct = "-";
    int opType = 0;
    if (rhs) {
      rn = esc(rhs->VpiName());
      if (rhs->UhdmType() == uhdmoperation) {
        const operation* op = (const operation*)rhs;
        opType = op->VpiOpType();
        rop = std::to_string(opType);
        auto* ods = op->Operands();
        nopd = std::to_string(ods ? ods->size() : 0);
        if (ods && !ods->empty()) {
          const any* o0 = (*ods)[0];
          o0k = kindName(o0);
          if (o0->UhdmType() == uhdmoperation) o0op = std::to_string(((const operation*)o0)->VpiOpType());
          if (o0->UhdmType() == uhdmconstant) {
            const constant* c = (const constant*)o0;
            o0sz = std::to_string(c->VpiSize());
            o0val = esc(c->VpiValue());
            o0ct = std::to_string(c->VpiConstType());
          }
          if (o0->UhdmType() == uhdmref_obj) o0val = esc(o0->VpiName());
        }
      } else if (rhs->UhdmType() == uhdmconstant) {
        const constant* c = (const constant*)rhs;
        rsz = std::to_string(c->VpiSize());
        rval = esc(c->VpiValue());
        rct = std::to_string(c->VpiConstType());
        rdec = esc(c->VpiDecompile());
      }
    }
    if (onlyUnary && !(rhs && rhs->UhdmType() == uhdmoperation && isUnaryOp(opType)))
      continue;

    const typespec* rts = tsOfExpr(rhs);
    std::string rtsk = rts ? kindName(rts) : "-";
    std::string rtssg = "-";
    if (rts) {
      switch (rts->UhdmType()) {
        case uhdmint_typespec: rtssg = std::to_string((int)((const int_typespec*)rts)->VpiSigned()); break;
        case uhdmlogic_typespec: rtssg = std::to_string((int)((const logic_typespec*)rts)->VpiSigned()); break;
        case uhdmbit_typespec: rtssg = std::to_string((int)((const bit_typespec*)rts)->VpiSigned()); break;
        case uhdminteger_typespec: rtssg = std::to_string((int)((const integer_typespec*)rts)->VpiSigned()); break;
        default: rtssg = "0"; break;
      }
    }
    std::string rtsrg = rts ? std::to_string(rangeCount(rts)) : "-";

    const typespec* lts = nullptr;
    std::string llp = "-";
    std::string pname = "-";
    if (lhs) {
      pname = esc(lhs->VpiName());
      if (lhs->UhdmType() == uhdmparameter) {
        const parameter* p = (const parameter*)lhs;
        lts = actualTs(p->Typespec());
        llp = std::to_string((int)p->VpiLocalParam());
      } else if (lhs->UhdmType() == uhdmtype_parameter) {
        lts = actualTs(((const type_parameter*)lhs)->Typespec());
      }
    }
    std::set<std::string> refs;
    tsRefNames(lts, refs);
    std::string refstr;
    for (auto& r : refs) { if (!refstr.empty()) refstr += ","; refstr += r; }
    if (refstr.empty()) refstr = "-";

    Home h = homeOf(pa);
    char buf[2048];
    snprintf(buf, sizeof buf,
             "SPAN=%s VIEW=%s HOME=%s PNAME=%s%s%s | OV=%d CBN=%d RK=%s ROP=%s RN=%s "
             "RSZ=%s RVAL=%s RCT=%s RDEC=%s RTS=%s RTSSG=%s RTSRG=%s NOPD=%s "
             "O0K=%s O0OP=%s O0SZ=%s O0VAL=%s O0CT=%s LTS=%s LTSRG=%d LTSREF=%s LLP=%s",
             spanOf(pa).c_str(), h.view.c_str(), h.cls.c_str(), pname.c_str(),
             wantInst ? " INST=" : "", wantInst ? esc(h.inst).c_str() : "",
             (int)pa->VpiOverriden(), (int)pa->VpiConnByName(),
             rk.c_str(), rop.c_str(), rn.c_str(), rsz.c_str(), rval.c_str(),
             rct.c_str(), rdec.c_str(), rtsk.c_str(), rtssg.c_str(), rtsrg.c_str(),
             nopd.c_str(), o0k.c_str(), o0op.c_str(), o0sz.c_str(), o0val.c_str(),
             o0ct.c_str(), lts ? kindName(lts).c_str() : "-", rangeCount(lts),
             refstr.c_str(), llp.c_str());
    rows.push_back(buf);
  }
  std::sort(rows.begin(), rows.end());
  for (auto& r : rows) printf("%s\n", r.c_str());
  fprintf(stderr, "PARAM_ASSIGNS=%ld ROWS=%zu\n", nPa, rows.size());
  return 0;
}
