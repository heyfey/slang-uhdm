// predict184 — r11u184's byte-mover predictor, run on PRISTINE databases before the law sweep.
//   predict184 <db.uhdm>...   prints "<db> <LAW,...>" (or "-") per database.
// A database is predicted to move under a law when it holds an object the law rewrites:
//   GENENUM   an enum_const parented at a ref_obj (the loc-less lateBinding mint) below a gen_scope
//             (over-approximates: whether the block declares the enum or a variable of it is not read);
//   TPENUM    a type_parameter whose typespec is an enum_typespec without a line (the unlocated copy);
//   MEMPAREN  a bit_select element of a hier_path (not an assignment target), spanned exactly as its index,
//             whose source has `(` just before the span, or whose line holds a backtick (read from the object's
//             absolute VpiFile; fence-refusing);
//   INCDECSEL an inc/dec operation whose operand is a hier_path whose LAST element is a bit_select;
//   LVIDXSEL  a hier_path whose last element is a bit_select, reached from an assignment's / continuous
//             assignment's left side through selects and operations only, not being that left side;
//   GSTRAIL   a hier_path whose last element is a bit_select, below a gen_scope (over-approximates: the
//             process / assignment context is not read);
//   ROOTLV    a hier_path named `$root.<...>` that is an assignment's / continuous assignment's left side;
//   STREAMRD  a hier_path or bit_select that is an operand of a streaming operation (directly or through
//             concatenations) that is itself (inside) an assignment's left side;
//   HPIDXCALL a func_call reached from a NON-LAST bit_select element of a hier_path through operations and
//             bit_selects only, spanning more than its name.
// build: drivers/cc184.sh.  Fail-closed fence: FENCED must hold four names; the caller never passes a fenced
// database, and the source reader refuses any path naming a fenced test (exit 4).
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
static bool underGenScope(const any* o) {
  for (const any* a = o->VpiParent(); a; a = a->VpiParent())
    if (a->UhdmType() == uhdmgen_scope) return true;
  return false;
}
static const any* lastElem(const hier_path* hp) {
  auto* el = hp->Path_elems();
  if (!el || el->empty()) return nullptr;
  return el->back();
}
static bool isSel(UHDM_OBJECT_TYPE t) {
  return t == uhdmbit_select || t == uhdmpart_select || t == uhdmindexed_part_select || t == uhdmvar_select ||
         t == uhdmoperation || t == uhdmhier_path;
}
int main(int argc, char** argv) {
  const char* fe = getenv("FENCED");
  if (!fe) { std::cerr << "FENCED unset\n"; return 3; }
  { std::string s(fe), alt; size_t n = 0; std::string w;
    for (char c : s + " ") { if (c == ' ') { if (!w.empty()) { alt += (alt.empty() ? "" : "|") + w; n++; w.clear(); } } else w += c; }
    if (n != 4) { std::cerr << "FENCED must hold four names\n"; return 3; }
    fenceRe = new std::regex("\\b(" + alt + ")\\b"); }
  for (int ai = 1; ai < argc; ai++) {
    if (std::regex_search(std::string(argv[ai]), *fenceRe)) { std::cerr << "FENCED database refused\n"; return 4; }
    Serializer s; auto designs = s.Restore(std::string(argv[ai])); (void)designs;
    std::set<std::string> laws;
    for (auto& kv : s.AllObjects()) { const BaseClass* o = kv.first; if (!o) continue; auto t = o->UhdmType();
      if (t == uhdmenum_const && o->VpiParent() && o->VpiParent()->UhdmType() == uhdmref_obj && underGenScope(o))
        laws.insert("GENENUM");
      if (t == uhdmtype_parameter) {
        if (auto* rt = ((const type_parameter*)o)->Typespec())
          if (auto* ts = rt->Actual_typespec())
            if (ts->UhdmType() == uhdmenum_typespec && ts->VpiLineNo() == 0) laws.insert("TPENUM");
      }
      if (t == uhdmoperation) {
        auto* op = (const operation*)o; int ot = op->VpiOpType();
        if ((ot == vpiPostIncOp || ot == vpiPreIncOp || ot == vpiPostDecOp || ot == vpiPreDecOp) && op->Operands())
          for (auto* x : *op->Operands())
            if (x && x->UhdmType() == uhdmhier_path) {
              auto* le = lastElem((const hier_path*)x);
              if (le && le->UhdmType() == uhdmbit_select) laws.insert("INCDECSEL");
            }
      }
      if (t == uhdmhier_path || t == uhdmbit_select) {
        const any* c = o; bool viaStream = false;
        for (const any* a = o->VpiParent(); a; c = a, a = a->VpiParent()) {
          auto at = a->UhdmType();
          if (at == uhdmoperation) {
            int ot = ((const operation*)a)->VpiOpType();
            if (ot == vpiStreamLROp || ot == vpiStreamRLOp) viaStream = true;
            else if (ot != vpiConcatOp) break;
            continue;
          }
          if (at == uhdmassignment) { if (viaStream && ((const assignment*)a)->Lhs() == c) laws.insert("STREAMRD"); break; }
          break;
        }
      }
      if (t == uhdmfunc_call && (o->VpiEndColumnNo() > o->VpiColumnNo() + (int)o->VpiName().size() ||
                                 o->VpiEndLineNo() > o->VpiLineNo())) {
        const any* q = o->VpiParent();
        while (q && (q->UhdmType() == uhdmoperation ||
                     (q->UhdmType() == uhdmbit_select && q->VpiParent() && q->VpiParent()->UhdmType() != uhdmhier_path)))
          q = q->VpiParent();
        if (q && q->UhdmType() == uhdmbit_select && q->VpiParent() && q->VpiParent()->UhdmType() == uhdmhier_path) {
          auto* el = ((const hier_path*)q->VpiParent())->Path_elems();
          if (el && !el->empty() && el->back() != q) laws.insert("HPIDXCALL");
        }
        // (an index § hierPathSelIdxAtPath178 hung off the path: its parent is the hier_path itself)
        if (q && q->UhdmType() == uhdmhier_path) laws.insert("HPIDXCALL");
      }
      if (t == uhdmhier_path && o->VpiName().rfind("$root.", 0) == 0) {
        const any* p = o->VpiParent();
        if (p && ((p->UhdmType() == uhdmassignment && ((const assignment*)p)->Lhs() == o) ||
                  (p->UhdmType() == uhdmcont_assign && ((const cont_assign*)p)->Lhs() == o)))
          laws.insert("ROOTLV");
      }
      if (t == uhdmhier_path) {
        auto* hp = (const hier_path*)o; auto* le = lastElem(hp);
        if (le && le->UhdmType() == uhdmbit_select) {
          if (underGenScope(o)) laws.insert("GSTRAIL");
          const any* c = o; bool viaSel = false;
          for (const any* a = o->VpiParent(); a; c = a, a = a->VpiParent()) {
            auto at = a->UhdmType();
            if (at == uhdmassignment) { if (viaSel && ((const assignment*)a)->Lhs() == c) laws.insert("LVIDXSEL"); break; }
            if (at == uhdmcont_assign) { if (viaSel && ((const cont_assign*)a)->Lhs() == c) laws.insert("LVIDXSEL"); break; }
            if (!isSel(at)) break;
            if (at != uhdmoperation) viaSel = true;
          }
          // MEMPAREN
          auto* bs = (const bit_select*)le; auto* ix = bs->VpiIndex(); const any* p = o->VpiParent();
          bool lhs = p && ((p->UhdmType() == uhdmassignment && ((const assignment*)p)->Lhs() == o) ||
                           (p->UhdmType() == uhdmcont_assign && ((const cont_assign*)p)->Lhs() == o));
          if (ix && !lhs && ix->VpiLineNo() == bs->VpiLineNo() && ix->VpiColumnNo() == bs->VpiColumnNo() &&
              ix->VpiEndColumnNo() == bs->VpiEndColumnNo() && bs->VpiLineNo() > 0) {
            std::string f(bs->VpiFile());
            if (f.empty() || f[0] != '/') { const any* a = bs; while (a && (f.empty() || f[0] != '/')) { a = a->VpiParent(); if (a) f = std::string(a->VpiFile()); } }
            if (auto* L = lines(f)) {
              int ln = bs->VpiLineNo(), col = bs->VpiColumnNo();
              if (ln >= 1 && (size_t)ln <= L->size()) {
                const std::string& sl = (*L)[ln - 1];
                if (sl.find('`') != std::string::npos) laws.insert("MEMPAREN");
                else if (col >= 2 && (size_t)(col - 2) < sl.size()) {
                  size_t k = col - 2; while (k > 0 && (sl[k] == ' ' || sl[k] == '\t')) k--;
                  if (sl[k] == '(') laws.insert("MEMPAREN");
                }
              }
            }
          }
        }
      }
    }
    std::string out; for (auto& l : laws) out += (out.empty() ? "" : ",") + l;
    std::cout << argv[ai] << " " << (out.empty() ? "-" : out) << "\n";
  }
  return 0;
}
