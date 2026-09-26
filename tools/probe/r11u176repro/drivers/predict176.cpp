// predict176 — the r11u176 byte-mover predictor, run on PRISTINE databases before a law sweep.
//   predict176 <db.uhdm>...   prints "<db> <LAW,...>" (or "-") per database.
// Each trigger traces one branch of one law (the object the law rewrites):
//   FSPAN     (§ externProtoFormalsFromPrototype175, r11u175's trigger verbatim) a class_defn-listed
//             function/task with vpiAccessType 2 (extern prototype listing), not pure, carrying
//             io_decls, a Return, or named `new`;
//   CASTCLONE (§ castRhsClonePerInst176) a cont_assign listed by an ELABORATED instance (a module_inst
//             reached from the design's top instances) whose Rhs is a vpiCastOp
//             operation carrying a typespec (no assignment-pattern operand, no reference delay) and
//             whose Lhs is not a whole-name reference to a net / variable the instance lists (an
//             implicit net's reference, or a select / concatenation / path Lhs).
//   PROGLCLOC (§ progTypedPortLowConnUnlocated176) a definition program's (AllPrograms) port whose
//             Low_conn ref_obj binds nothing (a typed interface port) and is located;
//   PROGMPDEF (§ progLowConnDefModport176) an elaborated program's port whose Low_conn ref_obj binds a
//             modport that is not a definition interface's (its parent is not in AllInterfaces);
//   GENMPLOC  (§ genericMpConnLowConnAtDecl176) a port typed by an unsupported_typespec (a generic
//             interface port) whose Low_conn ref_obj binds a modport and is located off the port's
//             own span;
//   GENPLAIN  (§ genericPlainNamedView176, both switches) a generic interface port whose Low_conn
//             ref_obj binds an interface_inst (the named-connection port view);
//   PROGVIEW  (§ progPlainPortViewUnparented176) an elaborated program's port whose Low_conn ref_obj
//             binds an interface_inst.
//   TDWRITER  (§ tfArgQualOutsideWriter176, § tfArgClassMethodOrder176, § tfArgDefTopSplit176) a
//             function/task io_decl whose typespec reference reaches a package-level enum, struct or
//             union typespec (full name `pkg::name`) while the subroutine sits in a class_defn, or its
//             home unit (the nearest package / module / interface / program) is not that package.
//   UDPLV     (§ udpFormNetLvalueFirst176) a port whose HighConn is a concatenation whose first operand
//             is a concatenation holding a constant or a non-concatenation operation (the late wrap);
//   GATEGEN   (§ genElseBeginIfDepth176, § genElseIfGateArrayPath176) a gate (primitive or
//             primitive_array) listed under an elaborated gen_scope;
//   TDTIE     (§ tdEndMoveModuleOrder176) array_net / array_var objects in two different files at one
//             line and column whose typespec is the same named typedef;
//   TDKEY     (§ tdMoveKeyResolved176) two package typedefs with one bare name in two packages, one of
//             them typing a package subroutine's io_decl.
// build: drivers/cc176.sh.  Fail-closed fence: the caller (predict176.sh) never passes a fenced
// database.
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_user.h>
#include <functional>
#include <iostream>
#include <set>
#include <string>
#include <tuple>
using namespace UHDM;
static std::set<std::tuple<std::string, int, int>> defCastSites;  // def-view cast cont_assigns
static bool castRhs(const cont_assign* ca) {
  const expr* r = ca->Rhs();
  if (!r || r->UhdmType() != uhdmoperation) return false;
  auto* op = (const operation*)r;
  if (op->VpiOpType() != vpiCastOp || !op->Typespec()) return false;
  if (op->Operands())
    for (auto* o : *op->Operands())
      if (o && o->UhdmType() == uhdmoperation && ((const operation*)o)->VpiOpType() == vpiAssignmentPatternOp)
        return false;
  if (ca->Delay() && ca->Delay()->UhdmType() == uhdmref_obj) return false;
  return true;
}
static bool castClone(const cont_assign* ca, const BaseClass* inst) {
  // the elaborated listing's own Rhs (default view), or -- under --elabuhdm, where the listener may
  // have reduced the copy -- a definition cont_assign at the same position with a cast Rhs
  if (!castRhs(ca) && !defCastSites.count({std::string(ca->VpiFile()), (int)ca->VpiLineNo(), (int)ca->VpiColumnNo()}))
    return false;
  const expr* l = ca->Lhs();
  if (!l) return false;
  if (l->UhdmType() != uhdmref_obj) return true;  // select / concatenation / path Lhs
  const any* act = ((const ref_obj*)l)->Actual_group();
  std::set<const any*> listed;
  if (inst->UhdmType() == uhdmmodule_inst) {
    auto* m = (const module_inst*)inst;
    if (m->Nets()) for (auto* n : *m->Nets()) listed.insert(n);
    if (m->Variables()) for (auto* v : *m->Variables()) listed.insert(v);
  }
  if (act && listed.count(act)) return false;
  // a whole-name Lhs whose name the instance lists (the general path clones it anyway)
  if (inst->UhdmType() == uhdmmodule_inst) {
    auto* m = (const module_inst*)inst;
    if (m->Nets()) for (auto* n : *m->Nets()) if (n->VpiName() == l->VpiName()) return false;
    if (m->Variables()) for (auto* v : *m->Variables()) if (v->VpiName() == l->VpiName()) return false;
  }
  return true;
}
int main(int argc, char** argv) {
  for (int ai = 1; ai < argc; ai++) {
    Serializer s; auto designs = s.Restore(std::string(argv[ai]));
    std::set<std::string> laws;
    for (auto& kv : s.AllObjects()) { const BaseClass* o = kv.first; if (!o) continue; auto t = o->UhdmType();
      if (t == uhdmfunction || t == uhdmtask) {
        auto* tf = (const task_func*)o; const BaseClass* par = o->VpiParent();
        if (par && par->UhdmType() == uhdmclass_defn && tf->VpiAccessType() == 2 && !tf->VpiDPIPure()) {
          bool ret = t == uhdmfunction && ((const function*)o)->Return();
          if ((tf->Io_decls() && !tf->Io_decls()->empty()) || ret || tf->VpiName() == "new") laws.insert("FSPAN"); } } }
    defCastSites.clear();
    for (auto& kv : s.AllObjects()) if (kv.first && kv.first->UhdmType() == uhdmdesign) {
      auto* d = (const design*)kv.first;
      if (d->AllModules()) for (auto* m : *d->AllModules()) if (m->Cont_assigns()) for (auto* ca : *m->Cont_assigns())
        if (ca && castRhs(ca)) defCastSites.insert({std::string(ca->VpiFile()), (int)ca->VpiLineNo(), (int)ca->VpiColumnNo()}); }
    std::set<const BaseClass*> defIfs, defProgs;
    for (auto& kv : s.AllObjects()) if (kv.first && kv.first->UhdmType() == uhdmdesign) {
      auto* d = (const design*)kv.first;
      if (d->AllInterfaces()) for (auto* i : *d->AllInterfaces()) defIfs.insert(i);
      if (d->AllPrograms()) for (auto* p : *d->AllPrograms()) defProgs.insert(p); }
    for (auto& kv : s.AllObjects()) { const BaseClass* o = kv.first;
      if (!o || o->UhdmType() != uhdmport) continue;
      auto* pt = (const port*)o; const BaseClass* par = o->VpiParent();
      const any* lc = pt->Low_conn();
      if (!lc || lc->UhdmType() != uhdmref_obj) continue;
      auto* lr = (const ref_obj*)lc; const any* act = lr->Actual_group();
      bool isProg = par && par->UhdmType() == uhdmprogram;
      if (isProg && defProgs.count(par) && !act && lr->VpiLineNo() != 0) laws.insert("PROGLCLOC");
      if (isProg && !defProgs.count(par) && act && act->UhdmType() == uhdmmodport &&
          !defIfs.count(act->VpiParent())) laws.insert("PROGMPDEF");
      if (isProg && !defProgs.count(par) && act && act->UhdmType() == uhdminterface_inst) laws.insert("PROGVIEW");
      bool generic = false;
      if (auto* rt = pt->Typespec()) if (auto* a = rt->Actual_typespec()) generic = a->UhdmType() == uhdmunsupported_typespec;
      if (generic && act && act->UhdmType() == uhdmmodport &&
          (lr->VpiLineNo() != pt->VpiLineNo() || lr->VpiColumnNo() != pt->VpiColumnNo())) laws.insert("GENMPLOC");
      if (generic && act && act->UhdmType() == uhdminterface_inst) laws.insert("GENPLAIN"); }
    for (auto& kv : s.AllObjects()) { const BaseClass* o = kv.first;
      if (!o || o->UhdmType() != uhdmio_decl) continue;
      auto* io = (const io_decl*)o; const ref_typespec* rt = io->Typespec(); if (!rt) continue;
      const typespec* ts = rt->Actual_typespec(); if (!ts) continue;
      auto tt = ts->UhdmType();
      if (tt != uhdmenum_typespec && tt != uhdmstruct_typespec && tt != uhdmunion_typespec) continue;
      std::string tn(ts->VpiName()); auto q = tn.find("::"); if (q == std::string::npos) continue;
      std::string tpkg = tn.substr(0, q);
      const BaseClass* tf = io->VpiParent();
      if (!tf || (tf->UhdmType() != uhdmfunction && tf->UhdmType() != uhdmtask)) continue;
      bool inCls = false; std::string home;
      for (const BaseClass* a = tf->VpiParent(); a; a = a->VpiParent()) {
        auto at = a->UhdmType();
        if (at == uhdmclass_defn) inCls = true;
        if (at == uhdmpackage) { home = std::string(a->VpiName()); break; }
        if (at == uhdmmodule_inst || at == uhdminterface_inst || at == uhdmprogram) { home = "<unit>"; break; } }
      if (inCls || home != tpkg) laws.insert("TDWRITER"); }
    {
      std::function<bool(const any*)> nonLv = [&](const any* x) -> bool {
        if (!x) return false;
        if (x->UhdmType() == uhdmconstant) return true;
        if (x->UhdmType() == uhdmoperation) {
          auto* op = (const operation*)x;
          if (op->VpiOpType() != vpiConcatOp) return true;
          if (op->Operands()) for (auto* o : *op->Operands()) if (nonLv(o)) return true; }
        return false; };
      std::map<std::tuple<int, int, std::string>, std::set<std::string>> arrPos;
      std::map<std::string, std::set<std::string>> bareToPkg;
      std::set<std::string> ioPkgTd;
      for (auto& kv : s.AllObjects()) { const BaseClass* o = kv.first; if (!o) continue; auto t = o->UhdmType();
        if (t == uhdmport) { auto* pt = (const port*)o;
          if (auto* hc = pt->High_conn(); hc && hc->UhdmType() == uhdmoperation && ((const operation*)hc)->VpiOpType() == vpiConcatOp) {
            auto* ops = ((const operation*)hc)->Operands();
            if (ops && !ops->empty() && (*ops)[0]->UhdmType() == uhdmoperation &&
                ((const operation*)(*ops)[0])->VpiOpType() == vpiConcatOp && nonLv((*ops)[0])) laws.insert("UDPLV"); } }
        if (t == uhdmgate || t == uhdmudp || t == uhdmgate_array || t == uhdmudp_array || t == uhdmswitch_tran || t == uhdmswitch_array) {
          for (const BaseClass* a = o->VpiParent(); a; a = a->VpiParent()) if (a->UhdmType() == uhdmgen_scope) { laws.insert("GATEGEN"); break; } }
        const ref_typespec* rtA = nullptr;
        if (t == uhdmlogic_net) rtA = ((const logic_net*)o)->Typespec();
        else if (t == uhdmstruct_net) rtA = ((const struct_net*)o)->Typespec();
        else if (t == uhdmlogic_var) rtA = ((const logic_var*)o)->Typespec();
        else if (t == uhdmstruct_var) rtA = ((const struct_var*)o)->Typespec();
        else if (t == uhdmarray_var) rtA = ((const array_var*)o)->Typespec();
        if (rtA && rtA->Actual_typespec() &&
            (rtA->Actual_typespec()->UhdmType() == uhdmarray_typespec ||
             rtA->Actual_typespec()->UhdmType() == uhdmstruct_typespec ||
             rtA->Actual_typespec()->UhdmType() == uhdmunion_typespec ||
             rtA->Actual_typespec()->UhdmType() == uhdmenum_typespec)) {
          const ref_typespec* rt = rtA;
          std::string tn;
          if (rt && rt->Actual_typespec()) {
            const typespec* at = rt->Actual_typespec();
            if (at->UhdmType() == uhdmarray_typespec) { auto* et = ((const array_typespec*)at)->Elem_typespec(); if (et && et->Actual_typespec()) at = et->Actual_typespec(); }
            tn = std::string(at->VpiName()); }
          std::string fl(o->VpiFile());
          for (const BaseClass* a = o->VpiParent(); fl.empty() && a; a = a->VpiParent()) fl = std::string(a->VpiFile());
          if (!tn.empty()) arrPos[{(int)o->VpiLineNo(), (int)o->VpiColumnNo(), tn}].insert(fl); }
        if (t == uhdmenum_typespec || t == uhdmstruct_typespec || t == uhdmunion_typespec) {
          std::string n(o->VpiName()); auto q = n.find("::"); if (q != std::string::npos) bareToPkg[n.substr(q + 2)].insert(n.substr(0, q)); }
        if (t == uhdmio_decl) { auto* io = (const io_decl*)o;
          if (auto* rt = io->Typespec(); rt && rt->Actual_typespec()) {
            bool inPkg = false; for (const BaseClass* a = o->VpiParent(); a; a = a->VpiParent()) if (a->UhdmType() == uhdmpackage) { inPkg = true; break; }
            std::string n(rt->Actual_typespec()->VpiName()); auto q = n.find("::");
            if (inPkg && q != std::string::npos) ioPkgTd.insert(n.substr(q + 2)); } } }
      for (auto& [k, fs] : arrPos) { if (getenv("P176_DBG")) { std::cerr << std::get<0>(k) << ":" << std::get<1>(k) << " " << std::get<2>(k); for (auto& f : fs) std::cerr << " [" << f << "]"; std::cerr << "\n"; } if (fs.size() >= 2) laws.insert("TDTIE"); }
      for (auto& b : ioPkgTd) if (bareToPkg[b].size() >= 2) laws.insert("TDKEY");
    }
    std::function<void(const BaseClass*)> walk = [&](const BaseClass* inst) {
      if (!inst) return;
      const std::vector<cont_assign*>* cas = nullptr;
      const std::vector<module_inst*>* mods = nullptr;
      const std::vector<interface_inst*>* ifs = nullptr;
      if (inst->UhdmType() == uhdmmodule_inst) { auto* m = (const module_inst*)inst; cas = m->Cont_assigns(); mods = m->Modules(); ifs = m->Interfaces(); }
      if (cas) for (auto* ca : *cas) if (ca && castClone(ca, inst)) laws.insert("CASTCLONE");
      if (mods) for (auto* c : *mods) walk(c);
      if (ifs) for (auto* c : *ifs) walk(c);
    };
    (void)designs;
    for (auto& kv : s.AllObjects()) if (kv.first && kv.first->UhdmType() == uhdmdesign) {
      auto* d = (const design*)kv.first; if (d->TopModules()) for (auto* t : *d->TopModules()) walk(t); }
    std::string o; for (auto& l : laws) o += (o.empty() ? "" : ",") + l;
    std::cout << argv[ai] << " " << (o.empty() ? "-" : o) << "\n";
  }
}
