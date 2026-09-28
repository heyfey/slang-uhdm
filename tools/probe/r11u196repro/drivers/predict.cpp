// r11u196: the byte-mover predictor, read from a PRISTINE database only (and, for TPARR, the source line the database
// locates).  Prints one token per r11u196 law whose trigger the database carries; each trigger is derived from the
// law's condition and is an UPPER bound (it may name a database the law leaves unchanged, never the reverse):
//   MODGEN   a class_typespec with no vpiClassDefn, or a class_typespec param_assign with no Lhs: the handle of a class
//            the module listing lacked (modGenericClassListed196 / modGenericHandleBare196 / modClassTsLinksDefListing196)
//   ELEMCLS  an array_typespec or an array_var element class_var whose class_typespec spans more than its name
//            (classPropElemClassTsAtName196)
//   RETQUAL  a function return whose typespec is a clone with a Typedef_alias to `<pkg>::<its own name>`
//            (retPkgQualTdNoAlias196)
//   TPARR    a packed_array_var range whose located bound's source text holds an operator (tpArrBoundAtLeftOperand196)
//   DFLTARG  a cont_assign whose Rhs is a func_call of a function with a defaulted io_decl
//            (evalFuncOmittedDefaultKeepsCall196)
//   FCFILE   an io_decl whose typespec is a clone carrying a Typedef_alias filed apart from the io_decl
//            (tfFormalTdCloneFile196)
// usage: predict <db.uhdm>
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_user.h>
#include <cstdio>
#include <fstream>
#include <map>
#include <set>
#include <string>
using namespace UHDM;
static std::map<std::string, std::vector<std::string>> fileCache;
static std::string srcLine(const std::string& f, int l) {
  auto it = fileCache.find(f);
  if (it == fileCache.end()) {
    std::vector<std::string> v; std::ifstream in(f); std::string s;
    while (std::getline(in, s)) v.push_back(s);
    it = fileCache.emplace(f, v).first;
  }
  if (l < 1 || (size_t)l > it->second.size()) return {};
  return it->second[l - 1];
}
int main(int argc, char** argv) {
  if (argc < 2) return 2;
  Serializer s;
  s.Restore(std::string(argv[1]));
  std::set<std::string> fired;
  for (auto& kv : s.AllObjects()) {
    auto* o = (const any*)kv.first;
    if (!o) continue;
    switch (o->UhdmType()) {
      case uhdmclass_typespec: {
        auto* ct = (const class_typespec*)o;
        if (!ct->VpiName().empty() && !ct->Class_defn()) fired.insert("MODGEN");
        if (auto* pas = ct->Param_assigns())
          for (auto* pa : *pas) if (pa && !pa->Lhs()) fired.insert("MODGEN");
        break;
      }
      case uhdmarray_typespec: {
        auto* at = (const array_typespec*)o;
        if (auto* er = at->Elem_typespec())
          if (auto* et = er->Actual_typespec(); et && et->UhdmType() == uhdmclass_typespec)
            if (et->VpiLineNo() && (et->VpiLineNo() != et->VpiEndLineNo() ||
                                    et->VpiEndColumnNo() > et->VpiColumnNo() + et->VpiName().size()))
              fired.insert("ELEMCLS");
        break;
      }
      case uhdmclass_var: {
        // the array element's class_var (an array_var's element), typed by the class_typespec
        auto* cv = (const class_var*)o;
        if (cv->VpiParent() && cv->VpiParent()->UhdmType() == uhdmarray_var)
          if (auto* rt = cv->Typespec())
            if (auto* et = rt->Actual_typespec(); et && et->UhdmType() == uhdmclass_typespec)
              if (et->VpiLineNo() && (et->VpiLineNo() != et->VpiEndLineNo() ||
                                      et->VpiEndColumnNo() > et->VpiColumnNo() + et->VpiName().size()))
                fired.insert("ELEMCLS");
        break;
      }
      case uhdmfunction: {
        auto* f = (const function*)o;
        if (auto* rv = f->Return())
          if (auto* rt = rv->Typespec())
            if (auto* t = rt->Actual_typespec())
              if (auto* al = t->Typedef_alias())
                if (auto* a = al->Actual_typespec()) {
                  std::string an(a->VpiName()), tn(t->VpiName());
                  if (!tn.empty() && an.size() > tn.size() + 2 && an.find("::") != std::string::npos &&
                      an.compare(an.size() - tn.size() - 2, tn.size() + 2, "::" + tn) == 0)
                    fired.insert("RETQUAL");
                }
        break;
      }
      case uhdmpacked_array_var: {
        auto* pv = (const packed_array_var*)o;
        if (auto* rs = pv->Ranges())
          for (auto* r : *rs)
            for (const expr* b : {r->Left_expr(), r->Right_expr()})
              if (b && b->VpiLineNo()) {
                std::string ln = srcLine(std::string(r->VpiFile().empty() ? b->VpiFile() : r->VpiFile()), r->VpiLineNo());
                if (ln.empty()) ln = srcLine(std::string(b->VpiFile()), b->VpiLineNo());
                if (r->VpiLineNo() == r->VpiEndLineNo() && r->VpiEndColumnNo() > r->VpiColumnNo() &&
                    ln.size() >= (size_t)r->VpiEndColumnNo() - 1) {
                  std::string t = ln.substr(r->VpiColumnNo() - 1, r->VpiEndColumnNo() - r->VpiColumnNo());
                  if (t.find_first_of("+-*/%&|^<>") != std::string::npos) fired.insert("TPARR");
                }
              }
        break;
      }
      case uhdmcont_assign: {
        auto* ca = (const cont_assign*)o;
        if (auto* rhs = ca->Rhs(); rhs && rhs->UhdmType() == uhdmfunc_call)
          if (auto* fn = ((const func_call*)rhs)->Function())
            if (auto* ios = fn->Io_decls())
              for (auto* io : *ios) if (io && io->Expr()) fired.insert("DFLTARG");
        break;
      }
      case uhdmio_decl: {
        auto* io = (const io_decl*)o;
        if (auto* rt = io->Typespec())
          if (auto* t = rt->Actual_typespec())
            if (t->Typedef_alias() && !t->VpiFile().empty() && !io->VpiFile().empty() &&
                t->VpiFile() != io->VpiFile())
              fired.insert("FCFILE");
        break;
      }
      default: break;
    }
  }
  for (auto& f : fired) printf("%s\n", f.c_str());
  return 0;
}
