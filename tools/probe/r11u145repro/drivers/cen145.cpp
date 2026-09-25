// cen145: census of listener-walk objects (measurement only, r11u145).
//   psb  : every ref_obj that is a part_select / indexed_part_select bound:
//          role, name, stored/computed full name, the select's full name, actual kind, 5 ancestors
//   rtc  : every ref_typespec whose parent is a constant: full name, constant span, 6 ancestors
#include <uhdm/Serializer.h>
#include <uhdm/VpiListener.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_visitor.h>
#include <iostream>
#include <memory>
#include <string>
#include <vector>
namespace {
std::string mode;
std::string sp(const UHDM::any* o) {
  return std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo()) + "-" +
         std::to_string(o->VpiEndLineNo()) + ":" + std::to_string(o->VpiEndColumnNo());
}
std::string tn(const UHDM::any* o) {
  if (!o) return "NULL";
  std::string s = UHDM::UhdmName(o->UhdmType());
  if (!o->VpiName().empty()) s += "(" + std::string(o->VpiName()) + ")";
  return s;
}
std::string fn(const UHDM::any* o) {
  vpiHandle h = NewVpiHandle(o);
  const char* f = vpi_get_str(vpiFullName, h);
  std::string r = f ? f : "";
  vpi_release_handle(h);
  return r;
}
class L : public UHDM::VpiListener {
 public:
  std::string ctx(int k) {
    std::string c;
    for (int i = (int)callstack.size() - 1, n = 0; i >= 0 && n < k; --i, ++n)
      c += std::string(n ? "<" : "") + tn(callstack[i]);
    return c;
  }
  void enterAny(const UHDM::any* o, vpiHandle) override {
    const UHDM::any* p = o->VpiParent();
    if (mode == "psb" && o->UhdmType() == UHDM::uhdmref_obj && p &&
        (p->UhdmType() == UHDM::uhdmpart_select || p->UhdmType() == UHDM::uhdmindexed_part_select)) {
      std::string role = "?";
      if (p->UhdmType() == UHDM::uhdmpart_select) {
        auto* ps = (const UHDM::part_select*)p;
        if (ps->Left_range() == o) role = "L"; else if (ps->Right_range() == o) role = "R";
      } else {
        auto* ps = (const UHDM::indexed_part_select*)p;
        if (ps->Base_expr() == o) role = "B"; else if (ps->Width_expr() == o) role = "W";
      }
      auto* ro = (const UHDM::ref_obj*)o;
      std::string ak = ro->Actual_group() ? UHDM::UhdmName(ro->Actual_group()->UhdmType()) : "none";
      std::cout << "psb\t" << UHDM::UhdmName(p->UhdmType()) << "\t" << role << "\t" << o->VpiName() << "\t" << fn(o)
                << "\t" << fn(p) << "\t" << ak << "\t" << sp(o) << "\t" << ctx(6) << "\n";
    }
    if (mode == "hpx" && o->UhdmType() == UHDM::uhdmref_obj) {
      // a ref under (operation*) under a select that is an element of a hier_path
      std::string chainT; const UHDM::any* sel = nullptr; int n = (int)callstack.size();
      for (int i = n - 1, k = 0; i >= 0 && k < 5; --i, ++k) {
        const UHDM::any* a = callstack[i];
        auto t = a->UhdmType();
        if (t == UHDM::uhdmoperation) { chainT += "op<"; continue; }
        if ((t == UHDM::uhdmbit_select || t == UHDM::uhdmpart_select || t == UHDM::uhdmindexed_part_select) &&
            i > 0 && callstack[i - 1]->UhdmType() == UHDM::uhdmhier_path) {
          sel = a;
          auto* hp = (const UHDM::hier_path*)callstack[i - 1];
          int idx = -1, j = 0;
          if (hp->Path_elems()) for (auto* e : *hp->Path_elems()) { if (e == a) idx = j; ++j; }
          std::cout << "hpx\t" << chainT << UHDM::UhdmName(t) << "\t" << idx << "/" << j << "\t" << o->VpiName() << "\t"
                    << fn(o) << "\t" << fn(callstack[i - 1]) << "\t" << sp(o) << "\t" << ctx(8) << "\n";
          break;
        }
        break;
      }
    }
    if (mode == "rtw" && o->UhdmType() == UHDM::uhdmref_typespec && !callstack.empty() &&
        callstack.back()->UhdmType() == UHDM::uhdmconstant) {
      const UHDM::any* c = callstack.back();
      const UHDM::any* cp = c->VpiParent();
      std::string par = p == c ? "own" : (p ? tn(p) : "NULL");
      if (p && p != c && p->VpiParent()) par += "<" + tn(p->VpiParent());
      std::cout << "rtw\t" << fn(o) << "\t" << par << "\t" << (cp ? tn(cp) : "none") << "\t" << sp(c) << "\t" << ctx(6) << "\n";
    }
    if (mode == "rtc" && o->UhdmType() == UHDM::uhdmref_typespec && p && p->UhdmType() == UHDM::uhdmconstant) {
      const UHDM::any* pp = p->VpiParent();
      const UHDM::any* mi = p;
      while (mi && mi->UhdmType() != UHDM::uhdmmodule_inst && mi->UhdmType() != UHDM::uhdminterface_inst &&
             mi->UhdmType() != UHDM::uhdmpackage && mi->UhdmType() != UHDM::uhdmdesign)
        mi = mi->VpiParent();
      std::string role = "-";
      if (pp && pp->UhdmType() == UHDM::uhdmpart_select) {
        auto* ps = (const UHDM::part_select*)pp;
        role = ps->Left_range() == p ? "L" : ps->Right_range() == p ? "R" : "?";
      } else if (pp && pp->UhdmType() == UHDM::uhdmindexed_part_select) {
        auto* ps = (const UHDM::indexed_part_select*)pp;
        role = ps->Base_expr() == p ? "B" : ps->Width_expr() == p ? "W" : "?";
      } else if (pp && pp->UhdmType() == UHDM::uhdmbit_select) role = "I";
      std::cout << "rtc\t" << fn(o) << "\t" << (pp ? UHDM::UhdmName(pp->UhdmType()) : "none") << "\t" << role
                << "\t" << (pp ? fn(pp) : "") << "\t" << (mi ? fn(mi) : "") << "\t" << sp(p) << "\t" << ctx(7) << "\n";
    }
  }
};
}  // namespace
int main(int argc, char** argv) {
  if (argc < 3) return 3;
  mode = argv[1];
  auto ser = std::make_unique<UHDM::Serializer>();
  std::vector<vpiHandle> h = ser->Restore(std::string(argv[2]));
  L l;
  l.listenDesigns(h);
  return 0;
}
