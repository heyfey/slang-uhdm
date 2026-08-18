// r10earl64 — PARAM_ASSIGN Rhs ENCODING CENSUS, read straight from a .uhdm
// database (never uhdm-dump: Earlgrey's dump is >1 GB and takes hours —
// earl61's hccen61.cpp / earl62's cacen62.cpp lesson, reused).
//
// MEASUREMENT ONLY.  The official uhdm-cmp stays the sole judge.
//
// One line per param_assign:
//   PA <sec> <owner> <L:C> <paramname> <rhskind> ct=<n> sz=<n> val=<v> dec=<d>
//
// <sec> is DEF (design AllModules/AllPackages listing) or ELAB (instance tree).
// <owner> is the DEFNAME by default, the instance vpiFullName with R64_INST=1.
// design::Compare on a constant reads, in order: VpiType, VpiDecompile,
// VpiSize, Typespec, VpiConstType.  VpiValue is NOT read — it is printed
// because it names the Value TYPE Surelog folded to, which is what the
// encoding law is about.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <string>
using namespace UHDM;

static const char* SEC = "DEF";
static std::string OWN, INST;
static bool WITHINST = false;

static std::string esc(std::string_view v) {
  std::string r;
  for (char c : v) r += (c == ' ' ? '_' : c);
  if (r.empty()) r = "-";
  return r;
}

static void do_pas(const VectorOfparam_assign* pas) {
  if (!pas) return;
  for (auto* pa : *pas) {
    if (!pa) continue;
    std::string pn = "-";
    if (auto* l = pa->Lhs()) pn = std::string(l->VpiName());
    if (pn.empty()) pn = "-";
    const any* r = pa->Rhs();
    std::string kind = r ? std::string(UhdmName(r->UhdmType())) : "<null>";
    char buf[1024];
    if (r && r->UhdmType() == uhdmconstant) {
      auto* c = (const constant*)r;
      snprintf(buf, sizeof buf, "ct=%d sz=%d val=%s dec=%s",
               c->VpiConstType(), c->VpiSize(),
               esc(c->VpiValue()).c_str(), esc(c->VpiDecompile()).c_str());
    } else if (r && r->UhdmType() == uhdmoperation) {
      snprintf(buf, sizeof buf, "op=%d", ((const operation*)r)->VpiOpType());
    } else {
      snprintf(buf, sizeof buf, "name=%s",
               r ? esc(r->VpiName()).c_str() : "-");
    }
    printf("PA %s %s L%u:%u %s %s %s ov=%d\n", SEC,
           (WITHINST ? INST : OWN).c_str(), pa->VpiLineNo(),
           pa->VpiColumnNo(), pn.c_str(), kind.c_str(), buf,
           pa->VpiOverriden() ? 1 : 0);
  }
}

static void do_scope(const scope* sc);

static void do_gsa(const VectorOfgen_scope_array* gsas) {
  if (!gsas) return;
  for (auto* ga : *gsas)
    if (ga->Gen_scopes()) for (auto* g : *ga->Gen_scopes()) do_scope(g);
}

static void do_inst(const instance* in) {
  std::string saved = OWN, savedI = INST;
  if (!in->VpiDefName().empty()) OWN = std::string(in->VpiDefName());
  INST = std::string(in->VpiFullName());
  if (auto* m = any_cast<const module_inst*>(in)) {
    do_pas(m->Param_assigns());
    do_gsa(m->Gen_scope_arrays());
    if (m->Modules()) for (auto* c : *m->Modules()) do_inst(c);
    if (m->Interfaces()) for (auto* c : *m->Interfaces()) do_inst(c);
  } else if (auto* i = any_cast<const interface_inst*>(in)) {
    do_pas(i->Param_assigns());
    do_gsa(i->Gen_scope_arrays());
  }
  OWN = saved; INST = savedI;
}

static void do_scope(const scope* sc) {
  auto* g = any_cast<const gen_scope*>(sc);
  if (!g) return;
  do_pas(g->Param_assigns());
  if (g->Modules()) for (auto* c : *g->Modules()) do_inst(c);
  if (g->Interfaces()) for (auto* c : *g->Interfaces()) do_inst(c);
  do_gsa(g->Gen_scope_arrays());
}

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: pacen64 <db.uhdm>\n"); return 2; }
  WITHINST = getenv("R64_INST") != nullptr;
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "EMPTY %s\n", argv[1]); return 3; }
  for (vpiHandle h : restored) {
    const any* o = (const any*)((const uhdm_handle*)h)->object;
    auto* d = any_cast<const design*>(o);
    if (!d) continue;
    SEC = "DEF";
    if (d->AllModules()) for (auto* m : *d->AllModules()) {
      OWN = std::string(m->VpiDefName()); INST = OWN;
      do_pas(m->Param_assigns()); do_gsa(m->Gen_scope_arrays()); }
    if (d->AllInterfaces()) for (auto* m : *d->AllInterfaces()) {
      OWN = std::string(m->VpiDefName()); INST = OWN;
      do_pas(m->Param_assigns()); do_gsa(m->Gen_scope_arrays()); }
    if (d->AllPackages()) for (auto* p : *d->AllPackages()) {
      OWN = std::string(p->VpiDefName()); INST = OWN;
      do_pas(p->Param_assigns()); }
    SEC = "ELAB";
    if (d->TopPackages()) for (auto* p : *d->TopPackages()) {
      OWN = std::string(p->VpiDefName()); INST = OWN;
      do_pas(p->Param_assigns()); }
    if (d->TopModules()) for (auto* m : *d->TopModules()) do_inst(m);
  }
  return 0;
}
