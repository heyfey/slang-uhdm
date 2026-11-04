// aliasscan <db>...: the prediction scan for pass 484's laws, read from PRISTINE databases.  Counts
// per database the shapes each law acts on:
//  ALIASLOCAL   a non-ref_var variable under a task_func of a package's definition (all) view or of
//               a module definition whose typespec binds a typedef object carrying a vpiTypedefAlias
//               and named after that same package (P::x) or bare (module)
//  TGTTOP       a typespec with a vpiTypedefAlias, instance a package's top view, whose alias target
//               reads a package definition (all) view
//  MEMBINST     a struct/union listing object (parented at a package or module) with a
//               vpiTypedefAlias at a package's top view whose own member type (parented at the
//               member's reference) reads a package's definition view
//  COPYNAME     a struct/union carrying a vpiTypedefAlias, parented at a ref_typespec inside a task or
//               function whose name is qualified (P::x)
// Prints "DB <path> <law>=<n> ..." for each database with a nonzero count.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
#include <set>
using namespace UHDM;
static const ref_typespec* aliasOf(const typespec* t) {
  switch (t->UhdmType()) {
    case uhdmstruct_typespec: return ((const struct_typespec*)t)->Typedef_alias();
    case uhdmunion_typespec: return ((const union_typespec*)t)->Typedef_alias();
    case uhdmenum_typespec: return ((const enum_typespec*)t)->Typedef_alias();
    case uhdmlogic_typespec: return ((const logic_typespec*)t)->Typedef_alias();
    case uhdmbit_typespec: return ((const bit_typespec*)t)->Typedef_alias();
    case uhdmint_typespec: return ((const int_typespec*)t)->Typedef_alias();
    default: return nullptr;
  }
}
int main(int argc, char** argv) {
  for (int i = 1; i < argc; ++i) {
    Serializer s; auto ds = s.Restore(std::filesystem::path(argv[i]));
    std::set<const any*> top, allp;
    std::map<std::string, const any*> allByName;
    for (auto h : ds) {
      auto* d = (const design*)((uhdm_handle*)h)->object;
      if (d->TopPackages()) for (auto* p : *d->TopPackages()) top.insert(p);
      if (d->AllPackages()) for (auto* p : *d->AllPackages()) { allp.insert(p); allByName[std::string(p->VpiName())] = p; }
    }
    std::map<std::string, int> n;
    for (auto& kv : s.AllObjects()) {
      auto* o = (const any*)kv.first;
      if (auto* v = dynamic_cast<const variables*>(o)) {
        if (o->UhdmType() == uhdmref_var || !v->Typespec() || !v->Typespec()->Actual_typespec()) continue;
        auto* t = v->Typespec()->Actual_typespec();
        if (!aliasOf(t)) continue;
        // the alias LISTING object (parented at its package or module), or a bare copy of one
        auto listed = [](const any* x) { return x && x->VpiParent() && (x->VpiParent()->UhdmType() == uhdmpackage || x->VpiParent()->UhdmType() == uhdmmodule_inst || x->VpiParent()->UhdmType() == uhdminterface_inst); };
        if (!listed(t)) {
          auto* x = aliasOf(t)->Actual_typespec();
          if (!x || !listed(x) || !aliasOf(x)) continue;
        }
        const any* p = o->VpiParent(); const any* tf = nullptr;
        for (int k = 0; p && k < 64; ++k, p = p->VpiParent()) {
          if (!tf && (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask)) tf = p;
          if (p->UhdmType() == uhdmpackage || p->UhdmType() == uhdmmodule_inst || p->UhdmType() == uhdminterface_inst) break;
        }
        if (!tf || !p) continue;
        std::string nm(t->VpiName());
        if (p->UhdmType() == uhdmpackage) {
          if (!allp.count(p) || top.count(p)) continue;
          if (nm.rfind(std::string(p->VpiName()) + "::", 0) != 0) continue;
        } else if (nm.find("::") != std::string::npos) continue;
        n["ALIASLOCAL"]++;
      } else if (auto* t = dynamic_cast<const typespec*>(o)) {
        auto* al = aliasOf(t);
        if (!al || !al->Actual_typespec()) continue;
        auto* x = al->Actual_typespec();
        if (o->VpiParent() && o->VpiParent()->UhdmType() == uhdmpackage &&
            t->Instance() && top.count(t->Instance()) && x->Instance() && allp.count(x->Instance()) && !top.count(x->Instance()))
          n["TGTTOP"]++;
        if ((o->UhdmType() == uhdmstruct_typespec || o->UhdmType() == uhdmunion_typespec) && t->Instance() && top.count(t->Instance())) {
          auto* mm = o->UhdmType() == uhdmstruct_typespec ? ((const struct_typespec*)o)->Members() : ((const union_typespec*)o)->Members();
          if (mm && o->VpiParent() && (o->VpiParent()->UhdmType() == uhdmpackage || o->VpiParent()->UhdmType() == uhdmmodule_inst))
            for (auto* m : *mm) if (m->Typespec() && m->Typespec()->Actual_typespec() && m->Typespec()->Actual_typespec()->VpiParent() == m->Typespec() && m->Typespec()->Actual_typespec()->Instance() && allp.count(m->Typespec()->Actual_typespec()->Instance())) n["MEMBINST"]++;
        }
        if ((o->UhdmType() == uhdmstruct_typespec || o->UhdmType() == uhdmunion_typespec) && o->VpiParent() && o->VpiParent()->UhdmType() == uhdmref_typespec &&
            std::string(o->VpiName()).find("::") != std::string::npos) {
          const any* p = o->VpiParent();
          for (int k = 0; p && k < 64; ++k, p = p->VpiParent()) if (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask) { n["COPYNAME"]++; break; }
        }
      }
    }
    if (n.empty()) continue;
    std::cout << "DB " << argv[i];
    for (auto& [k, c] : n) std::cout << " " << k << "=" << c;
    std::cout << "\n";
  }
}
