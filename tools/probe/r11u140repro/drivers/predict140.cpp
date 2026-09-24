// predict140: reads a PRISTINE database and prints which r11u140 law's trigger it
// holds (one line per law with a count). Measurement only.
//  SYSUNARY    a one-operand operation under a sys_func_call spanning one column
//              (the operator token), outside any part_select
//  STREAMBRACE a stream operation (71/72) whose span does not start at `{`
//              (source text read from the file)
//  LVIDX       an assignment-Lhs hier_path whose last element is a bit_select with
//              a ref_obj index (directly or under operations) whose stored full
//              name lacks the path's name
//  LVTRAIL     an assignment-Lhs hier_path whose first element is a bit_select and
//              whose last element is a bit_select not located at its index
//  FEFILE      a located unsupported_typespec with no file
//  PATOPSPAN   an op75 operation directly under an operation under a param_assign,
//              located outside its parent's line range
//  MULTIDECL   a begin under a function/task on the line of >= 2 of the
//              subroutine's (or its own) variables
//  LHSARRTS    a param_assign Lhs parameter that is not its scope's listed parameter
//              and reaches the array_typespec a listed parameter reaches
//  PKGREFMD    an elaborated module's param_assign whose Rhs constant is parented at
//              ANOTHER param_assign (the ParameterFromPkg clone arm)
//  PKGTDCAST   a valueless, expressionless integer_typespec under a ref_typespec under
//              an operation under a package param_assign
//  DEFFILL     an array_expr holding >= 2 distinct constant objects of one value
//  REPLCNTFILE a located constant with no file under an op76 operation
#include <uhdm/Serializer.h>
#include <uhdm/VpiListener.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_visitor.h>
#include <fstream>
#include <functional>
#include <iostream>
#include <map>
#include <set>
#include <memory>
#include <string>
#include <vector>
using namespace UHDM;
namespace {
std::map<std::string, int> hits;
std::map<std::string, std::vector<std::string>> files;
std::string lineOf(const std::string& f, int ln) {
  auto it = files.find(f);
  if (it == files.end()) {
    std::vector<std::string> v;
    std::ifstream in(f);
    std::string l;
    while (std::getline(in, l)) v.push_back(l);
    it = files.emplace(f, v).first;
  }
  if (ln <= 0 || ln > (int)it->second.size()) return "";
  return it->second[ln - 1];
}
std::string fileOf(const any* o) {
  for (const any* p = o; p; p = p->VpiParent())
    if (!p->VpiFile().empty()) return std::string(p->VpiFile());
  return "";
}
int lineVars(const VectorOfvariables* vs, int ln) {
  int n = 0;
  if (vs)
    for (auto* v : *vs)
      if (v && (int)v->VpiLineNo() == ln) n++;
  return n;
}
class L : public VpiListener {
 public:
  bool inStack(UHDM_OBJECT_TYPE t) {
    for (auto* c : callstack)
      if (c && c->UhdmType() == t) return true;
    return false;
  }
  void enterAny(const any* o, vpiHandle h) override {
    auto t = o->UhdmType();
    if (t == uhdmoperation) {
      auto* op = (const operation*)o;
      auto* p = o->VpiParent();
      if (p && p->UhdmType() == uhdmsys_func_call && op->Operands() &&
          op->Operands()->size() == 1 && o->VpiLineNo() > 0 &&
          o->VpiEndLineNo() == o->VpiLineNo() &&
          o->VpiEndColumnNo() == o->VpiColumnNo() + 1 && !inStack(uhdmpart_select))
        hits["SYSUNARY"]++;
      if ((op->VpiOpType() == 71 || op->VpiOpType() == 72) && o->VpiLineNo() > 0) {
        std::string l = lineOf(fileOf(o), o->VpiLineNo());
        int c = o->VpiColumnNo();
        if (c >= 1 && c <= (int)l.size() && l[c - 1] != '{') hits["STREAMBRACE"]++;
      }
      if (op->VpiOpType() == 75 && p && p->UhdmType() == uhdmoperation && inStack(uhdmparam_assign) &&
          o->VpiLineNo() > 0 && p->VpiLineNo() > 0 &&
          (o->VpiLineNo() < p->VpiLineNo() || o->VpiLineNo() > p->VpiEndLineNo()))
        hits["PATOPSPAN"]++;
    }
    if (t == uhdmunsupported_typespec && o->VpiLineNo() > 0 && o->VpiFile().empty())
      hits["FEFILE"]++;
    if (t == uhdmhier_path) {
      auto* hp = (const hier_path*)o;
      auto* p = o->VpiParent();
      bool lhs = p && p->UhdmType() == uhdmassignment && ((const assignment*)p)->Lhs() == hp;
      auto* pe = hp->Path_elems();
      if (lhs && pe && pe->size() >= 2 && pe->back()->UhdmType() == uhdmbit_select) {
        auto* bs = (const bit_select*)pe->back();
        std::string nm(hp->VpiName());
        bool bad = false;
        std::function<void(const any*)> w = [&](const any* e) {
          if (!e) return;
          if (e->UhdmType() == uhdmref_obj) {
            std::string fn(((const ref_obj*)e)->VpiFullName());
            if (fn.find(nm) == std::string::npos) bad = true;
          } else if (e->UhdmType() == uhdmoperation && ((const operation*)e)->Operands())
            for (auto* x : *((const operation*)e)->Operands()) w(x);
        };
        w(bs->VpiIndex());
        if (bad) hits["LVIDX"]++;
        auto* ix = bs->VpiIndex();
        if ((*pe)[0]->UhdmType() == uhdmbit_select && ix && ix->VpiLineNo() > 0 &&
            (bs->VpiLineNo() != ix->VpiLineNo() || bs->VpiColumnNo() != ix->VpiColumnNo()))
          hits["LVTRAIL"]++;
      }
    }
    if (t == uhdmparam_assign) {
      auto* pa = (const param_assign*)o;
      auto* r = pa->Rhs();
      bool inMod = false;
      for (auto* c : callstack)
        if (c && c->UhdmType() == uhdmmodule_inst) inMod = true;
      if (inMod && r && r->UhdmType() == uhdmconstant && r->VpiParent() && r->VpiParent() != pa &&
          r->VpiParent()->UhdmType() == uhdmparam_assign)
        hits["PKGREFMD"]++;
      if (r && r->UhdmType() == uhdmoperation && o->VpiParent() &&
          o->VpiParent()->UhdmType() == uhdmpackage)
        if (auto* rt = ((const operation*)r)->Typespec())
          if (auto* at = rt->Actual_typespec())
            if (at->UhdmType() == uhdminteger_typespec &&
                ((const integer_typespec*)at)->VpiValue().empty() &&
                !((const integer_typespec*)at)->Expr())
              hits["PKGTDCAST"]++;
      if (r && r->UhdmType() == uhdmarray_expr && ((const array_expr*)r)->Exprs()) {
        auto* xs = ((const array_expr*)r)->Exprs();
        if (xs->size() >= 2 && (*xs)[0] != (*xs)[1] && (*xs)[0]->UhdmType() == uhdmconstant &&
            (*xs)[1]->UhdmType() == uhdmconstant &&
            ((const constant*)(*xs)[0])->VpiValue() == ((const constant*)(*xs)[1])->VpiValue())
          hits["DEFFILL"]++;
      }
    }
    if (t == uhdmconstant && o->VpiLineNo() > 0 && o->VpiFile().empty() && o->VpiParent() &&
        o->VpiParent()->UhdmType() == uhdmoperation &&
        ((const operation*)o->VpiParent())->VpiOpType() == 76)
      hits["REPLCNTFILE"]++;
    if (t == uhdmbegin) {
      auto* p = o->VpiParent();
      if (p && (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask)) {
        int ln = o->VpiLineNo();
        int n = lineVars(((const begin*)o)->Variables(), ln) +
                lineVars(((const task_func*)p)->Variables(), ln);
        // ...and that line is the FIRST variable line (the anchor fell on the
        // first declaration's own statement)
        int mn = 1 << 30;
        for (auto* vs : {((const begin*)o)->Variables(), ((const task_func*)p)->Variables()})
          if (vs)
            for (auto* v : *vs)
              if (v && v->VpiLineNo() > 0 && (int)v->VpiLineNo() < mn) mn = v->VpiLineNo();
        if (n >= 2 && ln == mn) hits["MULTIDECL"]++;
      }
    }
  }
};
}  // namespace
int main(int argc, char** argv) {
  if (argc < 2) return 3;
  auto ser = std::make_unique<Serializer>();
  std::vector<vpiHandle> h = ser->Restore(std::string(argv[1]));
  L l;
  l.listenDesigns(h);
  // LHSARRTS over every package / definition module / interface listing
  auto scope = [&](const VectorOfparam_assign* pas, const VectorOfany* params) {
    if (!pas || !params) return;
    std::set<const any*> listed(params->begin(), params->end());
    std::set<const any*> lts;
    for (auto* p0 : *params)
      if (p0 && p0->UhdmType() == uhdmparameter)
        if (auto* rt0 = ((const parameter*)p0)->Typespec())
          if (rt0->Actual_typespec()) lts.insert(rt0->Actual_typespec());
    for (auto* pa : *pas) {
      auto* l = pa ? pa->Lhs() : nullptr;
      if (!l || l->UhdmType() != uhdmparameter || listed.count(l)) continue;
      auto* rt = ((const parameter*)l)->Typespec();
      if (rt && rt->Actual_typespec() && lts.count(rt->Actual_typespec()) &&
          rt->Actual_typespec()->UhdmType() == uhdmarray_typespec)
        hits["LHSARRTS"]++;
    }
  };
  for (auto hd : h) {
    auto* d = (const design*)((uhdm_handle*)hd)->object;
    if (!d) continue;
    for (auto* pv : {d->AllPackages(), d->TopPackages()})
      if (pv) for (auto* pk : *pv) if (pk) scope(pk->Param_assigns(), pk->Parameters());
    if (d->AllModules()) for (auto* m : *d->AllModules()) if (m) scope(m->Param_assigns(), m->Parameters());
    if (d->AllInterfaces()) for (auto* m : *d->AllInterfaces()) if (m) scope(m->Param_assigns(), m->Parameters());
  }
  for (auto& [k, v] : hits) std::cout << k << " " << v << "\n";
  return 0;
}
