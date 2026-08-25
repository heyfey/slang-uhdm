// r10earl93 — MEASUREMENT-ONLY.  THE SIZE-CAST / PARAM_ASSIGN / WIDE-CONSTANT
// CENSUS.  The official ~/git-repos/UHDM/build/bin/uhdm-cmp remains the sole
// acceptance judge.
//
// Three families over a whole database:
//
//   CS rows — every `operation` whose VpiOpType is vpiCastOp: WHERE it lives,
//             WHAT its target typespec is, and whether its parent still
//             REACHES it (LIVE).  A cast golden folded away is LIVE=0/absent
//             on golden and LIVE=1 for us.
//   PA rows — every `param_assign`: WHAT OBJECT its Rhs is, in the fields the
//             generated Compares read (constant: VpiSize/VpiConstType/
//             VpiValue/VpiDecompile; operation: VpiOpType + operand kinds).
//             THE HEAD IS A PA-ROW PAYLOAD FLIP.
//   CV rows — every `constant` whose VpiSize >= 32: the value population this
//             law can possibly touch (>= 64) plus a 32..63 CONTROL BAND that
//             must not move.
//
// KEY (never scored) ends at the literal `||`.  DIAG fields (after the literal
// `DIAG`) are stripped by score93.py and never scored.
//
// usage: ct93cen <db.uhdm> [--inst] [--cs|--pa|--cv ...]
// build: g++ -O2 -std=c++17 ct93cen.cpp -I ~/.local/include \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct93cen
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
  if (!o) return "-";
  char b[64];
  snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(), o->VpiColumnNo(),
           o->VpiEndLineNo(), o->VpiEndColumnNo());
  return b;
}
static int opTypeOf(const BaseClass* o) {
  if (o && o->UhdmType() == uhdmoperation) return ((const operation*)o)->VpiOpType();
  return -1;
}
static std::string opndK(const BaseClass* o) {
  if (!o || o->UhdmType() != uhdmoperation) return "-";
  const operation* op = (const operation*)o;
  if (!op->Operands()) return "-";
  std::string r;
  for (auto* e : *op->Operands()) {
    if (!r.empty()) r += "/";
    r += kindName(e);
    int t = opTypeOf(e);
    if (t >= 0) { r += ":"; r += std::to_string(t); }
    if (e && e->UhdmType() == uhdmconstant) {
      r += ":"; r += std::to_string(((const constant*)e)->VpiConstType());
    }
  }
  return r.empty() ? "-" : r;
}
static std::string decOf(const BaseClass* o) {
  if (!o) return "-";
  if (const expr* e = any_cast<const expr*>(o)) return esc(e->VpiDecompile());
  return "-";
}
static std::string valOf(const BaseClass* o) {
  if (!o) return "-";
  if (const expr* e = any_cast<const expr*>(o)) return esc(e->VpiValue());
  return "-";
}
static int szOf(const BaseClass* o) {
  if (!o) return 0;
  if (const expr* e = any_cast<const expr*>(o)) return e->VpiSize();
  return 0;
}
static std::string nameOf(const BaseClass* o) {
  if (!o) return "-";
  return esc(o->VpiName());
}
// The ACTUAL typespec behind a ref_typespec (uhdm-cmp reads Actual_typespec).
static const typespec* actual(const ref_typespec* rt) {
  return rt ? rt->Actual_typespec() : nullptr;
}

struct Ctx {
  std::string cls = "OTHER";
  std::string view = "-";
  std::string mod = "-";
  std::string inst = "-";
};

static Ctx ctxOf(const BaseClass* o) {
  Ctx c;
  const BaseClass* prev = o;
  const BaseClass* p = o->VpiParent();
  bool fixed = false;
  for (int i = 0; i < 128 && p; i++) {
    UHDM_OBJECT_TYPE t = p->UhdmType();
    if (t == uhdmmodule_inst && c.inst == "-") {
      const module_inst* mi = (const module_inst*)p;
      c.inst = esc(mi->VpiFullName());
      c.mod = esc(mi->VpiDefName());
      c.view = (mi->VpiFullName() == mi->VpiDefName()) ? "DEF" : "ELAB";
    }
    if (t == uhdmpackage && c.inst == "-") {
      c.inst = esc(p->VpiName()); c.mod = esc(p->VpiName());
      c.view = "PKG";
    }
    if (!fixed) {
      switch (t) {
        case uhdmport: {
          const port* pt = (const port*)p;
          c.cls = (pt->High_conn() == prev) ? "PORTHC"
                : (pt->Low_conn() == prev)  ? "PORTLC" : "PORTHC?";
          fixed = true; break;
        }
        case uhdmcont_assign: c.cls = "CONTASSIGN"; fixed = true; break;
        case uhdmparam_assign: c.cls = "PARAMINIT"; fixed = true; break;
        case uhdmtask: case uhdmfunction: c.cls = "TASKFUNC"; fixed = true; break;
        case uhdmalways: case uhdminitial: case uhdmfinal_stmt:
          c.cls = "PROCESS"; fixed = true; break;
        case uhdmassignment: case uhdmassign_stmt:
          c.cls = "PROCASSIGN"; fixed = true; break;
        case uhdmtypespec_member: c.cls = "TYPESPEC"; fixed = true; break;
        case uhdmgen_scope: case uhdmgen_scope_array:
          c.cls = "GENSCOPE"; fixed = true; break;
        default: break;
      }
      if (!fixed) {
        std::string kn = std::string(UHDM::UhdmName(t));
        if (kn.find("_typespec") != std::string::npos) { c.cls = "TYPESPEC"; fixed = true; }
      }
    }
    prev = p;
    p = p->VpiParent();
  }
  return c;
}

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: ct93cen <db.uhdm> [--inst] [--cs] [--pa] [--cv]\n"); return 2; }
  bool wantInst = false, wCs = false, wPa = false, wCv = false;
  for (int i = 2; i < argc; i++) {
    if (!strcmp(argv[i], "--inst")) wantInst = true;
    else if (!strcmp(argv[i], "--cs")) wCs = true;
    else if (!strcmp(argv[i], "--pa")) wPa = true;
    else if (!strcmp(argv[i], "--cv")) wCv = true;
  }
  if (!wCs && !wPa && !wCv) { wCs = wPa = wCv = true; }
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "RESTORE_FAILED %s\n", argv[1]); return 3; }
  auto all = s.AllObjects();
  long nCs = 0, nPa = 0, nCv = 0;
  std::vector<std::string> rows;
  char line[32768];
  for (auto& pr : all) {
    const BaseClass* bo = pr.first;
    if (!bo) continue;
    UHDM_OBJECT_TYPE t = bo->UhdmType();

    if (wCs && t == uhdmoperation && ((const operation*)bo)->VpiOpType() == vpiCastOp) {
      nCs++;
      const operation* op = (const operation*)bo;
      Ctx c = ctxOf(bo);
      const typespec* ts = actual(op->Typespec());
      std::string ttk = ts ? std::string(UHDM::UhdmName(ts->UhdmType())) : "-";
      // The cast WIDTH as the target typespec carries it.  An
      // integer_typespec's own VpiValue is Surelog's `cast_to`; anything
      // else reports its VpiSize when it has one.
      std::string tw = "-";
      if (ts && ts->UhdmType() == uhdminteger_typespec)
        tw = esc(((const integer_typespec*)ts)->VpiValue());
      const BaseClass* par = bo->VpiParent();
      int live = 1;
      if (par) {
        if (par->UhdmType() == uhdmparam_assign)
          live = (((const param_assign*)par)->Rhs() == (const any*)bo) ? 1 : 0;
        else if (par->UhdmType() == uhdmcont_assign)
          live = (((const cont_assign*)par)->Rhs() == (const expr*)bo) ? 1 : 0;
        else if (par->UhdmType() == uhdmoperation) {
          live = 0;
          const operation* po = (const operation*)par;
          if (po->Operands())
            for (auto* e : *po->Operands()) if (e == (const any*)bo) live = 1;
        }
      }
      snprintf(line, sizeof line,
               "CS\tSPAN=%s\tCTX=%s\tVIEW=%s\tMOD=%s\tINST=%s\tPKIND=%s\t||"
               "\tTTK=%s\tTW=%s\tLIVE=%d\tOPK=%s\tSZ=%d",
               spanOf(bo).c_str(), c.cls.c_str(), c.view.c_str(), c.mod.c_str(),
               wantInst ? c.inst.c_str() : "-", kindName(par).c_str(),
               ttk.c_str(), tw.c_str(), live, opndK(bo).c_str(), szOf(bo));
      rows.push_back(line);
    }

    if (wPa && t == uhdmparam_assign) {
      nPa++;
      const param_assign* pa = (const param_assign*)bo;
      Ctx c = ctxOf(bo);
      const any* l = pa->Lhs();
      const any* r = pa->Rhs();
      int rct = (r && r->UhdmType() == uhdmconstant)
                    ? ((const constant*)r)->VpiConstType() : -1;
      snprintf(line, sizeof line,
               "PA\tSPAN=%s\tLNAME=%s\tVIEW=%s\tMOD=%s\tINST=%s\t||"
               "\tRK=%s\tROP=%d\tRCT=%d\tRSZ=%d\tRVAL=%s\tRDEC=%s\tROPK=%s"
               "\tDIAG\tRSPAN=%s",
               spanOf(bo).c_str(), nameOf(l).c_str(), c.view.c_str(),
               c.mod.c_str(), wantInst ? c.inst.c_str() : "-",
               kindName(r).c_str(), opTypeOf(r), rct, szOf(r),
               valOf(r).c_str(), decOf(r).c_str(), opndK(r).c_str(),
               spanOf(r).c_str());
      rows.push_back(line);
    }

    if (wCv && t == uhdmconstant && szOf(bo) >= 32) {
      nCv++;
      const constant* cc = (const constant*)bo;
      Ctx c = ctxOf(bo);
      const BaseClass* par = bo->VpiParent();
      int sz = szOf(bo);
      const char* band = (sz >= 64) ? "W64UP" : "W32_63";
      snprintf(line, sizeof line,
               "CV\tSPAN=%s\tCTX=%s\tVIEW=%s\tMOD=%s\tINST=%s\tPKIND=%s\tBAND=%s\t||"
               "\tSZ=%d\tVAL=%s\tCT=%d\tDEC=%s",
               spanOf(bo).c_str(), c.cls.c_str(), c.view.c_str(), c.mod.c_str(),
               wantInst ? c.inst.c_str() : "-", kindName(par).c_str(), band,
               sz, valOf(bo).c_str(), cc->VpiConstType(), decOf(bo).c_str());
      rows.push_back(line);
    }
  }
  std::sort(rows.begin(), rows.end());
  for (auto& l : rows) printf("%s\n", l.c_str());
  fprintf(stderr, "-- casts=%ld paramAssigns=%ld wideConsts=%ld\n", nCs, nPa, nCv);
  return 0;
}
