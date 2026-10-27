// bind <db>: one line per func_call/task_call/method_func_call/method_task_call:
// call kind, name, line:col, the enclosing top-level owner (package/module + DEF/TOP view),
// and the bound subroutine's owner + view; sorted output for multiset comparison.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <set>
#include <vector>
#include <algorithm>
using namespace UHDM;
static design* D;
static std::string root(const any* o) {
  if (!o) return "null";
  const any* r = o;
  while (r->VpiParent() && r->VpiParent()->UhdmType() != uhdmdesign) r = r->VpiParent();
  for (int t = 0; t < 2; t++) {
    auto* l = t ? D->TopPackages() : D->AllPackages();
    if (l) for (auto* p : *l) if ((const any*)p == r) return std::string(p->VpiName()) + (t ? "#TOP" : "#DEF");
    auto* m = t ? D->TopModules() : D->AllModules();
    if (m) for (auto* p : *m) if ((const any*)p == r) return std::string(p->VpiName()) + (t ? "#TOPM" : "#DEFM");
  }
  if (D->AllClasses()) for (auto* c : *D->AllClasses()) if ((const any*)c == r) return std::string(c->VpiName()) + "#CLS";
  return std::string(UhdmName(r->UhdmType())) + ":" + std::string(r->VpiName());
}
static std::string encl(const any* o) {  // nearest subroutine and class above the call
  std::string s;
  for (const any* p = o->VpiParent(); p; p = p->VpiParent()) {
    auto k = p->UhdmType();
    if (k == uhdmfunction || k == uhdmtask || k == uhdmclass_defn) s += std::string(UhdmName(k)) + ":" + std::string(p->VpiName()) + "/";
  }
  return s;
}
int main(int argc, char** argv) {
  Serializer s; auto h = s.Restore(std::filesystem::path(argv[1]));
  D = (design*)((uhdm_handle*)h[0])->object;
  std::vector<std::string> out;
  for (auto& [o, _] : s.AllObjects()) {
    const any* a = (const any*)o; const any* f = nullptr;
    switch (a->UhdmType()) {
      case uhdmfunc_call: f = ((const func_call*)a)->Function(); break;
      case uhdmtask_call: f = ((const task_call*)a)->Task(); break;
      case uhdmmethod_func_call: f = ((const method_func_call*)a)->Function(); break;
      case uhdmmethod_task_call: f = ((const method_task_call*)a)->Task(); break;
      default: continue;
    }
    out.push_back(std::string(UhdmName(a->UhdmType())) + " " + std::string(a->VpiName()) + "@" + std::to_string(a->VpiLineNo()) + ":" + std::to_string(a->VpiColumnNo()) + " in " + root(a) + " " + encl(a) + " -> " + (f ? std::string(f->VpiName()) + " [" + root(f) + "]" : std::string("null")));
  }
  std::sort(out.begin(), out.end());
  for (auto& l : out) std::cout << l << "\n";
}
