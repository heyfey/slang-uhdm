// r10uvm142 — CLASS_TYPESPEC CENSUS.  MEASUREMENT ONLY.
// The official uhdm-cmp stays the sole acceptance judge.
//
// One row per `class_typespec` object the UhdmListener reaches, deduped by
// UhdmId per LISTING (a NODEDUP census manufactures AWAY-GOLDEN phantoms —
// RESUME.md §9).  Scored fields are exactly the ones the generated
// `class_typespec::Compare` / `typespec::Compare` / `BaseClass::Compare` read:
//
//   TSNAME  = VpiName                    <- typespec::Compare
//   TSINST  = Instance() kind(name)      <- typespec::Compare   <- THE HEAD
//   TSALIAS = Typedef_alias() actual     <- typespec::Compare
//   TSDEFN  = Class_defn() full name     <- class_typespec::Compare
//   TSCT    = VpiClassType               <- class_typespec::Compare
//   TSAUTO  = VpiAutomatic               <- class_typespec::Compare
//   TSPARM  = #Parameters                <- class_typespec::Compare (vector)
//   TSPA    = #Param_assigns             <- class_typespec::Compare (vector)
//   TSEXT   = Extends() target           <- class_typespec::Compare
// dump-only diagnostics (no generated Compare reads them):
//   TSSPAN  = the object's own span      (THE CENSUS KEY — our objects carry an
//                                         EMPTY VpiFile, so file is never keyed)
//   TSID    = UhdmId  (sharing: two rows with ONE id = one shared object)
//   DEFSPAN = the Class_defn's span      (TSSPAN==DEFSPAN => the class's own
//                                         LISTING typespec, not a per-use mint)
//   PAR     = VpiParent kind(name)
//   SCOPE   = the NAMED-scope parent chain
//   SITE    = which design listing the walk entered from
//
//   build: g++ -O2 -std=c++17 ct142cen.cpp -I ~/.local/include \
//              -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct142cen
//   usage: ct142cen <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/UhdmListener.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
#include <vector>
#include <set>
#include <map>
using namespace UHDM;

static std::string esc(std::string_view v) {
  std::string r;
  for (char c : v) r += ((c == ' ' || c == '\t' || c == '|') ? '_' : c);
  if (r.empty()) r = "-";
  return r;
}
static std::string spanOf(const any* o) {
  if (!o) return "-";
  char b[80];
  snprintf(b, sizeof b, "%u:%hu-%u:%hu", (unsigned)o->VpiLineNo(),
           o->VpiColumnNo(), (unsigned)o->VpiEndLineNo(), o->VpiEndColumnNo());
  return b;
}
static std::string kindName(const any* o) {
  if (!o) return "-";
  std::string e(UhdmName(o->UhdmType()));
  std::string n(o->VpiName());
  if (n.empty())
    if (const instance* in = any_cast<const instance*>(o)) n = std::string(in->VpiFullName());
  if (!n.empty()) e += "(" + esc(n) + ")";
  return e;
}
static std::string scopeOf(const any* o) {
  std::string r;
  const any* p = o ? o->VpiParent() : nullptr;
  for (int i = 0; i < 60 && p; i++) {
    switch (p->UhdmType()) {
      case uhdmtask: case uhdmfunction: case uhdmclass_defn:
      case uhdmmodule_inst: case uhdmpackage: case uhdmprogram:
      case uhdminterface_inst: {
        std::string e(UhdmName(p->UhdmType()));
        e += "(" + esc(p->VpiName()) + ")";
        r = r.empty() ? e : (e + "/" + r);
        break;
      }
      default: break;
    }
    p = p->VpiParent();
  }
  if (r.empty()) r = "-";
  return r;
}

static const char* g_lst = "-";

// PASS 1 — the REFERRER index.  Every `ref_typespec` whose Actual is a
// class_typespec is recorded against that typespec's UhdmId as
// "<holder kind>(<holder name>)"; the holder is the ref's OWN vpiParent, which
// BOTH producers set to the declaration object (Surelog:
// `tpsRef->VpiParent(var)`, CompileType.cpp:378).  A typespec with no referrer
// prints HOLD=- (a package/class LISTING entry reached through Typespecs()).
static std::map<unsigned, std::set<std::string>> g_hold;
struct RefIdx : public UhdmListener {
  void enterAny(const any* o) override {
    const ref_typespec* r = any_cast<const ref_typespec*>(o);
    if (!r) return;
    const typespec* a = r->Actual_typespec();
    if (!a || a->UhdmType() != uhdmclass_typespec) return;
    const any* h = r->VpiParent();
    std::string e = h ? std::string(UhdmName(h->UhdmType())) : std::string("-");
    if (h && !h->VpiName().empty()) e += "(" + esc(h->VpiName()) + ")";
    // ...and the holder's OWN owner kind, which is what separates a body local
    // (function/task) from a class property (class_defn) or a package variable
    // (package) without reading any name.
    if (h && h->VpiParent()) {
      // ...and a subroutine's RETURN VALUE variable is marked "@ret", never
      // "@function": it hangs off the function exactly as a TF-ITEM body local
      // does, and it is a DIFFERENT Surelog site (the class-handle return arm)
      // that this pass deliberately does not touch.
      const any* hp = h->VpiParent();
      bool isRet = false;
      if (const task_func* tf = any_cast<const task_func*>(hp))
        isRet = (tf->Return() == any_cast<const variables*>(h));
      e += isRet ? "@ret" : ("@" + std::string(UhdmName(hp->UhdmType())));
    }
    g_hold[(unsigned)a->UhdmId()].insert(e);
  }
};

struct Cen : public UhdmListener {
  std::set<unsigned> seen;
  void enterAny(const any* o) override {
    const class_typespec* t = any_cast<const class_typespec*>(o);
    if (!t) return;
    if (!seen.insert((unsigned)t->UhdmId()).second) return;
    const class_defn* cd = t->Class_defn();
    const typespec* al =
        t->Typedef_alias() ? t->Typedef_alias()->Actual_typespec() : nullptr;
    std::string defn = cd ? esc(cd->VpiFullName().empty() ? cd->VpiName()
                                                          : cd->VpiFullName())
                          : std::string("-");
    std::string alias = t->Typedef_alias()
                            ? (al ? kindName(al) : std::string("NULLACT"))
                            : std::string("NOALIAS");
    std::string hold;
    if (auto it = g_hold.find((unsigned)t->UhdmId()); it != g_hold.end())
      for (const auto& h : it->second) hold += (hold.empty() ? "" : ",") + h;
    if (hold.empty()) hold = "-";
    printf("HOLD=%s|TSNAME=%s|TSINST=%s|TSALIAS=%s|TSDEFN=%s|TSCT=%d|TSAUTO=%d"
           "|TSPARM=%d|TSPA=%d|TSEXT=%s|TSSPAN=%s|TSID=%u|DEFSPAN=%s"
           "|PAR=%s|SCOPE=%s|SITE=%s\n",
           hold.c_str(), esc(t->VpiName()).c_str(),
           kindName(t->Instance()).c_str(),
           alias.c_str(),
           cd ? defn.c_str() : "-",
           (int)t->VpiClassType(), t->VpiAutomatic() ? 1 : 0,
           t->Parameters() ? (int)t->Parameters()->size() : -1,
           t->Param_assigns() ? (int)t->Param_assigns()->size() : -1,
           t->Extends() ? kindName(t->Extends()->Actual_typespec()).c_str() : "-",
           spanOf(t).c_str(), (unsigned)t->UhdmId(), spanOf(cd).c_str(),
           kindName(t->VpiParent()).c_str(), scopeOf(t).c_str(), g_lst);
  }
};

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: ct142cen <db.uhdm>\n"); return 2; }
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "EMPTY %s\n", argv[1]); return 3; }
  for (vpiHandle h : restored) {
    const any* o = (const any*)((const uhdm_handle*)h)->object;
    const design* d = any_cast<const design*>(o);
    if (!d) continue;
    g_hold.clear();
    {
      RefIdx r;
      if (d->AllPackages()) for (auto* p : *d->AllPackages()) r.listenAny(p);
      if (d->TopPackages()) for (auto* p : *d->TopPackages()) r.listenAny(p);
      if (d->AllClasses())  for (auto* p : *d->AllClasses())  r.listenAny(p);
      if (d->TopModules())  for (auto* p : *d->TopModules())  r.listenAny(p);
      if (d->AllModules())  for (auto* p : *d->AllModules())  r.listenAny(p);
      if (d->AllPrograms()) for (auto* p : *d->AllPrograms()) r.listenAny(p);
      if (d->AllInterfaces())for (auto* p : *d->AllInterfaces()) r.listenAny(p);
    }
    Cen c;
    if (d->AllPackages()) { g_lst = "ALLPKG"; for (auto* p : *d->AllPackages()) c.listenAny(p); }
    if (d->TopPackages()) { g_lst = "TOPPKG"; for (auto* p : *d->TopPackages()) c.listenAny(p); }
    if (d->AllClasses())  { g_lst = "ALLCLS"; for (auto* p : *d->AllClasses())  c.listenAny(p); }
    if (d->TopModules())  { g_lst = "TOPMOD"; for (auto* p : *d->TopModules())  c.listenAny(p); }
    if (d->AllModules())  { g_lst = "ALLMOD"; for (auto* p : *d->AllModules())  c.listenAny(p); }
    if (d->AllPrograms()) { g_lst = "ALLPRG"; for (auto* p : *d->AllPrograms()) c.listenAny(p); }
    if (d->AllInterfaces()){g_lst = "ALLIFC"; for (auto* p : *d->AllInterfaces()) c.listenAny(p); }
  }
  return 0;
}
