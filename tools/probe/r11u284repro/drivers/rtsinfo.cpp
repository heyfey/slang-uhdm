// r11u284 rtsinfo <db.uhdm> <regex>: every ref_typespec the listener reaches (each once) whose full name matches
// <regex>: its UhdmId, the full name the getter returns, the name UHDM's ComputeFullName would give from the parent
// chain now (re-implemented: the member is protected), STORED when the two differ, and the parent chain
// (id:type:name).  A decode aid only; it opens the one database it is given and refuses a fenced path (fail-closed).
#include <uhdm/uhdm.h>
#include <uhdm/VpiListener.h>
#include <uhdm/vpi_visitor.h>
#include <iostream>
#include <regex>
#include <set>
#include <cstdlib>
#include <vector>
using namespace UHDM;
static std::string chainName(const BaseClass* self) {
  std::vector<std::string> names; const BaseClass* parent = self; const BaseClass* child = nullptr; bool column = false;
  while (parent) {
    const BaseClass* ap = parent->VpiParent();
    auto pt = parent->UhdmType(); auto apt = ap ? ap->UhdmType() : uhdmunsupported_stmt;
    if (pt == uhdmdesign) break;
    if (pt == uhdmpackage || pt == uhdmclass_defn) column = true;
    std::string name(parent->VpiName().empty() ? parent->VpiDefName() : parent->VpiName());
    bool skip = apt == uhdmref_obj || pt == uhdmmethod_func_call || pt == uhdmmethod_task_call || pt == uhdmfunc_call ||
                pt == uhdmtask_call || pt == uhdmsys_func_call || pt == uhdmsys_task_call;
    if (child) { auto ct = child->UhdmType();
      if ((ct == uhdmbit_select && pt == uhdmport) || (ct == uhdmref_obj && (pt == uhdmbit_select || pt == uhdmindexed_part_select || pt == uhdmhier_path))) skip = true; }
    if (!name.empty() && !skip) names.push_back(name);
    child = parent; parent = parent->VpiParent();
  }
  std::string f; for (int i = (int)names.size() - 1; i >= 0; --i) { f += names[i]; if (i) f += column ? "::" : "."; }
  return f;
}
struct L : VpiListener {
  std::regex re; std::set<const any*> seen;
  void enterAny(const any* o, vpiHandle) override {
    if (!seen.insert(o).second) return;
    auto* m = dynamic_cast<const ref_typespec*>(o); if (!m) return;
    std::string comp = chainName(o); std::string got(m->VpiFullName());
    if (getenv("CONSTONLY")) {  // only a constant's own reference: the constant's decompile, line:col, the name
      auto* c = dynamic_cast<const constant*>(o->VpiParent());
      if (!c || c->Typespec() != m) return;
      std::cout << "CONST " << c->VpiDecompile() << " @" << c->VpiLineNo() << ":" << c->VpiColumnNo()
                << " full=" << got << (got != comp ? " STORED" : "") << "\n";
      return;
    }
    if (getenv("ALIASONLY")) {  // only a package-named typespec's own Typedef_alias / Elem_typespec reference
      auto* pt = dynamic_cast<const typespec*>(o->VpiParent());
      if (!pt || pt->VpiName().find("::") == std::string_view::npos) return;
      std::string role = "other";
      if (pt->Typedef_alias() == m) role = "alias";
      if (auto* lt = dynamic_cast<const logic_typespec*>(pt); lt && lt->Elem_typespec() == m) role = "elem";
      if (auto* lt = dynamic_cast<const packed_array_typespec*>(pt); lt && lt->Elem_typespec() == m) role = "elem";
      if (auto* lt = dynamic_cast<const array_typespec*>(pt); lt && lt->Elem_typespec() == m) role = "elem";
      const any* gp = pt->VpiParent();
      std::cout << "ROLE " << role << " " << UhdmName(pt->UhdmType()) << ":" << pt->VpiName() << " listing-parent="
                << (gp ? std::string(UhdmName(gp->UhdmType())) + ":" + std::string(gp->VpiName()) : "none")
                << " full=" << got << (got != comp ? " STORED" : "") << "\n";
      return;
    }
    if (!std::regex_search(got, re)) return;
    std::cout << "#" << o->UhdmId() << " full=" << got << (got != comp ? " STORED(chain=" + comp + ")" : " (=chain)")
              << " actual=" << (m->Actual_typespec() ? std::string(UhdmName(m->Actual_typespec()->UhdmType())) + ":" + std::string(m->Actual_typespec()->VpiName()) : "-")
              << "\n   parents:";
    for (const any* p = o->VpiParent(); p; p = p->VpiParent())
      std::cout << " #" << p->UhdmId() << ":" << UhdmName(p->UhdmType()) << ":" << p->VpiName();
    std::cout << "\n";
  }
};
int main(int argc, char** argv) {
  if (argc < 3) return 2;
  const char* fz = getenv("FENCED");
  if (!fz) { std::cerr << "rtsinfo: FENCED unset\n"; return 2; }
  std::vector<std::string> fn; { std::string w; for (const char* c = fz;; ++c) { if (!*c || *c == ' ') { if (!w.empty()) fn.push_back(w); w.clear(); if (!*c) break; } else w += *c; } }
  if (fn.size() != 4) { std::cerr << "rtsinfo: FENCED not 4 names\n"; return 2; }
  for (auto& f : fn) if (std::regex_search(std::string(argv[1]), std::regex("(^|[^A-Za-z0-9_])" + f + "([^A-Za-z0-9_]|$)"))) { std::cerr << "rtsinfo: fenced path refused\n"; return 2; }
  Serializer s; std::vector<vpiHandle> designs = s.Restore(std::string(argv[1]));
  L l; l.re = std::regex(argv[2]);
  l.listenDesigns(designs);
  return 0;
}
