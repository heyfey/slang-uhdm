// r10earl87 — MEASUREMENT-ONLY.  THE param_assign CENSUS, WITH THE WHOLE Rhs
// TREE IN THE PAYLOAD.
//
// The official ~/git-repos/UHDM/build/bin/uhdm-cmp remains the sole acceptance
// judge.  Extends r10earl85's pacen85 (same KEY, same scalar payload) with the
// field that pass could not see: `TREE=`, a PREORDER linearization of the whole
// Rhs expression, one node per `depth,kind,opType,size,value,constType,
// decompile,typespecKind,typespecSigned` group.  earl85's payload stopped at
// the FIRST operand of the top operation, so a fold state two levels down --
// exactly where this head lives -- was invisible to it.
//
// TRAPS OBSERVED:
//   * NO SPAN IN THE SCORED PAYLOAD (earl60/earl69: a span-carrying payload hid
//     a real Instance flip inside STILL-WRONG).  `--spans` emits a SEPARATE
//     `TSPAN=` column for DIAGNOSIS ONLY; `score87.py` scores the row WITHOUT
//     it, and `cen87.sh` never passes it on the corpus run.
//   * The TREE carries only fields a generated `Compare` reads
//     (VpiSize/VpiValue*/VpiConstType/VpiDecompile/Typespec kind+signedness;
//     *VpiValue is NOT read by constant::Compare but IS the string the size and
//     const type are stamped from, and it is kept because a value flip with an
//     unchanged size/ct is a real regression the judge would see one level up).
//   * Rows are emitted for EVERY param_assign, unary or not (earl66: a census
//     keyed on the shape you intend to CHANGE is blind to the rows you would
//     change by ACCIDENT).
//
// usage: pacen87 <db.uhdm> [--inst] [--only-unary] [--spans]
// build: g++ -O2 -std=c++17 pacen87.cpp -I ~/.local/include \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o pacen87
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>
#include <set>
#include <map>
#include <algorithm>
#include <vector>
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


// THE PREORDER TREE.  One group per node:
//   d<depth>:<kind>:<opType>:<size>:<value>:<ct>:<dec>:<tsKind>:<tsSigned>
// Depth is a POSITION marker inside one row, not a census key (a fold changes
// the depth of everything beneath it, so it must never key a JOIN -- the row is
// the unit that joins, on SPAN+VIEW+HOME+PNAME+INST).
static void lin87(const BaseClass* o, int d, std::string& out, bool spans) {
  if (!o) return;
  if (d > 24) { out += ";d" + std::to_string(d) + ":DEPTHCAP"; return; }
  std::string kind = kindName(o);
  std::string op = "-", sz = "-", val = "-", ct = "-", dec = "-";
  if (o->UhdmType() == uhdmoperation) op = std::to_string(((const operation*)o)->VpiOpType());
  if (o->UhdmType() == uhdmconstant) {
    const constant* c = (const constant*)o;
    sz = std::to_string(c->VpiSize());
    val = esc(c->VpiValue());
    ct = std::to_string(c->VpiConstType());
    dec = esc(c->VpiDecompile());
  }
  std::string nm = esc(o->VpiName());
  const typespec* t = tsOfExpr(o);
  std::string tk = t ? kindName(t) : "-";
  std::string tsg = "-";
  if (t) {
    switch (t->UhdmType()) {
      case uhdmint_typespec: tsg = std::to_string((int)((const int_typespec*)t)->VpiSigned()); break;
      case uhdmlogic_typespec: tsg = std::to_string((int)((const logic_typespec*)t)->VpiSigned()); break;
      case uhdmbit_typespec: tsg = std::to_string((int)((const bit_typespec*)t)->VpiSigned()); break;
      case uhdminteger_typespec: tsg = std::to_string((int)((const integer_typespec*)t)->VpiSigned()); break;
      default: tsg = "0"; break;
    }
  }
  if (!out.empty()) out += ";";
  out += "d" + std::to_string(d) + ":" + kind + ":" + op + ":" + sz + ":" + val +
         ":" + ct + ":" + dec + ":" + nm + ":" + tk + ":" + tsg;
  if (spans) out += ":" + spanOf(o);
  switch (o->UhdmType()) {
    case uhdmoperation: {
      auto* ods = ((const operation*)o)->Operands();
      if (ods) for (auto* a : *ods) lin87(a, d + 1, out, spans);
      break;
    }
    case uhdmsys_func_call: {
      auto* as = ((const sys_func_call*)o)->Tf_call_args();
      if (as) for (auto* a : *as) lin87(a, d + 1, out, spans);
      break;
    }
    case uhdmfunc_call: {
      auto* as = ((const func_call*)o)->Tf_call_args();
      if (as) for (auto* a : *as) lin87(a, d + 1, out, spans);
      break;
    }
    case uhdmbit_select: lin87(((const bit_select*)o)->VpiIndex(), d + 1, out, spans); break;
    default: break;
  }
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
  if (argc < 2) { fprintf(stderr, "usage: pacen87 <db.uhdm> [--inst] [--only-unary] [--spans]\n"); return 2; }
  bool wantInst = false, onlyUnary = false, wantSpans = false;
  for (int i = 2; i < argc; i++) {
    if (!strcmp(argv[i], "--inst")) wantInst = true;
    else if (!strcmp(argv[i], "--only-unary")) onlyUnary = true;
    else if (!strcmp(argv[i], "--spans")) wantSpans = true;
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
    std::string limp = "-";
    std::string pname = "-";
    if (lhs) {
      pname = esc(lhs->VpiName());
      if (lhs->UhdmType() == uhdmparameter) {
        const parameter* p = (const parameter*)lhs;
        lts = actualTs(p->Typespec());
        llp = std::to_string((int)p->VpiLocalParam());
        limp = esc(p->VpiImported());
      } else if (lhs->UhdmType() == uhdmtype_parameter) {
        lts = actualTs(((const type_parameter*)lhs)->Typespec());
      }
    }
    std::set<std::string> refs;
    tsRefNames(lts, refs);
    std::string refstr;
    for (auto& r : refs) { if (!refstr.empty()) refstr += ","; refstr += r; }
    if (refstr.empty()) refstr = "-";

    std::string tree;
    lin87(rhs, 0, tree, wantSpans);
    if (tree.empty()) tree = "-";
    Home h = homeOf(pa);
    std::vector<char> buf(65536);
    snprintf(buf.data(), buf.size(),
             "SPAN=%s VIEW=%s HOME=%s PNAME=%s%s%s | OV=%d CBN=%d RK=%s ROP=%s RN=%s "
             "RSZ=%s RVAL=%s RCT=%s RDEC=%s RTS=%s RTSSG=%s RTSRG=%s NOPD=%s "
             "O0K=%s O0OP=%s O0SZ=%s O0VAL=%s O0CT=%s LTS=%s LTSRG=%d LTSREF=%s LLP=%s IMP=%s TREE=%s",
             spanOf(pa).c_str(), h.view.c_str(), h.cls.c_str(), pname.c_str(),
             wantInst ? " INST=" : "", wantInst ? esc(h.inst).c_str() : "",
             (int)pa->VpiOverriden(), (int)pa->VpiConnByName(),
             rk.c_str(), rop.c_str(), rn.c_str(), rsz.c_str(), rval.c_str(),
             rct.c_str(), rdec.c_str(), rtsk.c_str(), rtssg.c_str(), rtsrg.c_str(),
             nopd.c_str(), o0k.c_str(), o0op.c_str(), o0sz.c_str(), o0val.c_str(),
             o0ct.c_str(), lts ? kindName(lts).c_str() : "-", rangeCount(lts),
             refstr.c_str(), llp.c_str(), limp.c_str(), tree.c_str());
    rows.push_back(buf.data());
  }
  std::sort(rows.begin(), rows.end());
  for (auto& r : rows) printf("%s\n", r.c_str());
  fprintf(stderr, "PARAM_ASSIGNS=%ld ROWS=%zu\n", nPa, rows.size());
  return 0;
}
