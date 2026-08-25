// r10earl88 — GATE-REACHABLE reader.  For every packed_array_net / packed_array_var
// in one database, print the owner, the signal, the element kind, the element
// struct typespec NAME, and the two member scans:
//   LOOSE  = elab_signal_'s struct arm (member typespec is logic OR struct)
//   STRICT = SURELOG::Struct::isNet() (EVERY member typespec is logic)
// The law this pass writes swaps LOOSE for STRICT on the PACKED-DIM arm, so
// LOOSE=1 STRICT=0 is exactly the set that moves.  MEASUREMENT ONLY.
//   usage: pareach88 <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/Serializer.h>
#include <cstdio>
#include <string>
#include <vector>
using namespace UHDM;

static int scan(const typespec* ts, bool strict) {
  if (!ts || ts->UhdmType() != uhdmstruct_typespec) return strict ? 0 : 1;
  const struct_typespec* s = (const struct_typespec*)ts;
  if (!s->Members()) return 1;
  for (auto* m : *s->Members()) {
    const ref_typespec* rt = m->Typespec();
    if (!rt) { if (strict) return 0; else continue; }
    const typespec* a = rt->Actual_typespec();
    if (!a) { if (strict) return 0; else continue; }
    UHDM_OBJECT_TYPE k = a->UhdmType();
    if (strict) { if (k != uhdmlogic_typespec) return 0; }
    else { if (k != uhdmlogic_typespec && k != uhdmstruct_typespec) return 0; }
  }
  return 1;
}
static const typespec* elemTs(const any* e) {
  if (const variables* v = any_cast<const variables*>(e))
    return v->Typespec() ? v->Typespec()->Actual_typespec() : nullptr;
  if (const net* n = any_cast<const net*>(e))
    return n->Typespec() ? n->Typespec()->Actual_typespec() : nullptr;
  return nullptr;
}
static void emit(const char* ownerKind, const std::string& owner,
                 const char* cont, const any* o) {
  const std::vector<any*>* els = nullptr;
  std::string nm;
  if (const packed_array_var* p = any_cast<const packed_array_var*>(o)) {
    els = p->Elements(); nm = p->VpiName();
  } else if (const packed_array_net* p = any_cast<const packed_array_net*>(o)) {
    els = p->Elements(); nm = p->VpiName();
  } else return;
  const any* e = (els && !els->empty()) ? (*els)[0] : nullptr;
  const typespec* ts = e ? elemTs(e) : nullptr;
  printf("%s|%s|%s|%s|%s|ELEM=%s|ETS=%s|LOOSE=%d|STRICT=%d\n", ownerKind,
         owner.c_str(), nm.c_str(), cont, UhdmName(o->UhdmType()).data(),
         e ? UhdmName(e->UhdmType()).data() : "-",
         ts ? (std::string(UhdmName(ts->UhdmType())) + "/" +
               (std::string(ts->VpiName()).empty() ? std::string("<anon>")
                                                   : std::string(ts->VpiName()))).c_str()
            : "-",
         scan(ts, false), scan(ts, true));
}
int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: pareach88 <db>\n"); return 2; }
  Serializer s;
  if (s.Restore(std::string(argv[1])).empty()) { fprintf(stderr, "EMPTY\n"); return 3; }
  for (const auto& [obj, id] : s.AllObjects()) {
    std::string owner; const char* ok = nullptr;
    const std::vector<net*>* nets = nullptr;
    const std::vector<variables*>* vars = nullptr;
    if (const module_inst* m = any_cast<const module_inst*>(obj)) {
      owner = m->VpiFullName(); ok = "module_inst"; nets = m->Nets(); vars = m->Variables();
    } else if (const gen_scope* g = any_cast<const gen_scope*>(obj)) {
      owner = g->VpiFullName(); ok = "gen_scope"; nets = g->Nets(); vars = g->Variables();
    } else if (const interface_inst* i = any_cast<const interface_inst*>(obj)) {
      owner = i->VpiFullName(); ok = "interface_inst"; nets = i->Nets(); vars = i->Variables();
    } else continue;
    if (nets) for (auto* n : *nets) emit(ok, owner, "NET", n);
    if (vars) for (auto* v : *vars) emit(ok, owner, "VAR", v);
  }
  return 0;
}
