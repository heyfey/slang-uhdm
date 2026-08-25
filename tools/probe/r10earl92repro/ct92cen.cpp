// r10earl92 — MEASUREMENT-ONLY.  THE CONT_ASSIGN-RHS + vpiConditionOp CENSUS.
//
// The official ~/git-repos/UHDM/build/bin/uhdm-cmp remains the sole acceptance
// judge.  This instrument answers two questions over a whole database:
//
//   CA rows — for EVERY `cont_assign`, WHAT OBJECT is its `Rhs`, in the fields
//             `cont_assign::Compare` and the Rhs's own generated Compare
//             actually read (operation: VpiOpType + Operands; expr:
//             VpiDecompile / VpiSize / Typespec; constant: VpiConstType).
//             The head this pass takes is exactly a CA-row payload flip:
//             golden's Rhs is the SELECTED ARM, ours is the whole ternary.
//
//   CO rows — for EVERY `operation` whose VpiOpType is vpiConditionOp, WHERE
//             it lives.  A ternary that golden folded away is a row that
//             exists ONLY on our side; a ternary golden kept and we folded is
//             an AWAY-GOLDEN cell.  This is the denominator the law's fences
//             have to survive, and it is measured across every context, not
//             only the one the law intends to move.
//
// KEY (never scored):
//   CA: LSPAN  the Lhs's line:col-line:col   (the Rhs span is NOT a key and
//              NOT a payload — earl60's attrv60 lesson: a span-carrying
//              payload hid an Instance flip inside STILL-WRONG)
//       LK     the Lhs's UHDM kind          LNAME  its VpiName
//       VIEW   DEF when the enclosing module_inst's VpiFullName equals its
//              VpiDefName (Surelog's definition listing), ELAB otherwise
//       MOD    the enclosing module_inst's VpiDefName
//       INST   (--inst only) its VpiFullName
//   CO: SPAN PKIND POP OPIDX CTX LHSK VIEW MOD INST
//              (CTX = the same parent-walk context classes r10earl91's
//               ct91cen used: PORTHC/PORTLC/CONTASSIGN/PARAMINIT/TASKFUNC/
//               PROCESS/PROCASSIGN/TYPESPEC/OTHER)
// PAYLOAD (scored — COMPARE-VISIBLE fields only):
//   CA: RK ROP RCT RSZ RDEC RNOPS ROPK
// DIAG (after a literal `DIAG` field — NEVER scored, stripped by score92.py):
//   RSPAN  the Rhs object's own span.  It is the only way an ARM GRID can say
//   WHICH arm was installed (`EN ? k[5]^k[1] : k[2]^k[3]` gives the same
//   compare-visible fingerprint either way), and it is kept OUT of the scored
//   payload because a span-carrying payload hid an Instance flip for earl60.
//   CO: LIVE NOPS OPK DEC SZ
//
// usage: ct92cen <db.uhdm> [--inst] [--ca-only|--co-only]
// build: g++ -O2 -std=c++17 ct92cen.cpp -I ~/.local/include \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct92cen
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
// one-level operand fingerprint: kind[:optype] joined by '/'
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
      r += ":";
      r += std::to_string(((const constant*)e)->VpiConstType());
    }
  }
  return r.empty() ? "-" : r;
}
static std::string decOf(const BaseClass* o) {
  if (!o) return "-";
  if (const expr* e = any_cast<const expr*>(o)) return esc(e->VpiDecompile());
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

struct Ctx {
  std::string cls = "OTHER";
  std::string lhsk = "-";
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
    if (!fixed) {
      switch (t) {
        case uhdmport: {
          const port* pt = (const port*)p;
          c.cls = (pt->High_conn() == prev) ? "PORTHC"
                : (pt->Low_conn() == prev)  ? "PORTLC" : "PORTHC?";
          fixed = true; break;
        }
        case uhdmcont_assign: {
          c.cls = "CONTASSIGN";
          c.lhsk = kindName(((const cont_assign*)p)->Lhs());
          fixed = true; break;
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
    p = p->VpiParent();
  }
  return c;
}

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: ct92cen <db.uhdm> [--inst] [--ca-only|--co-only]\n"); return 2; }
  bool wantInst = false, caOnly = false, coOnly = false;
  for (int i = 2; i < argc; i++) {
    if (!strcmp(argv[i], "--inst")) wantInst = true;
    else if (!strcmp(argv[i], "--ca-only")) caOnly = true;
    else if (!strcmp(argv[i], "--co-only")) coOnly = true;
  }
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "RESTORE_FAILED %s\n", argv[1]); return 3; }
  auto all = s.AllObjects();
  long nCa = 0, nCo = 0;
  std::vector<std::string> rows;
  char line[32768];
  for (auto& pr : all) {
    const BaseClass* bo = pr.first;
    if (!bo) continue;
    UHDM_OBJECT_TYPE t = bo->UhdmType();
    if (t == uhdmcont_assign && !coOnly) {
      nCa++;
      const cont_assign* ca = (const cont_assign*)bo;
      Ctx c = ctxOf(bo);
      const expr* l = ca->Lhs();
      const expr* r = ca->Rhs();
      int rct = (r && r->UhdmType() == uhdmconstant)
                    ? ((const constant*)r)->VpiConstType() : -1;
      int rnops = 0;
      if (r && r->UhdmType() == uhdmoperation && ((const operation*)r)->Operands())
        rnops = (int)((const operation*)r)->Operands()->size();
      snprintf(line, sizeof line,
               "CA\tLSPAN=%s\tLK=%s\tLNAME=%s\tVIEW=%s\tMOD=%s\tINST=%s\t||"
               "\tRK=%s\tROP=%d\tRCT=%d\tRSZ=%d\tRDEC=%s\tRNOPS=%d\tROPK=%s"
               "\tDIAG\tRSPAN=%s",
               spanOf(l).c_str(), kindName(l).c_str(), nameOf(l).c_str(),
               c.view.c_str(), c.mod.c_str(),
               wantInst ? c.inst.c_str() : "-",
               kindName(r).c_str(), opTypeOf(r), rct, szOf(r),
               decOf(r).c_str(), rnops, opndK(r).c_str(),
               spanOf(r).c_str());
      rows.push_back(line);
    }
    if (t == uhdmoperation && !caOnly &&
        ((const operation*)bo)->VpiOpType() == vpiConditionOp) {
      nCo++;
      Ctx c = ctxOf(bo);
      const BaseClass* par = bo->VpiParent();
      std::string pop = "-", opidx = "-";
      if (par && par->UhdmType() == uhdmoperation) {
        const operation* po = (const operation*)par;
        pop = std::to_string(po->VpiOpType());
        if (po->Operands())
          for (size_t k = 0; k < po->Operands()->size(); k++)
            if ((*po->Operands())[k] == bo) { opidx = std::to_string(k); break; }
      }
      const operation* co = (const operation*)bo;
      int nops = co->Operands() ? (int)co->Operands()->size() : 0;
      // LIVE — is this conditionOp still REACHED by its parent?  Surelog's
      // writeCont_assign REPLACES `cont_assign::Rhs` and leaves the old
      // ternary object in the serializer with its VpiParent intact, so a
      // pure object census counts it on BOTH sides and sees nothing.  The
      // judge only walks REACHABLE objects; LIVE is that reachability, and
      // it is the field that flips when a fold lands.
      int live = 1;
      if (par) {
        if (par->UhdmType() == uhdmcont_assign)
          live = (((const cont_assign*)par)->Rhs() == (const expr*)bo) ? 1 : 0;
        else if (par->UhdmType() == uhdmoperation)
          live = (opidx == "-") ? 0 : 1;
      }
      snprintf(line, sizeof line,
               "CO\tSPAN=%s\tPKIND=%s\tPOP=%s\tOPIDX=%s\tCTX=%s\tLHSK=%s"
               "\tVIEW=%s\tMOD=%s\tINST=%s\t||\tLIVE=%d\tNOPS=%d\tOPK=%s\tDEC=%s\tSZ=%d",
               spanOf(bo).c_str(), kindName(par).c_str(), pop.c_str(),
               opidx.c_str(), c.cls.c_str(), c.lhsk.c_str(), c.view.c_str(),
               c.mod.c_str(), wantInst ? c.inst.c_str() : "-",
               live, nops, opndK(bo).c_str(), decOf(bo).c_str(), szOf(bo));
      rows.push_back(line);
    }
  }
  std::sort(rows.begin(), rows.end());
  for (auto& l : rows) printf("%s\n", l.c_str());
  fprintf(stderr, "-- cont_assigns=%ld conditionOps=%ld\n", nCa, nCo);
  return 0;
}
