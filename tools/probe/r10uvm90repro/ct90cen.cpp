// r10uvm90 — MEASUREMENT-ONLY.  The constructor-call ARGUMENT census.
//
// Walks EVERY object of ONE database once (Serializer::AllObjects) and emits one
// row per `method_func_call` whose VpiName is `new` or `super.new` -- the object
// this pass's law owns -- keyed by the fields `method_func_call::Compare`
// actually reads (VpiName + the Tf_call_args VECTOR: its SIZE, its element
// KINDS, their NAMES and whether each ref carries a vpiActual).
//
// The object is LOC-LESS by construction (Surelog never calls
// populateCoreMembers on it), so the JOIN KEY is the OWNER's fullname plus the
// FIRST ARGUMENT's span -- and when there are no arguments at all, the owner
// alone, with an occurrence index appended so two loc-less argument-less calls
// in one routine stay distinguishable.
//
//   OWNER    kind:fullname of the nearest enclosing function/task/class/pkg/mod
//   NAME     `new` | `super.new`                                (CMP-JUDGED)
//   NARGS    Tf_call_args size, or -1 when the VECTOR IS NULL   (CMP-JUDGED)
//   A1SPAN   first argument's line:col-endln:endcol, or `-`     (join only)
//   ARGS     per argument: kind[:name][@span][*bound]           (CMP-JUDGED)
//
// usage: ct90cen <db.uhdm> [--all]
//   default: only rows whose NARGS <= 0 (the population the law can move)
//   --all:   every `new`/`super.new` row
// build: g++ -O2 -std=c++17 ct90cen.cpp -I ~/.local/include \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct90cen
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <string>
#include <map>
#include <vector>
using namespace UHDM;

static std::string kindName(const BaseClass* o) {
  if (!o) return "<null>";
  return std::string(UHDM::UhdmName(o->UhdmType()));
}
static std::string spanOf(const BaseClass* o) {
  char b[64];
  snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(), o->VpiColumnNo(),
           o->VpiEndLineNo(), o->VpiEndColumnNo());
  return std::string(b);
}
static std::string fullOf(const BaseClass* o) {
  if (!o) return "<null>";
  vpiHandle h = NewVpiHandle(o);
  const char* s = h ? vpi_get_str(vpiFullName, h) : nullptr;
  std::string r = s ? s : "";
  if (h) vpi_free_object(h);
  if (r.empty()) r = std::string(o->VpiName());
  if (r.empty()) r = "<anon>";
  return r;
}
static std::string ownerStr(const BaseClass* o) {
  const BaseClass* p = o ? o->VpiParent() : nullptr;
  for (int i = 0; i < 80 && p; i++) {
    UHDM_OBJECT_TYPE t = p->UhdmType();
    if (t == uhdmfunction || t == uhdmtask || t == uhdmclass_defn ||
        t == uhdmpackage || t == uhdmmodule_inst)
      return kindName(p) + ":" + fullOf(p);
    p = p->VpiParent();
  }
  return "<unparented>";
}
// One argument's CMP-visible shape.
static std::string argStr(const any* a) {
  if (!a) return "<null>";
  std::string r = kindName(a);
  std::string nm(a->VpiName());
  if (!nm.empty()) r += ":" + nm;
  r += "@" + spanOf(a);
  if (a->UhdmType() == uhdmref_obj) {
    const ref_obj* ro = (const ref_obj*)a;
    r += ro->Actual_group() ? "*bound" : "*bare";
  }
  return r;
}

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: ct90cen <db.uhdm> [--all]\n"); return 2; }
  bool all = false;
  for (int i = 2; i < argc; i++) if (!strcmp(argv[i], "--all")) all = true;
  Serializer ser;
  std::vector<vpiHandle> restored = ser.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "RESTORE_FAILED %s\n", argv[1]); return 3; }
  std::map<std::string, int> occ;
  for (auto& kv : ser.AllObjects()) {
    const BaseClass* o = kv.first;
    if (!o || o->UhdmType() != uhdmmethod_func_call) continue;
    const method_func_call* m = (const method_func_call*)o;
    std::string nm(m->VpiName());
    if (nm != "new" && nm != "super.new") continue;
    auto* v = m->Tf_call_args();
    int n = v ? (int)v->size() : -1;
    if (!all && n > 0) continue;
    std::string ow = ownerStr(m);
    std::string a1 = (v && !v->empty()) ? spanOf((*v)[0]) : "-";
    int k = occ[ow + "|" + nm + "|" + a1]++;
    std::string args;
    if (v) for (auto* a : *v) { if (!args.empty()) args += ">"; args += argStr(a); }
    printf("%s\t%s#%d\t%s\tNARGS=%d\t%s\n", ow.c_str(), a1.c_str(), k, nm.c_str(),
           n, args.empty() ? "-" : args.c_str());
  }
  return 0;
}
