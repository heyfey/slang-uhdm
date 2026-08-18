// r10uvm96 — MEASUREMENT-ONLY.  THE CAST-TARGET TYPESPEC census.
//
// Surelog compiles an explicit cast (`paCast` / `paConstant_cast`,
// CompileExpression.cpp:2636) into `operation(vpiCastOp)` whose `Typespec()`
// is a `ref_typespec` wrapping whatever `CompileHelper::compileTypespec`
// returns for the WRITTEN casting-type node.  That dispatch is a switch on the
// KEYWORD NODE, so the cast target's typespec KIND is a pure function of the
// text to the left of the `'`.  This tool emits one row per cast operation so
// golden and ours can be joined on the operation's SPAN alone.
//
// row: SPAN \t TSKIND \t TSSPAN \t SRCTEXT \t REFNAME \t OPERANDKINDS
//      \t CARRIER \t OWNER \t FILE
//
// SPAN is line:col-endline:endcol WITHOUT the file: `VpiFile` is EMPTY on most
// of OUR objects (uhdm-dump synthesises it from the parent chain) and the
// nearest file-bearing ANCESTOR is not the same object on the two sides, so a
// file-keyed join reported 100% disagreement.  The join key is SPAN + OWNER
// (a vpiFullName, stable on both sides); FILE is a READING column only.
//
//   TSKIND   the Actual_typespec's UHDM kind (`<null>` / `<noref>` when absent)
//   TSSPAN   the Actual_typespec's own span (line:col-endline:endcol)
//   SRCTEXT  the source text at the TYPESPEC's span, whitespace-squeezed --
//            i.e. the cast target AS WRITTEN.  `SRC?` when the file or the
//            span is unavailable (macro bodies and pp_output still resolve).
//   REFNAME  the ref_typespec's VpiName (NOT VpiFullName, which uhdm-dump
//            synthesises from the parent chain)
//
// usage: ct96cen <db.uhdm>
// build: g++ -O2 -std=c++17 ct96cen.cpp -I ~/.local/include \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct96cen
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
// The written text spanned by [line:col , endline:endcol) -- squeezed.
static std::string srcText(const std::string& path, uint32_t l0, uint32_t c0,
                           uint32_t l1, uint32_t c1) {
  if (path.empty() || l0 == 0 || c0 == 0) return "SRC?";
  const std::vector<std::string>* ls = linesOf(path);
  if (!ls || l0 > ls->size() || l1 > ls->size() || l1 < l0) return "SRC?";
  std::string out;
  for (uint32_t l = l0; l <= l1; l++) {
    const std::string& line = (*ls)[l - 1];
    size_t b = (l == l0) ? (size_t)c0 - 1 : 0;
    size_t e = (l == l1) ? (size_t)c1 - 1 : line.size();
    if (b > line.size()) b = line.size();
    if (e > line.size()) e = line.size();
    if (e > b) out += line.substr(b, e - b);
    if (l != l1) out += " ";
  }
  std::string sq;
  bool sp = false;
  for (char ch : out) {
    if (isspace((unsigned char)ch)) { sp = true; continue; }
    if (sp && !sq.empty()) sq += ' ';
    sp = false;
    sq += ch;
  }
  if (sq.empty()) return "SRC-EMPTY";
  return sq;
}
static std::string kindName(const BaseClass* o) {
  if (!o) return "<null>";
  return std::string(UHDM::UhdmName(o->UhdmType()));
}
static std::string base(std::string_view p) {
  size_t i = p.find_last_of('/');
  return std::string(i == std::string_view::npos ? p : p.substr(i + 1));
}
static std::string ownerStr(const BaseClass* o) {
  const BaseClass* p = o ? o->VpiParent() : nullptr;
  for (int i = 0; i < 200 && p; i++) {
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
// VpiFile is EMPTY on most of OUR objects (uhdm-dump synthesises it from the
// parent chain), so the file must be RESOLVED the same way on both sides --
// otherwise every key differs and the join reports 100% disagreement.
static std::string fileOf(const BaseClass* o) {
  for (int i = 0; i < 200 && o; i++) {
    std::string_view f = o->VpiFile();
    if (!f.empty()) return base(f);
    o = o->VpiParent();
  }
  return "<nofile>";
}
static std::string fullFileOf(const BaseClass* o) {
  for (int i = 0; i < 200 && o; i++) {
    std::string_view f = o->VpiFile();
    if (!f.empty()) return std::string(f);
    o = o->VpiParent();
  }
  return "";
}
static std::string carrierStr(const BaseClass* o) {
  const BaseClass* p = o ? o->VpiParent() : nullptr;
  return p ? kindName(p) : "<noparent>";
}
int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: ct96cen <db.uhdm>\n"); return 2; }
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "RESTORE_FAILED %s\n", argv[1]); return 3; }
  auto all = s.AllObjects();
  std::vector<std::string> rows;
  for (auto& pr : all) {
    const BaseClass* o = pr.first;
    if (!o) continue;
    if (o->UhdmType() != uhdmoperation) continue;
    auto* op = (const operation*)o;
    if (op->VpiOpType() != vpiCastOp) continue;
    const ref_typespec* rt = op->Typespec();
    const typespec* ats = rt ? rt->Actual_typespec() : nullptr;
    std::string tsk = rt ? (ats ? kindName(ats) : std::string("<null>"))
                         : std::string("<noref>");
    char tsp[128] = "-";
    std::string stx = "SRC?";
    if (ats) {
      snprintf(tsp, sizeof tsp, "%u:%u-%u:%u", ats->VpiLineNo(),
               ats->VpiColumnNo(), ats->VpiEndLineNo(), ats->VpiEndColumnNo());
      std::string f = fullFileOf(ats);
      if (f.empty()) f = fullFileOf(o);
      stx = srcText(f, ats->VpiLineNo(), ats->VpiColumnNo(),
                    ats->VpiEndLineNo(), ats->VpiEndColumnNo());
    }
    std::string rn = rt ? std::string(rt->VpiName()) : std::string("-");
    if (rn.empty()) rn = "<empty>";
    std::string argk;
    if (auto* ops = op->Operands()) {
      for (auto* x : *ops) { if (!argk.empty()) argk += ","; argk += kindName(x); }
    }
    if (argk.empty()) argk = "<noops>";
    char sp[160];
    snprintf(sp, sizeof sp, "%u:%u-%u:%u", o->VpiLineNo(), o->VpiColumnNo(),
             o->VpiEndLineNo(), o->VpiEndColumnNo());
    rows.push_back(std::string(sp) + "\t" + tsk + "\t" + tsp + "\t" + stx +
                   "\t" + rn + "\t" + argk + "\t" + carrierStr(o) + "\t" +
                   ownerStr(o) + "\t" + fileOf(o));
  }
  std::sort(rows.begin(), rows.end());
  for (auto& r : rows) printf("%s\n", r.c_str());
  fprintf(stderr, "ROWS %zu\n", rows.size());
  return 0;
}
