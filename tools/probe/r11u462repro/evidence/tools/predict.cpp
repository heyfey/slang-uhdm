// predict <listfile>: for each pristine database path in the list, print the r11u462 law signatures
// found in it (a candidate mover per law), read from the database alone (and, for the automatic
// law, the declaration's source line):
//   CLSINMOD  a class_defn parented at a module or program definition listing a named struct, union,
//             enum or class typedef
//   RETVAR    a task_func's return variable whose typespec aliases an unparented bare-named copy
//   ENUMBASE  an enum_typespec at a definition-view package whose unnamed base is at an elaborated one
//   SYSF      a ref_obj bound to a sys_func_call whose name a design-level parameter carries
//   AUTO      a class task/function without vpiAutomatic whose source header reads `task|function automatic`
#include <uhdm/uhdm.h>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <regex>
#include <set>
#include <map>
using namespace UHDM;
static std::map<std::string, std::vector<std::string>> fileCache;
static std::string lineOf(const std::string& f, int l) {
  auto it = fileCache.find(f);
  if (it == fileCache.end()) {
    std::vector<std::string> v; std::ifstream in(f); std::string s;
    while (std::getline(in, s)) v.push_back(s);
    it = fileCache.emplace(f, std::move(v)).first;
  }
  if (l < 1 || l > (int)it->second.size()) return "";
  return it->second[l - 1];
}
int main(int argc, char** argv) {
  std::ifstream lst(argv[1]); std::string path;
  static const std::regex autoRe(R"(^\s*(task|function)\s+automatic\b)");
  while (std::getline(lst, path)) {
    if (!std::filesystem::exists(path)) continue;
    Serializer s; auto h = s.Restore(std::filesystem::path(path));
    if (h.empty()) continue;
    auto* d = (design*)((uhdm_handle*)h[0])->object;
    std::set<const BaseClass*> defP, topP; std::set<std::string> dparams;
    if (d->AllPackages()) for (auto* p : *d->AllPackages()) defP.insert(p);
    if (d->TopPackages()) for (auto* p : *d->TopPackages()) topP.insert(p);
    if (d->Parameters()) for (auto* p : *d->Parameters()) dparams.insert(std::string(p->VpiName()));
    std::map<std::string, int> n;
    for (auto& kv : s.AllObjects()) {
      auto* o = (const BaseClass*)kv.first; auto k = o->UhdmType();
      if (k == uhdmclass_defn) {
        auto* c = (const class_defn*)o; auto* p = c->VpiParent();
        if (p && (p->UhdmType() == uhdmmodule_inst || p->UhdmType() == uhdmprogram) && c->Typespecs())
          for (auto* t : *c->Typespecs()) {
            auto tk = t->UhdmType();
            if (!t->VpiName().empty() && (tk == uhdmstruct_typespec || tk == uhdmunion_typespec || tk == uhdmenum_typespec || tk == uhdmclass_typespec)) { n["CLSINMOD"]++; break; }
          }
      } else if (k == uhdmenum_typespec) {
        auto* e = (const enum_typespec*)o; auto* br = e->Base_typespec(); auto* b = br ? br->Actual_typespec() : nullptr;
        if (b && e->Instance() && b->Instance() && b->VpiName().empty() && defP.count(e->Instance()) && topP.count(b->Instance()) && !defP.count(b->Instance())) n["ENUMBASE"]++;
      } else if (k == uhdmref_obj) {
        auto* r = (const ref_obj*)o; auto* a = r->Actual_group();
        if (a && a->UhdmType() == uhdmsys_func_call && dparams.count(std::string(r->VpiName()))) n["SYSF"]++;
      } else if (k == uhdmfunction || k == uhdmtask) {
        auto* tf = (const task_func*)o;
        if (k == uhdmfunction) {
          if (auto* rv = tf->Return()) if (auto* rt = rv->Typespec()) if (auto* t = rt->Actual_typespec())
            if (auto* al = t->Typedef_alias()) if (auto* at = al->Actual_typespec())
              if (!at->VpiParent() && at->VpiName().find("::") == std::string_view::npos && !at->VpiName().empty() && rv->VpiParent() != tf) n["RETVAR"]++;
        }
        const BaseClass* p = tf->VpiParent();
        if (p && p->UhdmType() == uhdmclass_defn && !tf->VpiAutomatic()) {
          std::string f(tf->VpiFile()); if (f.empty()) f = std::string(p->VpiFile());
          if (!f.empty() && std::regex_search(lineOf(f, tf->VpiLineNo()), autoRe)) n["AUTO"]++;
        }
      }
    }
    std::cout << path;
    for (auto& [k, v] : n) std::cout << " " << k << "=" << v;
    std::cout << "\n";
  }
}
