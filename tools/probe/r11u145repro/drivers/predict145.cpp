// predict145 <db.uhdm>: prints one line per r11u145 law whose TRIGGER the (pristine) database carries.
// Wider than the laws on purpose: a mover must be predicted; a predicted database need not move.
#include <uhdm/Serializer.h>
#include <uhdm/VpiListener.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_visitor.h>
#include <iostream>
#include <map>
#include <memory>
#include <string>
#include <vector>
namespace {
std::map<std::string, int> hits;
std::string fnOf(const UHDM::any* o) {
  if (!o) return "";
  vpiHandle h = NewVpiHandle(o); const char* f = vpi_get_str(vpiFullName, h);
  std::string r = f ? f : ""; vpi_release_handle(h); return r;
}
const UHDM::any* inst(const UHDM::any* a) {
  for (; a; a = a->VpiParent())
    if (a->UhdmType() == UHDM::uhdmmodule_inst || a->UhdmType() == UHDM::uhdminterface_inst) return a;
  return nullptr;
}
bool inGen(const UHDM::any* a) {
  for (; a; a = a->VpiParent()) if (a->UhdmType() == UHDM::uhdmgen_scope) return true;
  return false;
}
bool endsWith(const std::string& s, const std::string& t) { return s.size() >= t.size() && s.compare(s.size() - t.size(), t.size(), t) == 0; }
class L : public UHDM::VpiListener {
 public:
  void enterAny(const UHDM::any* o, vpiHandle) override {
    auto t = o->UhdmType(); const UHDM::any* p = o->VpiParent();
    // DEFFILLIMP: an array_expr listing one constant object more than once, the constant parented at it
    if (t == UHDM::uhdmarray_expr) {
      auto* ae = (const UHDM::array_expr*)o;
      if (ae->Exprs() && ae->Exprs()->size() > 1) {
        auto* e0 = (*ae->Exprs())[0]; bool same = true;
        for (auto* e : *ae->Exprs()) if (e != e0) same = false;
        if (same && e0 && e0->VpiParent() == o) hits["DEFFILLIMP"]++;
      }
    }
    // UNSPARAMTS: a scalar bit/logic typespec spanning `bit unsigned` / `logic unsigned` / `reg unsigned` widths
    if ((t == UHDM::uhdmbit_typespec || t == UHDM::uhdmlogic_typespec) && o->VpiLineNo() == o->VpiEndLineNo()) {
      int w = (int)o->VpiEndColumnNo() - (int)o->VpiColumnNo();
      bool noRanges = t == UHDM::uhdmbit_typespec ? !((const UHDM::bit_typespec*)o)->Ranges() || ((const UHDM::bit_typespec*)o)->Ranges()->empty()
                                                   : !((const UHDM::logic_typespec*)o)->Ranges() || ((const UHDM::logic_typespec*)o)->Ranges()->empty();
      if (noRanges && (w == 12 || w == 14)) hits["UNSPARAMTS"]++;
    }
    // PSBAREREF: a ref_obj that is a simple part-select bound, not already named by the select
    if (t == UHDM::uhdmref_obj && p && p->UhdmType() == UHDM::uhdmpart_select) {
      auto* ps = (const UHDM::part_select*)p;
      if (ps->Left_range() == o || ps->Right_range() == o) {
        // every direct bound reference: the law also STORES a name the dump synthesises identically
        // (a byte mover with no dump difference: YosysOldOpen)
        hits["PSBAREREF"]++;
      }
    }
    // UNARYOWN / LPBOUNDOWN: a constant with a ref_typespec under a unary operation / as a select bound, in a
    // generate scope, whose typespec is not named by the enclosing instance
    if (t == UHDM::uhdmconstant && p && ((const UHDM::constant*)o)->Typespec() && inGen(p)) {
      std::string rf = fnOf(((const UHDM::constant*)o)->Typespec());
      std::string inf = fnOf(inst(p));
      if (p->UhdmType() == UHDM::uhdmoperation) {
        int op = ((const UHDM::operation*)p)->VpiOpType();
        if (op >= vpiMinusOp && op <= vpiUnaryXNorOp && rf != inf) hits["UNARYOWN"]++;
      }
      if ((p->UhdmType() == UHDM::uhdmpart_select || p->UhdmType() == UHDM::uhdmindexed_part_select) && rf != inf)
        hits["LPBOUNDOWN"]++;
    }
    // BASESELOP: a hier_path whose first element is a bit_select indexed by an operation holding a ref_obj
    // not named by the path
    if (t == UHDM::uhdmhier_path) {
      auto* hp = (const UHDM::hier_path*)o;
      if (hp->Path_elems() && !hp->Path_elems()->empty()) {
        auto* e0 = (*hp->Path_elems())[0];
        if (e0 && e0->UhdmType() == UHDM::uhdmbit_select) {
          auto* ix = ((const UHDM::bit_select*)e0)->VpiIndex();
          std::vector<const UHDM::any*> st; if (ix && ix->UhdmType() == UHDM::uhdmoperation) st.push_back(ix);
          std::string hn(hp->VpiName());
          while (!st.empty()) { auto* e = st.back(); st.pop_back();
            if (e->UhdmType() == UHDM::uhdmref_obj) { if (fnOf(e).find(hn) == std::string::npos) hits["BASESELOP"]++; }
            else if (e->UhdmType() == UHDM::uhdmoperation && ((const UHDM::operation*)e)->Operands())
              for (auto* x : *((const UHDM::operation*)e)->Operands()) st.push_back(x);
          }
        }
      }
    }
    // IMPARITH: a module-side param_assign whose constant Rhs ends before the param_assign does (left-operand anchor)
    if (t == UHDM::uhdmparam_assign && p && p->UhdmType() == UHDM::uhdmmodule_inst) {
      auto* r = ((const UHDM::param_assign*)o)->Rhs();
      if (r && r->UhdmType() == UHDM::uhdmconstant && r->VpiEndLineNo() == o->VpiEndLineNo() &&
          r->VpiEndColumnNo() < o->VpiEndColumnNo() && r->VpiLineNo() > 0) hits["IMPARITH"]++;
    }
  }
};
}  // namespace
int main(int argc, char** argv) {
  if (argc < 2) return 3;
  auto ser = std::make_unique<UHDM::Serializer>();
  std::vector<vpiHandle> h = ser->Restore(std::string(argv[1]));
  L l; l.listenDesigns(h);
  // PSBAREREF over EVERY serialized object, reachable from the design or not (an unreachable bound reference
  // still serializes its stored name: YosysOldOpen moves in bytes with an identical dump)
  for (auto& [obj, id] : ser->AllObjects()) {
    (void)id;
    auto* o = (const UHDM::any*)obj;
    if (!o) continue;
    if (o->UhdmType() == UHDM::uhdmpart_select) {
      auto* ps = (const UHDM::part_select*)o;
      for (auto* b : {(const UHDM::any*)ps->Left_range(), (const UHDM::any*)ps->Right_range()})
        if (b && b->UhdmType() == UHDM::uhdmref_obj) hits["PSBAREREF_ALLOBJ"]++;
    }
    if (o->UhdmType() == UHDM::uhdmref_obj && o->VpiParent() &&
        o->VpiParent()->UhdmType() == UHDM::uhdmpart_select)
      hits["PSBAREREF_ALLOBJ"]++;
  }
  for (auto& [k, v] : hits) std::cout << k << " " << v << "\n";
  return 0;
}
