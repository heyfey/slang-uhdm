// (r11u271: copied from r11u269repro/drivers)
// r11u269 idobj: print every object of a UHDM database with its serializer id, kind, name, line:col, parent id,
// and the id its reference points at (ref_obj / ref_typespec / ref_module Actual, typespec_member Typespec,
// packed_array_typespec / array_typespec Elem_typespec): identity, which neither uhdm-dump nor the strict walk shows.
// (r11u271: par, tgt and alias are UhdmIds; a typespec also prints alias=<the id of its Typedef_alias ref_typespec> and its file basename.)
// usage: idobj <db.uhdm>   Fail-closed on $FENCED (4 names; a path naming one is refused).
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <uhdm/vpi_visitor.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <sstream>
#include <string>
using namespace UHDM;
int main(int argc, char** argv) {
  const char* f = getenv("FENCED");
  if (!f || argc < 2) { fprintf(stderr, "idobj: FENCED unset or no db\n"); return 2; }
  std::istringstream is(f); std::string n; int k = 0;
  while (is >> n) { ++k; std::string p = argv[1];
    for (size_t pos = p.find(n); pos != std::string::npos; pos = p.find(n, pos + 1)) {
      bool l = pos == 0 || !isalnum((unsigned char)p[pos - 1]); size_t e = pos + n.size();
      bool r = e >= p.size() || !isalnum((unsigned char)p[e]);
      if (l && r) { fprintf(stderr, "idobj: fenced path refused\n"); return 2; } } }
  if (k != 4) { fprintf(stderr, "idobj: FENCED not 4 names\n"); return 2; }
  Serializer s; s.Restore(std::string(argv[1]));
  auto ids = s.AllObjects();
  auto id = [&](const BaseClass* o) -> long { if (!o) return -1; return (long)o->UhdmId(); };  // r11u271: par/tgt/alias by UhdmId (the serializer index is per kind)
  for (auto& [o, i] : ids) {
    const any* a = (const any*)o;
    const BaseClass* tgt = nullptr;
    switch (a->UhdmType()) {
      case uhdmref_obj: tgt = ((const ref_obj*)a)->Actual_group(); break;
      case uhdmref_typespec: tgt = ((const ref_typespec*)a)->Actual_typespec(); break;
      case uhdmtypespec_member: tgt = ((const typespec_member*)a)->Typespec(); break;
      case uhdmpacked_array_typespec: tgt = ((const packed_array_typespec*)a)->Elem_typespec(); break;
      case uhdmarray_typespec: tgt = ((const array_typespec*)a)->Elem_typespec(); break;
      default: break;
    }
    const any* p = a->VpiParent();
    long al = -1;
    if (auto* t = any_cast<const typespec*>(a)) al = id(t->Typedef_alias());
    std::string fb(a->VpiFile()); if (auto sl = fb.rfind('/'); sl != std::string::npos) fb = fb.substr(sl + 1);
    printf("%u\tuid=%u\t%s\t%s\t%u:%u\tpar=%ld\t%s\ttgt=%ld\t%s\talias=%ld\t%s\n", i, a->UhdmId(), UhdmName(a->UhdmType()).data(), std::string(a->VpiName()).c_str(),
           a->VpiLineNo(), a->VpiColumnNo(), id(p), p ? UhdmName(p->UhdmType()).data() : "-", id(tgt), tgt ? UhdmName(((const any*)tgt)->UhdmType()).data() : "-", al, fb.c_str());
  }
}
