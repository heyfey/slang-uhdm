// r10earl83 — MEASUREMENT-ONLY.  THE WRITTEN-CAST CENSUS.
//
// The official ~/git-repos/UHDM/build/bin/uhdm-cmp remains the sole acceptance
// judge.  This instrument only says, for every WRITTEN cast site, what object
// each database put there — a KEPT `vpiCastOp` operation, or (golden) a
// REDUCED constant — keyed so the two databases join on the SAME cell.
//
// Two modes, because a REDUCED cast is no longer an operation and therefore
// cannot be found by looking for operations:
//
//   --cast          ONE ROW PER `operation` whose VpiOpType is vpiCastOp (67).
//                   Run on BOTH databases.  Ours' rows give the candidate
//                   SPANS; golden's rows are the KEPT population.
//   --at <spans>    ONE ROW PER OBJECT OF ANY KIND whose SPAN appears in the
//                   newline-separated span list.  Run on the OTHER database
//                   with the first database's spans, this is what answers
//                   "what did the other side put at this cast site".
//
// KEY (never scored):
//   SPAN   line:col-line:col.  VpiFile is EMPTY on our expressions and on
//          golden's, so the file is NOT a key; the span list is per-database
//          and every corpus test here is a single design.
//   CTX    the CONTEXT CLASS, computed from the parent walk (see ctxOf):
//          PORTHC   an actual hanging off a `port`'s High_conn  (the ELAB and
//                   the DEF-listing copies are distinguished by PORTPAR)
//          PORTLC   a port's Low_conn
//          CONTASSIGN / PARAMINIT / TASKFUNC / PROCESS / TYPESPEC / OTHER
//   PORTPAR the kind of the port's own parent when CTX is PORTHC/PORTLC:
//          `module_inst` = the ELABORATED connection, `ref_module` = the DEF
//          listing.  This is the § elabConnEmit21 split, read out of the data.
//   DEPTH  hops from the cast site down to this object (0 for the site itself);
//          only ever printed, never joined on (RESUME §9: a fold changes the
//          depth of everything beneath it).
//   CALLARG 1 when a `tf_call`/`sys_func_call`/`func_call`/`task_call`
//          ancestor sits between the object and its context home — the
//          § connCallArgKeepsEnumRef66v carve-out, measured not assumed.
//   PSBOUND 1 when a `part_select` ancestor sits between (Surelog's
//          compilePartSelectRange hardcodes Reduce::No).
// PAYLOAD (scored):
//   KIND   the UHDM kind
//   OPT    vpiOpType for an operation, else -
//   NOPS   operand count for an operation, else -
//   SZ     VpiSize        VAL  VpiValue        CT  VpiConstType
//   DEC    VpiDecompile
//   TS     the Actual_typespec's kind (`-` = no typespec at all)
//   TSV    that typespec's VpiValue (a size cast's width lives here)
//   TSN    that typespec's VpiName
//   OP0    for an operation, the first operand's KIND/SZ/VAL/CT
//
// TRAPS THIS INSTRUMENT AVOIDS (each paid for elsewhere in this campaign):
//  * `VpiParent` is not a key beyond the CONTEXT CLASS it yields: no generated
//    `Compare` reads it.
//  * NESTING DEPTH is not a key.  The whole subject is an operation golden
//    REMOVES, which shifts the depth of the operand beneath it.
//  * `Serializer::AllObjects` can name objects that are not in the dump tree
//    (uvm97).  ROOT= records where the parent walk ends.
//  * The payload carries NO span-derived field beyond the key itself
//    (earl60/earl69: a span-carrying payload hides a real flip).
//
// usage: ct83cen <db.uhdm> --cast
//        ct83cen <db.uhdm> --at <spanlist>
//        ct83cen <db.uhdm> --spans        (bare span list of cast operations)
// build: g++ -O2 -std=c++17 ct83cen.cpp -I ~/.local/include \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct83cen
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>
#include <set>
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
  const ref_typespec* rt = nullptr;
  if (o->UhdmType() == uhdmoperation) rt = ((const operation*)o)->Typespec();
  else if (o->UhdmType() == uhdmconstant) rt = ((const constant*)o)->Typespec();
  else if (o->UhdmType() == uhdmref_obj) rt = ((const ref_obj*)o)->Typespec();
  return rt ? rt->Actual_typespec() : nullptr;
}

struct Ctx {
  std::string cls = "OTHER";
  std::string portpar = "-";
  std::string root = "-";
  int callarg = 0, psbound = 0;
};

static Ctx ctxOf(const BaseClass* o) {
  Ctx c;
  const BaseClass* prev = o;
  const BaseClass* p = o->VpiParent();
  bool fixed = false;
  const BaseClass* last = o;
  for (int i = 0; i < 128 && p; i++) {
    UHDM_OBJECT_TYPE t = p->UhdmType();
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
                                            : "PORTOTHER";
          // when the actual is nested the immediate child is not the port's
          // own High_conn; recover the slot by identity of the top ancestor
          if (c.cls == "PORTOTHER") c.cls = "PORTHC?";
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
        // any typespec ancestor
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
  if (argc < 3) {
    fprintf(stderr, "usage: ct83cen <db.uhdm> --cast|--spans|--at <spanlist>\n");
    return 2;
  }
  const std::string mode = argv[2];
  std::set<std::string> want;
  if (mode == "--at") {
    if (argc < 4) { fprintf(stderr, "--at needs a spanlist\n"); return 2; }
    FILE* f = fopen(argv[3], "r");
    if (!f) { fprintf(stderr, "NO_SPANLIST %s\n", argv[3]); return 2; }
    char b[512];
    while (fgets(b, sizeof b, f)) {
      std::string s(b);
      while (!s.empty() && (s.back() == '\n' || s.back() == '\r')) s.pop_back();
      if (!s.empty()) want.insert(s);
    }
    fclose(f);
  }
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "RESTORE_FAILED %s\n", argv[1]); return 3; }
  auto all = s.AllObjects();

  long nCast = 0, nRow = 0;
  std::vector<std::string> rows;
  std::vector<std::string> spans;
  for (auto& pr : all) {
    const BaseClass* bo = pr.first;
    if (!bo) continue;
    bool isCast = (bo->UhdmType() == uhdmoperation &&
                   ((const operation*)bo)->VpiOpType() == vpiCastOp);
    if (isCast) nCast++;
    std::string sp = spanOf(bo);
    if (mode == "--cast" || mode == "--spans") {
      if (!isCast) continue;
    } else {
      if (want.find(sp) == want.end()) continue;
      // a typespec/range object at the same span is not a cast SITE candidate
      UHDM_OBJECT_TYPE t = bo->UhdmType();
      if (t != uhdmconstant && t != uhdmoperation && t != uhdmref_obj &&
          t != uhdmsys_func_call && t != uhdmfunc_call && t != uhdmbit_select &&
          t != uhdmpart_select && t != uhdmindexed_part_select &&
          t != uhdmhier_path && t != uhdmoperation)
        continue;
    }
    if (mode == "--spans") { spans.push_back(sp); continue; }
    Ctx c = ctxOf(bo);
    std::string opt = "-", nops = "-", op0 = "-";
    if (bo->UhdmType() == uhdmoperation) {
      const operation* op = (const operation*)bo;
      opt = std::to_string(op->VpiOpType());
      nops = std::to_string(op->Operands() ? op->Operands()->size() : 0);
      if (op->Operands() && !op->Operands()->empty()) {
        const any* o0 = (*op->Operands())[0];
        std::string k0 = kindName(o0), sz0 = "-", v0 = "-", ct0 = "-";
        if (o0 && o0->UhdmType() == uhdmconstant) {
          const constant* cc = (const constant*)o0;
          sz0 = std::to_string(cc->VpiSize());
          v0 = esc(cc->VpiValue());
          ct0 = std::to_string(cc->VpiConstType());
        } else if (o0) {
          sz0 = std::to_string(((const expr*)o0)->VpiSize());
        }
        op0 = k0 + "/" + sz0 + "/" + v0 + "/" + ct0;
      }
    }
    std::string sz = "-", val = "-", ct = "-", dec = "-";
    if (bo->UhdmType() == uhdmconstant) {
      const constant* cc = (const constant*)bo;
      sz = std::to_string(cc->VpiSize());
      val = esc(cc->VpiValue());
      ct = std::to_string(cc->VpiConstType());
      dec = esc(cc->VpiDecompile());
    }
    std::string ts = "-", tsv = "-", tsn = "-";
    if (const typespec* at = actualTs(bo)) {
      ts = kindName(at);
      tsn = esc(at->VpiName());
      if (at->UhdmType() == uhdminteger_typespec)
        tsv = esc(((const integer_typespec*)at)->VpiValue());
      else if (at->UhdmType() == uhdmint_typespec)
        tsv = esc(((const int_typespec*)at)->VpiValue());
    }
    char line[8192];
    snprintf(line, sizeof line,
             "SPAN=%s\tCTX=%s\tPORTPAR=%s\tCALLARG=%d\tPSBOUND=%d\tROOT=%s\t||"
             "\tKIND=%s\tOPT=%s\tNOPS=%s\tSZ=%s\tVAL=%s\tCT=%s\tDEC=%s"
             "\tTS=%s\tTSV=%s\tTSN=%s\tOP0=%s",
             sp.c_str(), c.cls.c_str(), c.portpar.c_str(), c.callarg,
             c.psbound, c.root.c_str(), kindName(bo).c_str(), opt.c_str(),
             nops.c_str(), sz.c_str(), val.c_str(), ct.c_str(), dec.c_str(),
             ts.c_str(), tsv.c_str(), tsn.c_str(), op0.c_str());
    rows.push_back(line);
    nRow++;
  }
  if (mode == "--spans") {
    std::sort(spans.begin(), spans.end());
    spans.erase(std::unique(spans.begin(), spans.end()), spans.end());
    for (auto& x : spans) printf("%s\n", x.c_str());
    fprintf(stderr, "-- castops=%ld uniq-spans=%zu\n", nCast, spans.size());
    return 0;
  }
  std::sort(rows.begin(), rows.end());
  for (auto& l : rows) printf("%s\n", l.c_str());
  fprintf(stderr, "-- castops=%ld rows=%ld\n", nCast, nRow);
  return 0;
}
