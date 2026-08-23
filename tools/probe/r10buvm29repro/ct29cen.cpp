// r10buvm29 — MEASUREMENT ONLY.  Census of CAST and STREAM operations.
//
// § castOverStreamKeepsCast29 is a NODE-SHAPE law: golden wraps a WRITTEN
// `T'({ << bit {x} })` in a cast `operation` (vpiOpType 67) carrying the
// target typespec, and hangs the stream `operation` (71/72) under it as the
// sole operand; a COMPILER-INSERTED conversion of a bare stream in an
// assignment context has no cast node at all.  So the census must show, per
// operation node, whether a cast wraps a stream and whether a stream is
// wrapped.
//
// One row per `operation` whose VpiOpType is vpiCastOp (67), vpiStreamLROp
// (71) or vpiStreamRLOp (72):
//
//   SPAN \t OP \t TS \t NOPND \t OPNDS \t PARENT \t OWNER
//
//   SPAN   line:col-endline:endcol     (file is a READING column only -- our
//                                       objects carry an EMPTY VpiFile, so a
//                                       file-keyed join reports 100% bogus
//                                       disagreement: uvm96's trap)
//   OP     CAST | STREAM_LR | STREAM_RL
//   TS     the Typespec's ref_typespec -> Actual kind, or "-" when null.
//          This is the FIELD the judge reads (expr::Compare: VpiDecompile,
//          VpiSize, Typespec).
//   NOPND  operand count
//   OPNDS  comma-joined operand kinds; an `operation` operand prints
//          op<N>; a `constant` prints const<value>
//   PARENT the immediate vpiParent's kind (+ op<N> when an operation)
//   OWNER  nearest ancestor with a VpiName, as <kind>:<name>
//
// usage: ct29cen <db.uhdm>
// build: g++ -O2 -std=c++17 ct29cen.cpp -I ~/.local/include \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct29cen
#include <uhdm/uhdm.h>
#include <uhdm/UhdmListener.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
#include <set>
#include <vector>
using namespace UHDM;

static std::string kindName(const BaseClass* o) {
  if (!o) return "-";
  return std::string(UHDM::UhdmName(o->UhdmType()));
}

static std::string nodeDesc(const BaseClass* o) {
  if (!o) return "-";
  std::string k = kindName(o);
  if (o->UhdmType() == uhdmoperation) {
    const operation* op = (const operation*)o;
    k += "<" + std::to_string(op->VpiOpType()) + ">";
  } else if (o->UhdmType() == uhdmconstant) {
    const constant* c = (const constant*)o;
    k += "<" + std::string(c->VpiValue()) + ">";
  } else if (o->UhdmType() == uhdmref_obj) {
    k += "<" + std::string(((const ref_obj*)o)->VpiName()) + ">";
  }
  return k;
}

// The typespec the JUDGE reads: expr::Typespec() is a ref_typespec whose
// Actual_typespec is the real target.  Print BOTH so a pass that mints the
// ref but forgets the actual is visible.
static std::string tsDesc(const expr* e) {
  const ref_typespec* rt = e->Typespec();
  if (!rt) return "-";
  const typespec* a = rt->Actual_typespec();
  std::string s = "ref/";
  s += a ? std::string(UHDM::UhdmName(a->UhdmType())) : std::string("NULLACT");
  return s;
}

static std::string ownerOf(const BaseClass* o) {
  const BaseClass* p = o ? o->VpiParent() : nullptr;
  int guard = 0;
  while (p && guard++ < 200) {
    std::string n;
    if (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask ||
        p->UhdmType() == uhdmclass_defn || p->UhdmType() == uhdmpackage ||
        p->UhdmType() == uhdmmodule_inst || p->UhdmType() == uhdmbegin ||
        p->UhdmType() == uhdmnamed_begin) {
      // any_cast IS-A: dispatch on UhdmType, then read the name generically
      std::string nm;
      if (p->UhdmType() == uhdmfunction) nm = ((const function*)p)->VpiName();
      else if (p->UhdmType() == uhdmtask) nm = ((const task*)p)->VpiName();
      else if (p->UhdmType() == uhdmclass_defn) nm = ((const class_defn*)p)->VpiName();
      else if (p->UhdmType() == uhdmpackage) nm = ((const package*)p)->VpiName();
      else if (p->UhdmType() == uhdmmodule_inst) nm = ((const module_inst*)p)->VpiName();
      if (!nm.empty()) return kindName(p) + ":" + nm;
    }
    p = p->VpiParent();
  }
  return "-";
}

static std::set<const BaseClass*> g_seen;

static void emit(const operation* op) {
  if (!g_seen.insert(op).second) return;  // one row per OBJECT, not per path
  int t = op->VpiOpType();
  const char* tag = t == vpiCastOp ? "CAST"
                  : t == vpiStreamLROp ? "STREAM_LR"
                  : t == vpiStreamRLOp ? "STREAM_RL" : nullptr;
  if (!tag) return;
  std::string opnds;
  int n = 0;
  if (op->Operands()) {
    for (auto* o : *op->Operands()) {
      if (n) opnds += ",";
      opnds += nodeDesc(o);
      n++;
    }
  }
  if (!n) opnds = "-";
  printf("%d:%d-%d:%d\t%s\t%s\t%d\t%s\t%s\t%s\n",
         op->VpiLineNo(), op->VpiColumnNo(), op->VpiEndLineNo(),
         op->VpiEndColumnNo(), tag, tsDesc(op).c_str(), n, opnds.c_str(),
         nodeDesc(op->VpiParent()).c_str(), ownerOf(op).c_str());
}

// REACHABILITY.  The serializer ARENA holds objects the judge never sees --
// the weakly-referenced DEF-phase clones (RESUME.md §9).  Counting those made
// every elaborated-view cell read as a duplicate.  Walk from the DESIGN roots
// with UhdmListener instead, so the census sees exactly what uhdm-cmp can
// reach.  UHDM `any_cast` IS-A: dispatch on UhdmType().
class Cen29 final : public UhdmListener {
 public:
  void enterOperation(const operation* const o) override { emit(o); }
};

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: ct29cen <db.uhdm>\n"); return 2; }
  Serializer s;
  std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  Cen29 cen;
  for (vpiHandle h : restored) {
    const BaseClass* d = (const BaseClass*)((const uhdm_handle*)h)->object;
    cen.listenAny((const any*)d);
  }
  return 0;
}
