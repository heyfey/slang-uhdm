// predict180 — the r11u180 byte-mover predictor, run on PRISTINE databases before a law sweep.
//   predict180 <db.uhdm>...   prints "<db> <LAW,...>" (or "-") per database.
// Each trigger is derived from its law's CONDITION (a superset: it fires wherever the law could
// rewrite an object, whether or not the rewrite changes a byte):
//   ENUMIMP  (§ enumImportParentLastWriter180) an enum_typespec listed in the Typespecs of at least
//            one definition module / interface (AllModules / AllInterfaces) whose vpiParent is not
//            null and whose (rank interface<module, VpiDefName) is not the greatest listing container's, or
//            whose base-type ref full name is `work@...` and differs from `<winner>.<enum name>`;
//            (ENUMIMPHDR when the current parent is not a module / interface: the header-import writer,
//            § enumImportParentLastWriter180's R11U180_ENUMIMPHDR_OFF branch);
//   TPUSE    (§ classTpDefaultTsAtUse180) a class_typespec under a class_defn (not through an io_decl)
//            whose class_defn edge equals the class_defn edge of a class_typespec that types one of
//            that class_defn's type_parameters, and whose name, file or span differs from it;
//   TPFORMAL (§ classTpFormalMovesTs180) the same through an io_decl (a formal) whose span differs;
//   TPCHAIN  (§ classTpChainRootShares180) two type_parameters of one class_defn typed by class_typespecs of
//            one class_defn edge at different spans or names;
//   TPQUAL   (§ classTpQualDefaultSpan180) a class_defn's type_parameter typed by a class_typespec
//            whose name holds `::` or a blank;
//   MODAGGCLONE (§ modAggTfArgCloneFollows180) a struct / union typespec listed by a definition module
//            with another struct / union object of the same name and file at a different span;
//   PKGAGGCLONE (§ pkgAggTfArgCloneFollows180) a struct / union typespec a package lists with another
//            struct / union object of the same name at a different span;
//   PORTINTREDECL (§ splitPortIntRedeclLogicTs180) a port typed by a predefined integer typespec whose
//            low conn binds an object declared on another line (a body re-declaration);
//   IFACETDORDER (§ ifaceWildcardTdNameOrder180) a definition interface whose Typespecs list holds
//            two `pkg::name` entries of one package out of name order.
// build: drivers/cc180.sh.  Fail-closed fence: the caller (predict180.sh) never passes a fenced
// database.
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_user.h>
#include <iostream>
#include <map>
#include <set>
#include <string>
using namespace UHDM;
static bool sameSpan(const BaseClass* a, const BaseClass* b) {
  return a->VpiFile() == b->VpiFile() && a->VpiLineNo() == b->VpiLineNo() &&
         a->VpiColumnNo() == b->VpiColumnNo() && a->VpiEndLineNo() == b->VpiEndLineNo() &&
         a->VpiEndColumnNo() == b->VpiEndColumnNo();
}
int main(int argc, char** argv) {
  for (int ai = 1; ai < argc; ai++) {
    Serializer s; auto designs = s.Restore(std::string(argv[ai]));
    std::set<std::string> laws;
    for (auto& kv : s.AllObjects()) if (kv.first && kv.first->UhdmType() == uhdmdesign) {
      auto* d = (const design*)kv.first;
      // ENUMIMP
      std::map<const typespec*, std::pair<std::pair<int, std::string>, const BaseClass*>> win;
      auto note = [&](const BaseClass* c, int rank, const VectorOftypespec* v) {
        if (!v) return;
        for (auto* t : *v) if (t && t->UhdmType() == uhdmenum_typespec) {
          auto key = std::make_pair(rank, std::string(c->VpiDefName()));
          auto it = win.find(t);
          if (it == win.end() || key >= it->second.first) win[t] = {key, c}; } };
      if (d->AllInterfaces()) for (auto* i : *d->AllInterfaces()) note(i, 0, i->Typespecs());
      if (d->AllModules()) for (auto* m : *d->AllModules()) note(m, 1, m->Typespecs());
      for (auto& [t, w] : win) {
        if (!t->VpiParent()) continue;
        {
          auto pt = t->VpiParent()->UhdmType();
          bool modPar = pt == uhdmmodule_inst || pt == uhdminterface_inst;
          // the parent may be the definition or an elaborated instance of it: compare the key
          if (!modPar) { laws.insert("ENUMIMPHDR"); continue; }
          auto pk = std::make_pair(pt == uhdminterface_inst ? 0 : 1, std::string(t->VpiParent()->VpiDefName()));
          if (pk != w.first) { laws.insert("ENUMIMP"); continue; } }
        auto* et = (const enum_typespec*)t;
        if (auto* b = et->Base_typespec()) {
          std::string fn(b->VpiFullName());
          if (fn.rfind("work@", 0) == 0 && fn != w.first.second + "." + std::string(t->VpiName()))
            laws.insert("ENUMIMP"); } }
      // MODAGGCLONE
      std::set<const BaseClass*> modAgg;
      if (d->AllModules()) for (auto* m : *d->AllModules()) if (m->Typespecs())
        for (auto* t : *m->Typespecs()) if (t && (t->UhdmType() == uhdmstruct_typespec || t->UhdmType() == uhdmunion_typespec) && !t->VpiName().empty())
          modAgg.insert(t);
      if (!modAgg.empty())
        for (auto& kv2 : s.AllObjects()) { const BaseClass* o = kv2.first;
          if (!o || (o->UhdmType() != uhdmstruct_typespec && o->UhdmType() != uhdmunion_typespec) || modAgg.count(o)) continue;
          for (auto* l : modAgg) if (l->UhdmType() == o->UhdmType() && l->VpiName() == o->VpiName() && l->VpiFile() == o->VpiFile() && !sameSpan(l, o)) { laws.insert("MODAGGCLONE"); break; } }
      // PKGAGGCLONE: a package listing struct / union typedef with another object of its name at another span
      {
        std::set<const BaseClass*> pk;
        auto addP = [&](const VectorOfpackage* v) { if (v) for (auto* p : *v) if (p->Typespecs())
          for (auto* t : *p->Typespecs()) if (t && (t->UhdmType() == uhdmstruct_typespec || t->UhdmType() == uhdmunion_typespec) && !t->VpiName().empty()) pk.insert(t); };
        addP(d->TopPackages()); addP(d->AllPackages());
        if (!pk.empty())
          for (auto& kv2 : s.AllObjects()) { const BaseClass* o = kv2.first;
            if (!o || (o->UhdmType() != uhdmstruct_typespec && o->UhdmType() != uhdmunion_typespec) || pk.count(o)) continue;
            for (auto* l : pk) if (l->UhdmType() == o->UhdmType() && l->VpiName() == o->VpiName() && !sameSpan(l, o)) { laws.insert("PKGAGGCLONE"); break; } }
      }
      // IFACETDORDER
      if (d->AllInterfaces()) for (auto* i : *d->AllInterfaces()) if (i->Typespecs()) {
        std::map<std::string, std::string> last;
        for (auto* t : *i->Typespecs()) { if (!t) continue; std::string n(t->VpiName()); auto q = n.find("::"); if (q == std::string::npos) continue;
          std::string pk = n.substr(0, q), rest = n.substr(q + 2);
          auto it = last.find(pk); if (it != last.end() && rest < it->second) laws.insert("IFACETDORDER");
          last[pk] = rest; } }
    }
    // PORTINTREDECL: a port typed by a predefined integer typespec on another line than the object its low conn binds
    for (auto& kv : s.AllObjects()) { const BaseClass* o = kv.first;
      if (!o || o->UhdmType() != uhdmport) continue;
      auto* pt = (const port*)o; auto* rt = pt->Typespec(); if (!rt) continue;
      auto* a = rt->Actual_typespec(); if (!a) continue;
      auto at = a->UhdmType();
      if (at != uhdminteger_typespec && at != uhdmint_typespec && at != uhdmtime_typespec && at != uhdmbyte_typespec &&
          at != uhdmshort_int_typespec && at != uhdmlong_int_typespec) continue;
      const any* lc = pt->Low_conn(); if (!lc || lc->UhdmType() != uhdmref_obj) continue;
      const any* act = ((const ref_obj*)lc)->Actual_group(); if (!act) continue;
      if (act->VpiLineNo() != a->VpiLineNo()) laws.insert("PORTINTREDECL"); }
    // TPUSE / TPFORMAL / TPQUAL
    std::map<const BaseClass*, std::vector<const class_typespec*>> tpOwn;  // class_defn -> TP own typespecs
    for (auto& kv : s.AllObjects()) { const BaseClass* o = kv.first;
      if (!o || o->UhdmType() != uhdmtype_parameter) continue;
      const BaseClass* cd = o->VpiParent(); if (!cd || cd->UhdmType() != uhdmclass_defn) continue;
      auto* tp = (const type_parameter*)o; auto* rt = tp->Typespec(); if (!rt) continue;
      auto* a = rt->Actual_typespec(); if (!a || a->UhdmType() != uhdmclass_typespec) continue;
      for (auto* o2 : tpOwn[cd])
        if (o2->Class_defn() == ((const class_typespec*)a)->Class_defn() && (!sameSpan(o2, a) || o2->VpiName() != a->VpiName()))
          laws.insert("TPCHAIN");
      tpOwn[cd].push_back((const class_typespec*)a);
      std::string n(a->VpiName());
      if (n.find("::") != std::string::npos || n.find(' ') != std::string::npos) laws.insert("TPQUAL"); }
    // an unparented typespec is reached through the ref_typespec(s) naming it
    std::map<const BaseClass*, std::vector<const BaseClass*>> refOf;
    if (!tpOwn.empty())
      for (auto& kv : s.AllObjects()) if (kv.first && kv.first->UhdmType() == uhdmref_typespec)
        if (auto* a = ((const ref_typespec*)kv.first)->Actual_typespec()) refOf[a].push_back(kv.first);
    if (!tpOwn.empty())
      for (auto& kv : s.AllObjects()) { const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdmclass_typespec) continue;
        std::vector<const BaseClass*> starts;
        if (o->VpiParent()) starts.push_back(o->VpiParent());
        else if (auto it0 = refOf.find(o); it0 != refOf.end()) starts = it0->second;
        for (const BaseClass* st : starts) {
        const BaseClass* cd = nullptr; bool formal = false;
        for (const BaseClass* a = st; a; a = a->VpiParent()) {
          if (a->UhdmType() == uhdmio_decl) formal = true;
          if (a->UhdmType() == uhdmtype_parameter) { cd = nullptr; break; }
          if (a->UhdmType() == uhdmclass_defn) { cd = a; break; }
          if (a->UhdmType() == uhdmpackage || a->UhdmType() == uhdmmodule_inst || a->UhdmType() == uhdmdesign) break; }
        if (!cd) continue;
        auto it = tpOwn.find(cd); if (it == tpOwn.end()) continue;
        auto* ct = (const class_typespec*)o;
        for (auto* own : it->second) {
          if (own == ct || own->Class_defn() != ct->Class_defn()) continue;
          if (formal) { if (!sameSpan(own, ct)) laws.insert("TPFORMAL"); }
          else if (!sameSpan(own, ct) || own->VpiName() != ct->VpiName()) laws.insert("TPUSE"); } } }
    std::string out;
    for (auto& l : laws) out += (out.empty() ? "" : ",") + l;
    std::cout << argv[ai] << " " << (out.empty() ? "-" : out) << "\n";
  }
  return 0;
}
