// predict178 — r11u178's byte-mover predictor for the three landed r11u175 ground-A laws (predict175 minus FSPAN,
// MULT widened to every declaration inside a clone body) + MIDIDX: § hierPathSelIdxAtPath178's reach -- a
// hier_path (any context, both views) whose NON-TRAILING bit_select holds a non-constant index parented at that
// bit_select (a base select's reference index excluded: already at the path), or a path nested in another path's
// select index holding a non-trailing reference index (the name half).  Over-approximates: lvalues are not told
// apart (the law leaves a member select's lvalue index alone).  PATUNQUAL: § pkgPatUnqualReadTsNoParent178's
// reach -- a package-listed param_assign whose Rhs is an assignment-pattern operation with no tagged_pattern
// operand left and a PARENTED typespec reference (the source-level read test is not applied: over-approximates)., run on PRISTINE databases before the law sweep.
//   predict175 <db.uhdm>...   prints "<db> <LAW,...>" (or "-") per database.
// A database is predicted to move under a law when it holds an object the law rewrites:
//   FSPAN    a class_defn-listed function/task with vpiAccessType 2 (extern prototype listing), not
//            pure, carrying io_decls, a Return, or named `new`;
//   MULT     a package-listed subroutine that is a wildcard-import CLONE (a `C::m` whose class C is
//            declared in another package, or a free subroutine whose name and line recur under
//            another package) whose body begin or whose subroutine lists local variables;
//   FULLNAME a ref_obj inside a function/task that is an io_decl's default, or an argument of a
//            method_func_call / an index of a bit_select sitting directly in a hier_path, whose
//            stored full name differs from the parent-chain name with the same root and leaf;
//   ESPAN    a do_while.
// build: see drivers/cc175.sh.  Fail-closed fence: the caller (predict175.sh) never passes a
// fenced database.
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <iostream>
#include <map>
#include <set>
#include <string>
#include <vector>
using namespace UHDM;
static std::string chainName(const BaseClass* o) {
  if (o->UhdmType() == uhdmmodule_inst && o->VpiParent() && o->VpiParent()->UhdmType() == uhdmmodule_inst)
    return std::string(o->VpiDefName());
  std::vector<std::string_view> names; const BaseClass* p = o; const BaseClass* child = nullptr; bool col = false;
  while (p) {
    const BaseClass* ap = p->VpiParent(); auto pt = p->UhdmType(); auto apt = ap ? ap->UhdmType() : uhdmunsupported_stmt;
    if (pt == uhdmdesign) break;
    if (pt == uhdmpackage || pt == uhdmclass_defn) col = true;
    std::string_view n = p->VpiName().empty() ? p->VpiDefName() : p->VpiName();
    bool skip = apt == uhdmref_obj || pt == uhdmmethod_func_call || pt == uhdmmethod_task_call || pt == uhdmfunc_call ||
                pt == uhdmtask_call || pt == uhdmsys_func_call || pt == uhdmsys_task_call;
    if (child) { auto ct = child->UhdmType();
      if (ct == uhdmbit_select && pt == uhdmport) skip = true;
      if (ct == uhdmref_obj && (pt == uhdmbit_select || pt == uhdmindexed_part_select || pt == uhdmhier_path)) skip = true; }
    if (!n.empty() && !skip) names.push_back(n);
    child = p; p = p->VpiParent();
  }
  std::string f; for (size_t i = names.size(); i-- > 0;) { f += names[i]; if (i) f += col ? "::" : "."; } return f;
}
static bool ends(const std::string& a, std::string_view b) { return a.size() >= b.size() && a.compare(a.size() - b.size(), b.size(), b) == 0; }
int main(int argc, char** argv) {
  for (int ai = 1; ai < argc; ai++) {
    Serializer s; auto designs = s.Restore(std::string(argv[ai])); (void)designs;
    std::set<std::string> laws;
    std::map<std::string, std::string> classHome;             // class name -> package name
    std::map<std::pair<std::string, int>, std::set<std::string>> freeTf;  // (name,line) -> packages
    std::map<const BaseClass*, const BaseClass*> ioOf;
    std::set<const BaseClass*> cloneTf; std::map<std::pair<std::string, int>, std::vector<const BaseClass*>> freeObj;
    std::vector<const BaseClass*> declVars;  // variables listed by a begin / named_begin or an assignment's Lhs
    for (auto& kv : s.AllObjects()) { const BaseClass* o = kv.first; if (!o) continue;
      if (o->UhdmType() == uhdmclass_defn && o->VpiParent() && o->VpiParent()->UhdmType() == uhdmpackage)
        classHome[std::string(o->VpiName())] = std::string(o->VpiParent()->VpiName());
      if (o->UhdmType() == uhdmio_decl) if (auto* x = ((const io_decl*)o)->Expr()) ioOf[x] = o; }
    for (auto& kv : s.AllObjects()) { const BaseClass* o = kv.first; if (!o) continue; auto t = o->UhdmType();
      if (t == uhdmdo_while) laws.insert("ESPAN");
      if (t == uhdmparam_assign && o->VpiParent() && o->VpiParent()->UhdmType() == uhdmpackage) {
        auto* r = ((const param_assign*)o)->Rhs();
        if (r && r->UhdmType() == uhdmoperation && ((const operation*)r)->VpiOpType() == vpiAssignmentPatternOp) {
          auto* op = (const operation*)r; auto* os = op->Operands(); bool flat = os && !os->empty();
          if (os) for (auto* x : *os) if (!x || x->UhdmType() == uhdmtagged_pattern) flat = false;
          if (flat && op->Typespec() && op->Typespec()->VpiParent()) laws.insert("PATUNQUAL"); } }
      if (t == uhdmhier_path) { auto* pe = ((const hier_path*)o)->Path_elems();
        if (pe) for (size_t i = 0; i + 1 < pe->size(); i++) { auto* e = (*pe)[i];
          if (!e || e->UhdmType() != uhdmbit_select) continue; auto* ix = ((const bit_select*)e)->VpiIndex();
          if (!ix || ix->VpiParent() != e || ix->UhdmType() == uhdmconstant) continue;
          if (i == 0 && ix->UhdmType() == uhdmref_obj) continue;
          laws.insert("MIDIDX"); } }
      if (dynamic_cast<const variables*>(o) && o->VpiParent()) { auto pt = o->VpiParent()->UhdmType();
        if (pt == uhdmbegin || pt == uhdmnamed_begin || pt == uhdmassignment || pt == uhdmarray_var) declVars.push_back(o); }
      if (t == uhdmfunction || t == uhdmtask) {
        auto* tf = (const task_func*)o; const BaseClass* par = o->VpiParent();
        if (par && par->UhdmType() == uhdmclass_defn && tf->VpiAccessType() == 2 && !tf->VpiDPIPure()) {
          bool ret = t == uhdmfunction && ((const function*)o)->Return();
          (void)ret; }
        if (par && par->UhdmType() == uhdmpackage) {
          bool locals = tf->Variables() && !tf->Variables()->empty();
          if (auto* st = tf->Stmt(); st && st->UhdmType() == uhdmbegin) { auto* b = (const begin*)st; if (b->Variables() && !b->Variables()->empty()) locals = true; }
          std::string nm(tf->VpiName()); auto q = nm.find("::");
          if (q != std::string::npos) { auto h = classHome.find(nm.substr(0, q));
            if (h != classHome.end() && h->second != par->VpiName()) { cloneTf.insert(o); if (locals) laws.insert("MULT"); } }
          else { freeTf[{nm, (int)o->VpiLineNo()}].insert(std::string(par->VpiName())); freeObj[{nm, (int)o->VpiLineNo()}].push_back(o); } } }
      if (t == uhdmref_obj) {
        const BaseClass* p = o->VpiParent(); bool viaIo = false;
        if (auto it = ioOf.find(o); it != ioOf.end()) { p = it->second; viaIo = true; }
        if (!p) continue; const BaseClass* gp = p->VpiParent();
        bool shape = p->UhdmType() == uhdmio_decl;
        if (!shape && gp && gp->UhdmType() == uhdmhier_path && (p->UhdmType() == uhdmmethod_func_call || p->UhdmType() == uhdmbit_select)) {
          auto* pe = ((const hier_path*)gp)->Path_elems(); shape = pe && !pe->empty() && pe->back() == p; }
        if (!shape) continue;
        bool inTf = false;
        for (const BaseClass* q = p; q; q = q->VpiParent()) { auto qt = q->UhdmType();
          if (qt == uhdmfunction || qt == uhdmtask) { inTf = true; break; }
          if (qt == uhdmmodule_inst || qt == uhdminterface_inst || qt == uhdmgen_scope || qt == uhdmpackage || qt == uhdmclass_defn || qt == uhdmprogram) break; }
        if (!inTf) continue;
        std::string have(((const ref_obj*)o)->VpiFullName()), want;
        if (viaIo) { want = chainName(p); bool col = want.find("::") != std::string::npos;
          for (auto* q = p; q; q = q->VpiParent()) if (q->UhdmType() == uhdmpackage || q->UhdmType() == uhdmclass_defn) col = true;
          if (!want.empty()) want += (col ? "::" : ".") + std::string(o->VpiName()); }
        else want = chainName(o);
        std::string_view nm = o->VpiName();
        if (want.empty() || have.empty() || have == want || nm.empty() || !ends(have, nm) || !ends(want, nm)) continue;
        size_t hr = have.find_first_of(":."); if (hr == std::string::npos || want.compare(0, hr + 1, have, 0, hr + 1) != 0) continue;
        laws.insert("FULLNAME"); } }
    for (auto& [k, pk] : freeTf) if (pk.size() >= 2) for (auto* f : freeObj[k]) cloneTf.insert(f);
    for (auto* v : declVars) for (const BaseClass* q = v->VpiParent(); q; q = q->VpiParent()) {
      auto qt = q->UhdmType(); if (qt == uhdmfunction || qt == uhdmtask) { if (cloneTf.count(q)) laws.insert("MULT"); break; } }
    std::string o; for (auto& l : laws) o += (o.empty() ? "" : ",") + l;
    std::cout << argv[ai] << " " << (o.empty() ? "-" : o) << "\n";
  }
}
