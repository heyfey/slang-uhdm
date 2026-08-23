// r10buvm27 — MEASUREMENT-ONLY.  The TYPE-QUERY FOLD census (r10uvm95's
// ct95cen.cpp plus the ARGUMENT SUB-SHAPE column § binOpLeftmostSelectBits27
// needs: for a call whose first argument is an `operation`, the vpiOpType and
// the FIRST OPERAND's kind — the two facts that decide whether this pass's
// rule can reach the cell.  That column IS the mover predictor.
//
// Surelog's `CompileHelper::compileBits` (CompileExpression.cpp:4663) answers
// `$bits(<arg>)` / `$size(<arg>)` either with a MINTED unsized-decimal constant
// (`UINT:<w>`, vpiSize 64, vpiConstType 9 — LOCATED once compileExpression's
// tail fills the span) or with the surviving `sys_func_call`.  This tool emits
// one row per CANDIDATE SPAN of a database so golden and ours can be joined on
// the span alone (no source text needed — the UVM head's span is a MACRO BODY
// position where the written text is `SIZE`, not `$bits`).
//
// CANDIDATE SPAN = a span carrying either
//   * a `sys_func_call` whose name is a type query
//     ($bits $size $clog2 $high $low $left $right $dimensions
//      $unpacked_dimensions $increment), or
//   * a `constant` with vpiSize==64 && vpiConstType==vpiUIntConst — the exact
//     signature compileBits mints (uvm93 § streamSliceTypeBits93).
//
// row:  FILE:line:col-endline:endcol \t KIND \t NAME/DECOMPILE \t ARGK \t OWNER
// usage: ct95cen <db.uhdm>
// build: g++ -O2 -std=c++17 ct95cen.cpp -I ~/.local/include \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct95cen
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <string>
#include <map>
#include <set>
#include <vector>
#include <algorithm>
#include <fstream>
using namespace UHDM;

// The SOURCE TEXT flag: does the written text at (file,line,col) begin with a
// `$`?  A folded type query keeps the CALL's own span, so this separates a
// plain-source `$bits(...)` site from a range bound that merely wears the same
// mint signature -- and from a MACRO-BODY substitution (the UVM head), where
// the written text at the span is the macro FORMAL and the flag reads SRC-.
static std::map<std::string, std::vector<std::string>> g_files;
static const std::vector<std::string>* linesOf(const std::string& path) {
  auto it = g_files.find(path);
  if (it != g_files.end()) return it->second.empty() ? nullptr : &it->second;
  std::vector<std::string> v;
  std::ifstream f(path);
  std::string l;
  while (std::getline(f, l)) v.push_back(l);
  auto& slot = g_files[path];
  slot = std::move(v);
  return slot.empty() ? nullptr : &slot;
}
static const char* srcFlag(const BaseClass* o) {
  std::string path(o->VpiFile());
  if (path.empty()) return "SRC?";
  const std::vector<std::string>* ls = linesOf(path);
  if (!ls) return "SRC?";
  uint32_t ln = o->VpiLineNo(), col = o->VpiColumnNo();
  if (ln == 0 || col == 0 || ln > ls->size()) return "SRC?";
  const std::string& line = (*ls)[ln - 1];
  if (col - 1 >= line.size()) return "SRC?";
  return line[col - 1] == '$' ? "SRC$" : "SRC-";
}

static std::string kindName(const BaseClass* o) {
  if (!o) return "<null>";
  return std::string(UHDM::UhdmName(o->UhdmType()));
}
static std::string base(std::string_view p) {
  size_t i = p.find_last_of('/');
  return std::string(i == std::string_view::npos ? p : p.substr(i + 1));
}
static bool isTypeQuery(std::string_view n) {
  static const std::set<std::string> q = {
      "$bits", "$size", "$clog2", "$high", "$low", "$left", "$right",
      "$dimensions", "$unpacked_dimensions", "$increment"};
  return q.count(std::string(n)) != 0;
}
static std::string ownerStr(const BaseClass* o) {
  const BaseClass* p = o ? o->VpiParent() : nullptr;
  for (int i = 0; i < 80 && p; i++) {
    UHDM_OBJECT_TYPE t = p->UhdmType();
    if (t == uhdmclass_defn || t == uhdmpackage || t == uhdmmodule_inst ||
        t == uhdmfunction || t == uhdmtask || t == uhdmgen_scope) {
      vpiHandle h = NewVpiHandle(p);
      const char* s = h ? vpi_get_str(vpiFullName, h) : nullptr;
      std::string r = s ? s : std::string(p->VpiName());
      if (h) vpi_free_object(h);
      return kindName(p) + ":" + (r.empty() ? "<anon>" : r);
    }
    p = p->VpiParent();
  }
  return "<unparented>";
}
// The immediate parent KIND -- the carrier (operation / assignment / range / ...)
static std::string carrierStr(const BaseClass* o) {
  const BaseClass* p = o ? o->VpiParent() : nullptr;
  return p ? kindName(p) : "<noparent>";
}
int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: ct95cen <db.uhdm>\n"); return 2; }
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "RESTORE_FAILED %s\n", argv[1]); return 3; }
  auto all = s.AllObjects();
  std::vector<std::string> rows;
  for (auto& pr : all) {
    const BaseClass* o = pr.first;
    if (!o) continue;
    UHDM_OBJECT_TYPE t = o->UhdmType();
    std::string kind, val, argk = "-";
    if (t == uhdmsys_func_call) {
      auto* sc = (const sys_func_call*)o;
      if (!isTypeQuery(sc->VpiName())) continue;
      kind = "CALL";
      val = std::string(sc->VpiName());
      auto* a = sc->Tf_call_args();
      if (a && !a->empty()) {
        argk.clear();
        for (auto* x : *a) { if (!argk.empty()) argk += ","; argk += kindName(x); }
        // SUB-SHAPE of the FIRST argument when it is an operation: the opType
        // and the leading operand's kind.  `$bits(m_data[i] & be)` reads
        // `operation[op28/bit_select]`; `$bits({a,b})` reads `[op33/...]`
        // (concat) and `$bits(~x)` reads `[op4/...]` (unary) — neither is a
        // cell this pass's rule can reach.
        const any* a0 = a->at(0);
        if (a0 && a0->UhdmType() == uhdmoperation) {
          const operation* op = (const operation*)a0;
          std::string sub = "[op" + std::to_string(op->VpiOpType()) + "/";
          if (auto* ops = op->Operands(); ops && !ops->empty())
            sub += kindName(ops->at(0));
          else
            sub += "<noops>";
          argk += sub + "]";
        }
      } else argk = "<noargs>";
    } else if (t == uhdmconstant) {
      auto* c = (const constant*)o;
      if (c->VpiSize() != 64 || c->VpiConstType() != vpiUIntConst) continue;
      kind = "CONST";
      val = std::string(c->VpiDecompile());
    } else continue;
    char sp[128];
    snprintf(sp, sizeof sp, "%s:%u:%u-%u:%u", base(o->VpiFile()).c_str(),
             o->VpiLineNo(), o->VpiColumnNo(), o->VpiEndLineNo(),
             o->VpiEndColumnNo());
    rows.push_back(std::string(sp) + "\t" + kind + "\t" + val + "\t" + argk +
                   "\t" + carrierStr(o) + "\t" + ownerStr(o) + "\t" +
                   srcFlag(o));
  }
  std::sort(rows.begin(), rows.end());
  for (auto& r : rows) printf("%s\n", r.c_str());
  fprintf(stderr, "ROWS %zu\n", rows.size());
  return 0;
}
