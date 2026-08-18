// r10earl62 — MODULE-LOCAL TYPESPEC census, straight from a .uhdm database.
// For every module_inst (DEF listing and ELAB tree) prints its own Typespecs
// (kind:name, #enum consts / #members) and, for every net/variable it owns,
// the typespec its ref_typespec actually resolves to.  This is what UHDM's
// clone_tree hier_path resolver and ElaboratorListener's enum collection read.
// MEASUREMENT ONLY.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
using namespace UHDM;

static const char* SEC = "DEF";
static std::string DEFN;

static void tsline(const char* tag, const std::string& own, const typespec* t,
                   const char* extra) {
  if (!t) { printf("TS %s %s %s %s <null> %s\n", SEC, own.c_str(), DEFN.c_str(), tag, extra); return; }
  int n = -1;
  if (t->UhdmType() == uhdmenum_typespec) {
    auto* e = (const enum_typespec*)t; n = e->Enum_consts() ? (int)e->Enum_consts()->size() : 0;
  } else if (t->UhdmType() == uhdmstruct_typespec) {
    auto* e = (const struct_typespec*)t; n = e->Members() ? (int)e->Members()->size() : 0;
  }
  std::string k(UhdmName(t->UhdmType())), nm(t->VpiName());
  printf("TS %s %s %s %s %s:%s n=%d id=%u %s\n", SEC, own.c_str(), DEFN.c_str(),
         tag, k.c_str(), nm.c_str(), n, (unsigned)t->UhdmId(), extra);
}

template <class T>
static void do_one(const T* m, const std::string& own) {
  DEFN = std::string(m->VpiDefName());
  if (m->Typespecs())
    for (auto* t : *m->Typespecs()) tsline("OWNTS", own, t, "");
  if (m->Variables())
    for (auto* v : *m->Variables()) {
      auto* rt = v->Typespec();
      std::string vn(v->VpiName());
      tsline("VAR", own, rt ? rt->Actual_typespec() : nullptr, vn.c_str());
    }
  if (m->Nets())
    for (auto* v : *m->Nets()) {
      auto* rt = v->Typespec();
      std::string vn(v->VpiName());
      tsline("NET", own, rt ? rt->Actual_typespec() : nullptr, vn.c_str());
    }
}

static const char* FILT = nullptr;
// Interfaces carry module-local typedefs too — `emitTypedefs` runs for them at
// ModuleEmit's emitInterfaceDef site — and leaving them out of this walk is
// what made r10earl62's first mover PREDICTION read ZERO where byteverify then
// found `genvar_iface_struct` (an interface-local `req_t` on the second and
// third interface instance).  Walk both kinds.
static void do_inst(const module_inst* m);
static void do_iface(const interface_inst* i) {
  if (!FILT || i->VpiDefName().find(FILT) != std::string_view::npos)
    do_one(i, std::string(i->VpiFullName()));
  if (i->Interfaces()) for (auto* c : *i->Interfaces()) do_iface(c);
}
static void do_inst(const module_inst* m) {
  if (!FILT || m->VpiDefName().find(FILT) != std::string_view::npos)
    do_one(m, std::string(m->VpiFullName()));
  if (m->Modules()) for (auto* c : *m->Modules()) do_inst(c);
  if (m->Interfaces()) for (auto* c : *m->Interfaces()) do_iface(c);
}

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: mlts62 <db.uhdm> [defname-substr]\n"); return 2; }
  if (argc > 2) FILT = argv[2];
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "EMPTY\n"); return 3; }
  for (vpiHandle h : restored) {
    auto* d = any_cast<const design*>((const any*)((const uhdm_handle*)h)->object);
    if (!d) continue;
    SEC = "DEF";
    if (d->AllModules()) for (auto* m : *d->AllModules())
      if (!FILT || m->VpiDefName().find(FILT) != std::string_view::npos)
        do_one(m, std::string(m->VpiDefName()));
    if (d->AllInterfaces()) for (auto* m : *d->AllInterfaces())
      if (!FILT || m->VpiDefName().find(FILT) != std::string_view::npos)
        do_one(m, std::string(m->VpiDefName()));
    SEC = "ELAB";
    if (d->TopModules()) for (auto* m : *d->TopModules()) do_inst(m);
    if (d->TopPackages()) (void)0;
  }
  return 0;
}
