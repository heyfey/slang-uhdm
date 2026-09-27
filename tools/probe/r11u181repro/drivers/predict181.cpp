// predict181 — r11u181's byte-mover predictor, run on PRISTINE databases before the law sweep.
//   predict181 <db.uhdm>...   prints "<db> <LAW,...>" (or "-") per database.
// A database is predicted to move under a law when it holds an object the law rewrites:
//   ROOTFN   a hier_path named `$root.<...>` whose full name reads its own name (stored = name, the
//            no-full-name idiom), unless it is an assignment target holding a select;
//   ROOTELEM a ref_obj element of a `$root.` hier_path whose full name is not its own name;
//   ROOTNET  a `$root.` hier_path (not an assignment target) whose `$root` element is anchored at its own
//            token (the column of the path) -- over-approximates (the builder is not visible here);
//   PARENIDX a bit_select that is not an assignment target, whose span is its index's span, and whose
//            source text has `(` just before the span (read from the object's absolute VpiFile), or whose
//            source line holds a backtick (a macro-born index: over-approximates, the column is the
//            expansion's);
//   INCDECBS an inc/dec operation whose operand is a bit_select;
//   INVSTMT  a begin directly under a function/task with no location (over-approximates: a wrapper whose
//            second item slang could not bind; the unbound item emits no statement, so the count is not read);
//   DECUS    a UINT constant whose decompile holds an underscore;
//   DW       a do_while ending two columns after its start on its own line (DWSYN / DWMACRO);
//   INCDECMIX an inc/dec operation whose operand is a hier_path holding a bit_select element;
//   LVPATH   an assignment's (or op-assignment's) left side that is a hier_path holding a bit_select element
//            (LVCLASS / LVCHAIN / LVIDXREAD over-approximated: the process arms are not visible here);
//   LVCALL   a func_call below an assignment's left side (not a continuous assignment);
//   NEWLHS   an assignment whose right side is a method_func_call `new` and whose left side is a bit_select.
// The source reader refuses any path that names a fenced test (FENCED, word boundary; fail closed).
// build: drivers/cc181.sh.  Fail-closed fence: the caller (predict181.sh) never passes a fenced database.
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <iostream>
#include <map>
#include <set>
#include <string>
#include <vector>
#include <fstream>
#include <regex>
#include <cstdlib>
using namespace UHDM;
static std::regex* fenceRe = nullptr;
static std::map<std::string, std::vector<std::string>> fileCache;
static const std::vector<std::string>* lines(const std::string& f) {
  if (f.empty() || f[0] != '/') return nullptr;
  if (std::regex_search(f, *fenceRe)) { std::cerr << "FENCED path refused\n"; exit(4); }
  auto it = fileCache.find(f);
  if (it != fileCache.end()) return &it->second;
  std::vector<std::string> v; std::ifstream in(f); std::string l;
  while (std::getline(in, l)) v.push_back(l);
  return &(fileCache[f] = v);
}
static bool isLhs(const hier_path* hp) {
  const any* p = hp->VpiParent();
  if (p && p->UhdmType() == uhdmassignment) return ((const assignment*)p)->Lhs() == hp;
  if (p && p->UhdmType() == uhdmcont_assign) return ((const cont_assign*)p)->Lhs() == hp;
  return false;
}
static bool hasSel(const hier_path* hp) {
  if (hp->VpiName().find('[') != std::string_view::npos) return true;
  if (auto* el = hp->Path_elems()) for (auto* e : *el) if (e && e->UhdmType() != uhdmref_obj) return true;
  return false;
}
int main(int argc, char** argv) {
  const char* fe = getenv("FENCED");
  if (!fe) { std::cerr << "FENCED unset\n"; return 3; }
  { std::string s(fe), alt; size_t n = 0; std::string w;
    for (char c : s + " ") { if (c == ' ') { if (!w.empty()) { alt += (alt.empty() ? "" : "|") + w; n++; w.clear(); } } else w += c; }
    if (n != 4) { std::cerr << "FENCED must hold four names\n"; return 3; }
    fenceRe = new std::regex("\\b(" + alt + ")\\b"); }
  for (int ai = 1; ai < argc; ai++) {
    Serializer s; auto designs = s.Restore(std::string(argv[ai])); (void)designs;
    std::set<std::string> laws;
    for (auto& kv : s.AllObjects()) { const BaseClass* o = kv.first; if (!o) continue; auto t = o->UhdmType();
      if (t == uhdmdo_while && o->VpiEndLineNo() == o->VpiLineNo() && o->VpiEndColumnNo() == o->VpiColumnNo() + 2)
        laws.insert("DW");
      if (t == uhdmassignment) {
        auto* as = (const assignment*)o; const any* l = as->Lhs(); const any* r = as->Rhs();
        if (l && l->UhdmType() == uhdmhier_path) {
          if (auto* el = ((const hier_path*)l)->Path_elems())
            for (auto* e : *el) if (e && e->UhdmType() == uhdmbit_select) laws.insert("LVPATH");
        }
        if (l && r && l->UhdmType() == uhdmbit_select && r->UhdmType() == uhdmmethod_func_call && r->VpiName() == "new")
          laws.insert("NEWLHS");
      }
      if (t == uhdmfunc_call) {
        bool inCa = false, inLhs = false; const any* c = o;
        for (const any* a = o->VpiParent(); a; c = a, a = a->VpiParent()) {
          if (a->UhdmType() == uhdmassignment) { inLhs = ((const assignment*)a)->Lhs() == c; break; }
          if (a->UhdmType() == uhdmcont_assign) { inCa = true; break; }
          if (!dynamic_cast<const expr*>(a)) break;
        }
        if (inLhs && !inCa) laws.insert("LVCALL");
      }
      if (t == uhdmconstant) {
        auto* c = (const constant*)o;
        if (c->VpiConstType() == vpiUIntConst && c->VpiDecompile().find('_') != std::string_view::npos) laws.insert("DECUS");
      }
      if (t == uhdmoperation) {
        auto* op = (const operation*)o; int ot = op->VpiOpType();
        if ((ot == vpiPostIncOp || ot == vpiPreIncOp || ot == vpiPostDecOp || ot == vpiPreDecOp) && op->Operands())
          for (auto* x : *op->Operands()) {
            if (x && x->UhdmType() == uhdmbit_select) laws.insert("INCDECBS");
            if (x && x->UhdmType() == uhdmhier_path)
              if (auto* el = ((const hier_path*)x)->Path_elems())
                for (auto* e : *el) if (e && e->UhdmType() == uhdmbit_select) laws.insert("INCDECMIX");
          }
      }
      if (t == uhdmbegin && o->VpiParent() && (o->VpiParent()->UhdmType() == uhdmfunction || o->VpiParent()->UhdmType() == uhdmtask) &&
          o->VpiLineNo() == 0) laws.insert("INVSTMT");
      if (t == uhdmbit_select) {
        auto* bs = (const bit_select*)o; auto* ix = bs->VpiIndex(); const any* p = o->VpiParent();
        bool lhs = p && ((p->UhdmType() == uhdmassignment && ((const assignment*)p)->Lhs() == o) ||
                         (p->UhdmType() == uhdmcont_assign && ((const cont_assign*)p)->Lhs() == o));
        if (ix && !lhs && ix->VpiLineNo() == o->VpiLineNo() && ix->VpiColumnNo() == o->VpiColumnNo() &&
            ix->VpiEndColumnNo() == o->VpiEndColumnNo() && o->VpiLineNo() > 0) {
          std::string f(o->VpiFile());
          if (f.empty() || f[0] != '/') { const any* a = o; while (a && (f.empty() || f[0] != '/')) { a = a->VpiParent(); if (a) f = std::string(a->VpiFile()); } }
          if (auto* L = lines(f)) {
            int ln = o->VpiLineNo(), col = o->VpiColumnNo();
            if (ln >= 1 && (size_t)ln <= L->size()) {
              const std::string& s = (*L)[ln - 1];
              if (s.find('`') != std::string::npos) laws.insert("PARENIDX");
              else if (col >= 2 && (size_t)(col - 2) < s.size()) {
                size_t k = col - 2; while (k > 0 && (s[k] == ' ' || s[k] == '\t')) k--;
                if (s[k] == '(') laws.insert("PARENIDX");
              }
            }
          }
        }
      }
      if (t == uhdmhier_path) {
        auto* hp = (const hier_path*)o;
        if (hp->VpiName().rfind("$root.", 0) == 0) {
          bool lhs = isLhs(hp);
          if (!(lhs && hasSel(hp)) && hp->VpiFullName() == hp->VpiName()) laws.insert("ROOTFN");
          if (auto* el = hp->Path_elems()) {
            for (auto* e : *el) if (e && e->UhdmType() == uhdmref_obj && !e->VpiName().empty() &&
                                     ((const ref_obj*)e)->VpiFullName() != e->VpiName()) laws.insert("ROOTELEM");
            if (!lhs && el->size() > 1 && (*el)[0] && (*el)[0]->VpiColumnNo() == hp->VpiColumnNo() &&
                (*el)[0]->VpiLineNo() == hp->VpiLineNo()) laws.insert("ROOTNET");
          }
        }
      }
    }
    std::string out; for (auto& l : laws) out += (out.empty() ? "" : ",") + l;
    std::cout << argv[ai] << " " << (out.empty() ? "-" : out) << "\n";
  }
  return 0;
}
