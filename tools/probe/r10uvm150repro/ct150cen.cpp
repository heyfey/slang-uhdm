// r10uvm150 — MEASUREMENT-ONLY.  THE CALL-CHAIN CENSUS.
//
// Two populations, one pass over Serializer::AllObjects:
//
//   HP   every hier_path whose Path_elems carry at least one CALL element
//        (func_call / task_call / method_func_call / sys_func_call).  This is
//        the road § rootCallEatsTheChain150 must NOT touch — the NAME-rooted
//        chain (`v.m(a)`, `v[i].m(a)`, `v.a().b()`) that Surelog builds in
//        compileComplexFuncCall's `while (dotedName)` loop.  Payload = the
//        ELEMENT SEQUENCE: per element its UHDM kind, its VpiName (or <anon>)
//        and its argument count.
//   CALL every func_call / task_call / method_func_call that is NOT inside a
//        hier_path, keyed by span, payload = kind, name, argument count,
//        whether it carries a vpiFunction/vpiTask binding and whether it
//        carries a Prefix.  This is the population the law MINTS into (the
//        surviving root call) and the one it DELETES from (the discarded
//        method_func_call).
//
// KEY is line:col-endln:endcol plus the kind, so a golden row and an ours row
// join on the WRITTEN SITE.  VpiFile is DELIBERATELY OUT of the key: our
// emitter leaves it EMPTY on these objects, and a first cut of this census that
// keyed on basename(VpiFile) reported the four NEW func_calls as AWAY-GOLDEN
// phantoms because golden's identical rows sat under a different key.
// VpiFullName is never in the key or the payload (the judge does not read it).
// The DEF/ELAB view is deliberately NOT in the key: the two producers label it
// differently.
//
// usage: ct150cen <db.uhdm> [--hp|--call|--all]
// build: g++ -O2 -std=c++17 ct150cen.cpp -I ~/.local/include \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct150cen
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
#include <vector>
#include <algorithm>
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
static bool isCall(const any* e) {
  if (!e) return false;
  UHDM_OBJECT_TYPE t = e->UhdmType();
  return t == uhdmfunc_call || t == uhdmtask_call ||
         t == uhdmmethod_func_call || t == uhdmmethod_task_call ||
         t == uhdmsys_func_call || t == uhdmsys_task_call;
}
static long nargs(const any* e) {
  if (auto* c = any_cast<const tf_call*>(e))
    return c->Tf_call_args() ? (long)c->Tf_call_args()->size() : 0;
  return -1;
}
static bool bound(const any* e) {
  if (auto* f = any_cast<const func_call*>(e)) return f->Function() != nullptr;
  if (auto* t = any_cast<const task_call*>(e)) return t->Task() != nullptr;
  return false;
}
static bool hasPrefix(const any* e) {
  if (auto* m = any_cast<const method_func_call*>(e)) return m->Prefix() != nullptr;
  if (auto* m = any_cast<const method_task_call*>(e)) return m->Prefix() != nullptr;
  return false;
}
static bool inHierPath(const BaseClass* o) {
  const BaseClass* p = o ? o->VpiParent() : nullptr;
  return p && p->UhdmType() == uhdmhier_path;
}

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: ct150cen <db.uhdm> [--hp|--call|--all]\n"); return 2; }
  const std::string mode = argc > 2 ? argv[2] : "--all";
  Serializer s;
  if (s.Restore(std::string(argv[1])).empty()) {
    fprintf(stderr, "RESTORE_FAILED %s\n", argv[1]); return 3; }
  auto all = s.AllObjects();
  long nHp = 0, nHpCall = 0, nCall = 0;
  std::vector<std::string> rows;
  for (auto& pr : all) {
    const BaseClass* o = pr.first;
    if (!o) continue;
    UHDM_OBJECT_TYPE t = o->UhdmType();
    if (t == uhdmhier_path) {
      nHp++;
      auto* hp = (const hier_path*)o;
      auto* el = hp->Path_elems();
      size_t n = el ? el->size() : 0;
      bool any = false;
      for (size_t i = 0; i < n; i++) if (isCall(el->at(i))) any = true;
      if (!any) continue;
      nHpCall++;
      if (mode == "--call") continue;
      std::string sig;
      for (size_t i = 0; i < n; i++) {
        const UHDM::any* e = el->at(i);
        std::string en(e->VpiName());
        if (i) sig += ">";
        sig += kindName(e) + "/" + (en.empty() ? std::string("<anon>") : en);
        if (isCall(e)) sig += "(" + std::to_string(nargs(e)) + ")";
      }
      char line[16384];
      snprintf(line, sizeof line, "HP\t%s|%s\tNELEM=%zu\tSIG=%s",
               spanOf(o).c_str(),
               std::string(hp->VpiName()).c_str(), n, sig.c_str());
      rows.push_back(line);
      continue;
    }
    if (!isCall((const any*)o) || inHierPath(o)) continue;
    nCall++;
    if (mode == "--hp") continue;
    char line[16384];
    snprintf(line, sizeof line, "CALL\t%s|%s\tKIND=%s\tNARG=%ld\tBOUND=%d\tPFX=%d",
             spanOf(o).c_str(),
             std::string(o->VpiName()).c_str(), kindName(o).c_str(),
             nargs((const any*)o), (int)bound((const any*)o),
             (int)hasPrefix((const any*)o));
    rows.push_back(line);
  }
  std::sort(rows.begin(), rows.end());
  for (auto& l : rows) printf("%s\n", l.c_str());
  fprintf(stderr, "-- hier_path=%ld with-call-elem=%ld standalone-calls=%ld rows=%zu\n",
          nHp, nHpCall, nCall, rows.size());
  return 0;
}
