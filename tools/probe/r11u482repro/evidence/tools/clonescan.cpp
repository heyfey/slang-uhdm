// clonescan <db>...: the prediction scan for pass 482's laws, read from PRISTINE databases.  An
// import clone is a task or function whose span lies outside its enclosing package's span (the
// clone keeps the home body's location).  Per database, counts the shapes each law acts on:
//  TFVARPARENT  a clone's Variables entry parented at a begin of the clone that does not list it
//  COPYINST     a struct/union/enum named P::x owned by a ref_typespec in a clone whose instance is
//               not the top view of P (and each instance-carrying non-array member type of it)
//  ARRELEMCOPY  an array_typespec in a clone whose element binds a struct/union it does not own,
//               every member typed by an unnamed keyword type
//  CLONEFIXAGG  a fixed array local of a clone whose element typespec is logic/bit over a NAME
//  IDXCHAIN     a clone hier_path element with no name (or '[...') and no actual after a bound
//               bit_select
//  MEMBCHAIN    a clone hier_path element with no actual after an element bound to a struct or
//               union member whose type has a member of that name
// Prints "DB <path> <law>=<n> ..." for each database with a nonzero count, and a total line.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <map>
#include <set>
#include <vector>
using namespace UHDM;
static std::map<std::string, std::vector<std::string>> cache;
static std::string tokenAt(const std::string& f, int l, int c) {
  auto it = cache.find(f);
  if (it == cache.end()) {
    std::vector<std::string> lines; std::ifstream in(f); std::string s;
    while (std::getline(in, s)) lines.push_back(s);
    it = cache.emplace(f, lines).first;
  }
  if (l < 1 || l > (int)it->second.size()) return "?";
  const std::string& s = it->second[l - 1];
  if (c < 1 || c > (int)s.size()) return "?";
  size_t b = c - 1, e = b;
  while (e < s.size() && (isalnum((unsigned char)s[e]) || s[e] == '_' || s[e] == ':' || s[e] == '$')) ++e;
  return s.substr(b, e - b);
}
int main(int argc, char** argv) {
  std::map<std::string, long> tot;
  for (int ai = 1; ai < argc; ++ai) {
    Serializer s; auto ds = s.Restore(std::filesystem::path(argv[ai]));
    std::map<std::string, const any*> topPkg;
    for (auto h : ds) {
      auto* d = (const design*)((uhdm_handle*)h)->object;
      if (d->TopPackages()) for (auto* p : *d->TopPackages()) topPkg[std::string(p->VpiName())] = p;
    }
    auto pkgOf = [](const any* o) -> const any* {
      for (; o; o = o->VpiParent()) if (o->UhdmType() == uhdmpackage) return o;
      return nullptr;
    };
    std::map<const any*, bool> cloneMemo;
    auto isClone = [&](const any* tf) -> bool {
      auto it = cloneMemo.find(tf);
      if (it != cloneMemo.end()) return it->second;
      bool c = false;
      if (auto* p = pkgOf(tf->VpiParent()))
        c = tf->VpiLineNo() && (tf->VpiFile() != p->VpiFile() || tf->VpiLineNo() < p->VpiLineNo() ||
                                tf->VpiLineNo() > p->VpiEndLineNo());
      return cloneMemo[tf] = c;
    };
    auto ownerTf = [](const any* o) -> const any* {
      for (int k = 0; o && k < 512; ++k, o = o->VpiParent())
        if (o->UhdmType() == uhdmfunction || o->UhdmType() == uhdmtask) return o;
      return nullptr;
    };
    auto inClone = [&](const any* o) { auto* t = ownerTf(o); return t && isClone(t); };
    auto agg = [](const any* t) {
      return t && (t->UhdmType() == uhdmstruct_typespec || t->UhdmType() == uhdmunion_typespec ||
                   t->UhdmType() == uhdmenum_typespec);
    };
    std::map<std::string, long> n;
    std::set<const any*> roots;
    for (auto& kv : s.AllObjects()) {
      auto* o = (const any*)kv.first;
      auto k = o->UhdmType();
      if ((k == uhdmfunction || k == uhdmtask) && isClone(o)) {
        auto* tf = (const task_func*)o;
        if (tf->Variables())
          for (auto* v : *tf->Variables()) {
            auto* pb = v->VpiParent();
            if (!pb || pb == o || pb->UhdmType() != uhdmbegin || ownerTf(pb) != o) continue;
            bool listed = false;
            if (auto* bv = ((const begin*)pb)->Variables()) for (auto* w : *bv) if (w == v) listed = true;
            if (!listed) n["TFVARPARENT"]++;
          }
      }
      if (agg(o) && o->VpiParent() && o->VpiParent()->UhdmType() == uhdmref_typespec &&
          ((const ref_typespec*)o->VpiParent())->Actual_typespec() == o && inClone(o)) {
        std::string nm(o->VpiName());
        auto c = nm.find("::");
        if (c != std::string::npos) {
          auto tp = topPkg.find(nm.substr(0, c));
          if (tp != topPkg.end()) {
            roots.insert(o);
            if (((const typespec*)o)->Instance() != tp->second) n["COPYINST"]++;
          }
        }
      }
      if (k == uhdmarray_typespec && inClone(o)) {
        auto* er = ((const array_typespec*)o)->Elem_typespec();
        auto* ea = er ? er->Actual_typespec() : nullptr;
        if (ea && ea->VpiParent() != er && std::string(ea->VpiName()).find("::") != std::string::npos &&
            (ea->UhdmType() == uhdmstruct_typespec || ea->UhdmType() == uhdmunion_typespec)) {
          const VectorOftypespec_member* mm = ea->UhdmType() == uhdmstruct_typespec
                                                  ? ((const struct_typespec*)ea)->Members()
                                                  : ((const union_typespec*)ea)->Members();
          bool plain = mm != nullptr;
          if (mm) for (auto* m : *mm) {
            auto* t = m->Typespec() ? m->Typespec()->Actual_typespec() : nullptr;
            if (!t || !t->VpiName().empty() || agg(t) || t->UhdmType() == uhdmclass_typespec) plain = false;
          }
          if (plain) n["ARRELEMCOPY"]++;
        }
      }
      if (k == uhdmarray_var && inClone(o)) {
        auto* av = (const array_var*)o;
        if (av->VpiArrayType() == vpiStaticArray && av->Variables() && !av->Variables()->empty()) {
          auto* v = (*av->Variables())[0];
          const ref_typespec* rt = nullptr;
          if (auto* vv = dynamic_cast<const variables*>(v)) rt = vv->Typespec();
          auto* t = rt ? rt->Actual_typespec() : nullptr;
          if (t && (t->UhdmType() == uhdmlogic_typespec || t->UhdmType() == uhdmbit_typespec)) {
            std::string tok = tokenAt(std::string(t->VpiFile()), t->VpiLineNo(), t->VpiColumnNo());
            if (!(tok == "logic" || tok == "reg" || tok == "bit" || tok == "wire" || tok == "?" || tok.empty()))
              n["CLONEFIXAGG"]++;
          }
        }
      }
      if (k == uhdmhier_path && inClone(o)) {
        auto* pe = ((const hier_path*)o)->Path_elems();
        if (pe)
          for (size_t i = 1; i < pe->size(); ++i) {
            auto* prev = any_cast<const ref_obj*>((*pe)[i - 1]);
            auto* cur = any_cast<const ref_obj*>((*pe)[i]);
            if (!prev || !cur || cur->Actual_group() || !prev->Actual_group()) continue;
            std::string_view nm = cur->VpiName();
            if ((nm.empty() || nm.front() == '[') && prev->UhdmType() == uhdmbit_select) n["IDXCHAIN"]++;
            else if (!nm.empty() && prev->Actual_group()->UhdmType() == uhdmtypespec_member) {
              auto* pm = (const typespec_member*)prev->Actual_group();
              const typespec* mt = pm->Typespec() ? pm->Typespec()->Actual_typespec() : nullptr;
              if (mt && mt->UhdmType() == uhdmarray_typespec) {
                auto* e = ((const array_typespec*)mt)->Elem_typespec(); mt = e ? e->Actual_typespec() : nullptr;
              } else if (mt && mt->UhdmType() == uhdmpacked_array_typespec) {
                auto* e = ((const packed_array_typespec*)mt)->Elem_typespec(); mt = e ? e->Actual_typespec() : nullptr;
              }
              const VectorOftypespec_member* mm = nullptr;
              if (mt && mt->UhdmType() == uhdmstruct_typespec) mm = ((const struct_typespec*)mt)->Members();
              if (mt && mt->UhdmType() == uhdmunion_typespec) mm = ((const union_typespec*)mt)->Members();
              if (mm) for (auto* m : *mm) if (m->VpiName() == nm) { n["MEMBCHAIN"]++; break; }
            }
          }
      }
    }
    for (auto& kv : s.AllObjects()) {
      auto* t = dynamic_cast<const typespec*>((const any*)kv.first);
      if (!t || !t->Instance() || t->UhdmType() == uhdmarray_typespec) continue;
      auto* pr = t->VpiParent();
      if (!pr || pr->UhdmType() != uhdmref_typespec || ((const ref_typespec*)pr)->Actual_typespec() != t) continue;
      auto* pm = pr->VpiParent();
      if (!pm || pm->UhdmType() != uhdmtypespec_member || !roots.count(pm->VpiParent())) continue;
      std::string nm(pm->VpiParent()->VpiName());
      auto tp = topPkg.find(nm.substr(0, nm.find("::")));
      if (tp != topPkg.end() && t->Instance() != tp->second) n["COPYINST_member"]++;
    }
    if (!n.empty()) {
      std::cout << "DB " << argv[ai];
      for (auto& [k, v] : n) { std::cout << " " << k << "=" << v; tot[k] += v; }
      std::cout << "\n";
    }
  }
  std::cout << "TOTAL";
  for (auto& [k, v] : tot) std::cout << " " << k << "=" << v;
  std::cout << "\n";
}
