// r11u121 castdump: every cast operation (vpiCastOp) of a UHDM database as one row:
//   CAST <span> in <parent chain kinds> -> <actual typespec kind>(<name>) @<span> refs=<n ref_typespecs sharing it> [ranges]
// plus, for every constant, typespec-less "SHARE" rows are not printed. Sorted multiset.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <algorithm>
#include <filesystem>
#include <iostream>
#include <map>
#include <string>
#include <vector>
using namespace UHDM;
static std::string sp(const BaseClass* o) {
  return std::to_string(o->VpiLineNo()) + "." + std::to_string(o->VpiColumnNo()) + "-" +
         std::to_string(o->VpiEndLineNo()) + "." + std::to_string(o->VpiEndColumnNo());
}
static std::string chain(const BaseClass* o) {
  std::string s; int d = 0;
  for (const BaseClass* p = o->VpiParent(); p && d < 5; p = p->VpiParent(), d++)
    s += std::string(d ? "<" : "") + std::string(UhdmName(p->UhdmType()));
  return s;
}
int main(int argc, char** argv) {
  Serializer s;
  s.Restore(std::filesystem::path(argv[1]));
  std::map<const BaseClass*, int> refs;
  std::map<const BaseClass*, std::vector<std::string>> users;
  for (auto& [obj, id] : s.AllObjects()) {
    if (!obj || obj->UhdmType() != uhdmref_typespec) continue;
    auto rt = (const ref_typespec*)obj;
    if (rt->Actual_typespec()) {
      refs[rt->Actual_typespec()]++;
      const BaseClass* p = rt->VpiParent();
      users[rt->Actual_typespec()].push_back(p ? std::string(UhdmName(p->UhdmType())) + "(" + std::string(p->VpiName()) + ")" : "-");
    }
  }
  std::vector<std::string> rows;
  for (auto& [obj, id] : s.AllObjects()) {
    if (!obj || obj->UhdmType() != uhdmoperation) continue;
    auto op = (const operation*)obj;
    if (op->VpiOpType() != vpiCastOp) continue;
    std::string r = "CAST " + sp(op) + " in " + chain(op) + " -> ";
    const typespec* t = op->Typespec() ? op->Typespec()->Actual_typespec() : nullptr;
    if (!t) r += "<none>";
    else {
      r += std::string(UhdmName(t->UhdmType())) + "(" + std::string(t->VpiName()) + ")@" + sp(t) +
           " refs=" + std::to_string(refs[t]);
      if (t->UhdmType() == uhdmlogic_typespec) {
        auto lt = (const logic_typespec*)t;
        r += " ranges=" + std::to_string(lt->Ranges() ? lt->Ranges()->size() : 0);
      }
      if (t->UhdmType() == uhdminteger_typespec)
        r += " val=" + std::string(((const integer_typespec*)t)->VpiValue()) + (((const integer_typespec*)t)->Expr() ? " expr" : "");
      std::vector<std::string> u = users[t];
      std::sort(u.begin(), u.end());
      u.erase(std::unique(u.begin(), u.end()), u.end());
      r += " users=";
      for (auto& x : u) r += x + ",";
    }
    rows.push_back(r);
  }
  std::sort(rows.begin(), rows.end());
  for (auto& r : rows) std::cout << r << "\n";
}
