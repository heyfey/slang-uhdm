// r10rgg9/caprobe9.cpp — MEASUREMENT ONLY.  The official uhdm-cmp is the judge.
//
// Print the FULL shape of every cont_assign matching (instance-path substring,
// line) in a database: Lhs kind/name/typespec, Rhs kind and, for an operation,
// its operands one level down.  Used to read golden's folded object and ours
// side by side.  LHS IS ALWAYS GOLDEN — this tool reads ONE database.
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <cstdio>
#include <string>
#include <set>
using namespace UHDM;

static std::string L(const any* o) {
  if (!o) return "-";
  char b[256];
  snprintf(b, sizeof b, "%u:%u-%u:%u", (unsigned)o->VpiLineNo(),
           (unsigned)o->VpiColumnNo(), (unsigned)o->VpiEndLineNo(),
           (unsigned)o->VpiEndColumnNo());
  return b;
}
static void pr(const any* o, int ind) {
  if (!o) return;
  char pad[64]; int n = ind*2 > 60 ? 60 : ind*2;
  for (int i = 0; i < n; i++) pad[i] = ' ';
  pad[n] = 0;
  UHDM_OBJECT_TYPE t = o->UhdmType();
  printf("%s%s name='%s' @%s", pad, std::string(UhdmName(t)).c_str(),
         std::string(o->VpiName()).c_str(), L(o).c_str());
  if (t == uhdmconstant) {
    auto* c = (constant*)o;
    printf(" ct=%d sz=%d val=%s dec='%s'", c->VpiConstType(), c->VpiSize(),
           std::string(c->VpiValue()).c_str(),
           std::string(c->VpiDecompile()).c_str());
  }
  if (auto* e = any_cast<const expr*>(o)) {
    if (auto* rt = e->Typespec()) {
      auto* at = rt->Actual_typespec();
      printf(" TS=%s", at ? std::string(UhdmName(at->UhdmType())).c_str() : "<null-actual>");
    } else printf(" TS=-");
  }
  printf(" parent=%s\n", o->VpiParent()
         ? std::string(UhdmName(o->VpiParent()->UhdmType())).c_str() : "-");
  if (t == uhdmoperation) {
    auto* op = (operation*)o;
    printf("%s  opType=%d\n", pad, op->VpiOpType());
    if (op->Operands()) for (auto* a : *op->Operands()) pr(a, ind+2);
  } else if (t == uhdmhier_path) {
    auto* h = (hier_path*)o;
    if (h->Path_elems()) for (auto* a : *h->Path_elems()) pr(a, ind+2);
  } else if (t == uhdmbit_select) {
    auto* b = (bit_select*)o;
    pr(b->VpiIndex(), ind+2);
  }
}
static const char* g_path; static unsigned g_line;
static void emitCa(const char* view, const std::string& path, const VectorOfcont_assign* cas) {
  if (!cas) return;
  if (path.find(g_path) == std::string::npos) return;
  for (auto* ca : *cas) {
    if (g_line && ca->VpiLineNo() != g_line) continue;
    printf("== %s %s  cont_assign @%s parent=%s\n", view, path.c_str(), L(ca).c_str(),
           ca->VpiParent() ? std::string(UhdmName(ca->VpiParent()->UhdmType())).c_str() : "-");
    printf("  LHS:\n"); pr(ca->Lhs(), 2);
    printf("  RHS:\n"); pr(ca->Rhs(), 2);
  }
}
static void walkScope(const char* view, const any* sc, std::set<const any*>& seen);
static void walkGen(const char* view, const VectorOfgen_scope_array* gsa, std::set<const any*>& seen) {
  if (!gsa) return;
  for (auto* g : *gsa) if (g->Gen_scopes()) for (auto* gs : *g->Gen_scopes()) walkScope(view, gs, seen);
}
static void walkScope(const char* view, const any* sc, std::set<const any*>& seen) {
  if (!sc || !seen.insert(sc).second) return;
  std::string path;
  if (auto* sco = any_cast<const scope*>(sc)) path = std::string(sco->VpiFullName());
  if (path.empty()) path = std::string(sc->VpiName());
  UHDM_OBJECT_TYPE t = sc->UhdmType();
  if (t == uhdmmodule_inst) {
    auto* m = (module_inst*)sc;
    emitCa(view, path, m->Cont_assigns());
    walkGen(view, m->Gen_scope_arrays(), seen);
    if (m->Modules()) for (auto* c : *m->Modules()) walkScope(view, c, seen);
    if (m->Interfaces()) for (auto* c : *m->Interfaces()) walkScope(view, c, seen);
    if (m->Interface_arrays()) for (auto* ia : *m->Interface_arrays())
      if (ia->Instances()) for (auto* c : *ia->Instances()) walkScope(view, c, seen);
    if (m->Module_arrays()) for (auto* ma : *m->Module_arrays())
      if (ma->Modules()) for (auto* c : *ma->Modules()) walkScope(view, c, seen);
  } else if (t == uhdmgen_scope) {
    auto* g = (gen_scope*)sc;
    emitCa(view, path, g->Cont_assigns());
    walkGen(view, g->Gen_scope_arrays(), seen);
    if (g->Modules()) for (auto* c : *g->Modules()) walkScope(view, c, seen);
    if (g->Interfaces()) for (auto* c : *g->Interfaces()) walkScope(view, c, seen);
  } else if (t == uhdminterface_inst) {
    auto* i = (interface_inst*)sc;
    emitCa(view, path, i->Cont_assigns());
    walkGen(view, i->Gen_scope_arrays(), seen);
  }
}
int main(int argc, char** argv) {
  if (argc < 3) { fprintf(stderr, "usage: caprobe9 <db.uhdm> <path-substr> [line]\n"); return 2; }
  g_path = argv[2]; g_line = argc > 3 ? (unsigned)atoi(argv[3]) : 0;
  Serializer s;
  auto restored = s.Restore(std::filesystem::path(argv[1]));
  if (restored.empty()) { fprintf(stderr, "FATAL: restore failed\n"); return 3; }
  for (auto h : restored) {
    auto* d = (design*)((const uhdm_handle*)h)->object;
    std::set<const any*> a, b;
    if (d->AllModules()) for (auto* m : *d->AllModules()) walkScope("DEF", m, a);
    if (d->AllInterfaces()) for (auto* m : *d->AllInterfaces()) walkScope("DEF", m, a);
    if (d->TopModules()) for (auto* m : *d->TopModules()) walkScope("ELAB", m, b);
  }
  return 0;
}
