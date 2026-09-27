// predict190 <db.uhdm>...: the byte-mover predictor of fix.patch, run on the HEAD (8e3153a2) databases BEFORE the
// fix sweep.  Prints "<db> <TAG,...>" or "<db> -".
//   ENUMITEM  (§ enumImpNamedItemWrites190v) the design holds a package with an enum_typespec typedef, and one of the
//             design's source files holds an explicit import `import <that package>::<item>` whose item is not that
//             enum typedef (an enum literal, another typedef, a function...): the importer's record is withheld.
//             Source files are the VpiFile of every object of the database; each is read as text.
//   NESTIDX   (§ nestRdIdxOnly190v) a hier_path below a call (func_call / sys_func_call / method_func_call) that is
//             itself nested (through expressions) in another hier_path H1 inside an assignment's left side or an
//             inc/dec operand without being that side (predict181v's NESTRD trigger, narrowed to a call between).
// Fence: the caller never passes a fenced database (predict190.sh, fail closed); a source path naming a fenced test
// by word boundary ($FENCED, four names required) is refused (exit 4).
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <regex>
#include <set>
#include <sstream>
#include <string>
#include <vector>
using namespace UHDM;
static std::vector<std::string> fenced;
static bool isFenced(const std::string& p) {
  for (auto& f : fenced) {
    std::regex r("\\b" + f + "\\b");
    if (std::regex_search(p, r)) return true;
  }
  return false;
}
static bool isIncDec(const any* a) {
  if (!a || a->UhdmType() != uhdmoperation) return false;
  int ot = ((const operation*)a)->VpiOpType();
  return ot == vpiPostIncOp || ot == vpiPreIncOp || ot == vpiPostDecOp || ot == vpiPreDecOp;
}
static bool isCall(const any* a) {
  auto t = a->UhdmType();
  return t == uhdmfunc_call || t == uhdmsys_func_call || t == uhdmmethod_func_call;
}
int main(int argc, char** argv) {
  const char* F = getenv("FENCED");
  if (!F) { std::cerr << "predict190: FENCED unset\n"; return 3; }
  { std::istringstream is(F); std::string w; while (is >> w) fenced.push_back(w); }
  if (fenced.size() != 4) { std::cerr << "predict190: FENCED must hold four names\n"; return 3; }
  std::regex imp("import\\s+([A-Za-z_][A-Za-z0-9_$]*)\\s*::\\s*([A-Za-z_][A-Za-z0-9_$]*)");
  for (int ai = 1; ai < argc; ai++) {
    Serializer s; auto designs = s.Restore(std::string(argv[ai])); (void)designs;
    std::set<std::string> tags, files;
    std::set<std::string> enumPkgs;             // package names holding an enum typedef
    std::set<std::string> enumTds;              // "pkg::name" of those typedefs
    for (auto& kv : s.AllObjects()) {
      const BaseClass* o = kv.first; if (!o) continue; auto t = o->UhdmType();
      if (!o->VpiFile().empty()) files.insert(std::string(o->VpiFile()));
      if (t == uhdmpackage) {
        auto* p = (const package*)o;
        if (p->Typespecs())
          for (auto* ts : *p->Typespecs())
            if (ts && ts->UhdmType() == uhdmenum_typespec) {
              enumPkgs.insert(std::string(p->VpiName()));
              enumTds.insert(std::string(ts->VpiName()));
            }
      }
      if (t != uhdmhier_path) continue;
      // NESTIDX: walk up through expressions
      bool callSeen = false; int nonRootAfterCall = 0; const any* c = (const any*)o; bool lv = false;
      std::vector<const any*> hps;
      for (const any* a = o->VpiParent(); a; c = a, a = a->VpiParent()) {
        auto at = a->UhdmType();
        if (at == uhdmassignment) { lv = ((const assignment*)a)->Lhs() == c; if (lv) for (auto* h : hps) if (h != c) nonRootAfterCall++; break; }
        if (at == uhdmcont_assign) break;
        if (isIncDec(a)) { lv = true; for (auto* h : hps) if (h != c) nonRootAfterCall++; break; }
        if (isCall(a)) callSeen = true;
        if (at == uhdmhier_path && callSeen) hps.push_back(a);
        if (!dynamic_cast<const expr*>(a)) break;
      }
      if (lv && nonRootAfterCall >= 1) tags.insert("NESTIDX");
    }
    if (!enumPkgs.empty())
      for (auto& f : files) {
        if (isFenced(f)) { std::cerr << "predict190: fenced source refused\n"; return 4; }
        std::ifstream in(f); if (!in) continue;
        std::stringstream ss; ss << in.rdbuf(); std::string txt = ss.str();
        for (std::sregex_iterator it(txt.begin(), txt.end(), imp), e; it != e; ++it) {
          std::string pk = (*it)[1], item = (*it)[2];
          if (enumPkgs.count(pk) && !enumTds.count(pk + "::" + item)) { tags.insert("ENUMITEM"); break; }
        }
        if (tags.count("ENUMITEM")) break;
      }
    std::string out; for (auto& l : tags) out += (out.empty() ? "" : ",") + l;
    std::cout << argv[ai] << " " << (out.empty() ? "-" : out) << "\n";
  }
  return 0;
}
