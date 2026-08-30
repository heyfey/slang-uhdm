// r10earl101 -- MEASUREMENT ONLY.  THE OWNER FINDER.
//
//   own101 <db.uhdm> <uhdmId> [<uhdmId> ...]
//
// For each named object id: every ref_typespec in the ARENA whose
// Actual_typespec is that object, and every typespec whose Typedef_alias
// resolves to it, each printed with its OWN parent chain (the ref_typespec's
// VpiParent IS the field owner in both producers -- verified against the
// uhdm-cmp head print, which shows `ref_typespec |vpiParent: \_logic_typespec`).
// Also: every scope whose Typespecs()/Typedefs() vector CONTAINS the object.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstdlib>
#include <string>
#include <vector>
#include <map>
#include <set>
#include <algorithm>
using namespace UHDM;

static std::string kn(const BaseClass *o) {
  return o ? std::string(UHDM::UhdmName(o->UhdmType())) : std::string("<null>");
}
static std::string nm(const BaseClass *o) {
  if (!o) return "-";
  std::string n(((const any *)o)->VpiName());
  return n.empty() ? std::string("~") : n;
}
static std::string sp(const BaseClass *o) {
  if (!o) return "-";
  char b[64];
  snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(), o->VpiColumnNo(),
           o->VpiEndLineNo(), o->VpiEndColumnNo());
  return b;
}
static std::string fn(const BaseClass *o) {
  if (!o) return "";
  const any *a = (const any *)o;
  if (const scope *x = any_cast<const scope *>(a)) return std::string(x->VpiFullName());
  if (const nets *x = any_cast<const nets *>(a)) return std::string(x->VpiFullName());
  if (const variables *x = any_cast<const variables *>(a)) return std::string(x->VpiFullName());
  if (const parameter *x = any_cast<const parameter *>(a)) return std::string(x->VpiFullName());
  if (const ref_obj *x = any_cast<const ref_obj *>(a)) return std::string(x->VpiFullName());
  if (const ref_typespec *x = any_cast<const ref_typespec *>(a)) return std::string(x->VpiFullName());
  return "";
}
static std::string chain(const BaseClass *o, int depth) {
  std::string c;
  int n = 0;
  for (const BaseClass *p = o ? o->VpiParent() : nullptr; p && n < depth; p = p->VpiParent(), ++n) {
    c += " <- " + kn(p) + "[" + nm(p) + "]";
    std::string f = fn(p);
    if (!f.empty() && f != nm(p)) c += "{" + f + "}";
    c += "@" + sp(p) + "#" + std::to_string(p->UhdmId());
  }
  return c.empty() ? std::string(" <- <null>") : c;
}
static std::string tsinfo(const BaseClass *o) {
  const typespec *ts = any_cast<const typespec *>((const any *)o);
  if (!ts) return "";
  std::string s;
  const ref_typespec *al = ts->Typedef_alias();
  s += " ALIAS=";
  if (al && al->Actual_typespec())
    s += nm(al->Actual_typespec()) + "#" + std::to_string(al->Actual_typespec()->UhdmId());
  else
    s += "-";
  s += " INST=";
  s += ts->Instance() ? kn(ts->Instance()) + "[" + nm(ts->Instance()) + "#" +
                            std::to_string(ts->Instance()->UhdmId()) + "]"
                      : std::string("-");
  return s;
}

int main(int argc, char **argv) {
  if (argc < 3) { fprintf(stderr, "usage: own101 <db.uhdm> <id>...\n"); return 2; }
  Serializer s;
  auto r = s.Restore(std::string(argv[1]));
  if (r.empty()) { fprintf(stderr, "RESTORE_FAILED\n"); return 3; }
  std::set<uint32_t> want;
  for (int i = 2; i < argc; ++i) want.insert((uint32_t)atoi(argv[i]));

  std::map<uint32_t, const BaseClass *> byId;
  std::vector<const BaseClass *> all;
  for (auto &pr : s.AllObjects()) if (pr.first) { all.push_back(pr.first); byId[pr.first->UhdmId()] = pr.first; }

  for (uint32_t id : want) {
    const BaseClass *t = byId.count(id) ? byId[id] : nullptr;
    if (!t) { printf("=== id %u NOT FOUND\n", id); continue; }
    printf("=== OBJ #%u %s name=%s span=%s%s\n     SELFPAR%s\n", id, kn(t).c_str(), nm(t).c_str(),
           sp(t).c_str(), tsinfo(t).c_str(), chain(t, 8).c_str());
    int nref = 0, nal = 0, nlist = 0;
    for (const BaseClass *o : all) {
      if (o->UhdmType() == uhdmref_typespec) {
        const ref_typespec *rt = (const ref_typespec *)o;
        if (rt->Actual_typespec() == t) {
          const BaseClass *p = rt->VpiParent();
          bool isAlias = false;
          if (p) {
            const typespec *pts = any_cast<const typespec *>((const any *)p);
            if (pts && pts->Typedef_alias() == rt) isAlias = true;
          }
          printf("  %s ref#%-8u full=%-34s%s\n", isAlias ? "ALIASREF" : "REF     ", o->UhdmId(),
                 fn(o).c_str(), chain(o, 7).c_str());
          if (isAlias) nal++; else nref++;
        }
      }
      // scope Typespecs / Typedefs listings
      if (const scope *sc = any_cast<const scope *>((const any *)o)) {
        if (sc->Typespecs()) for (auto *x : *sc->Typespecs()) if ((const BaseClass *)x == t) {
          printf("  LISTED-Typespecs in %s[%s]{%s}#%u\n", kn(o).c_str(), nm(o).c_str(), fn(o).c_str(), o->UhdmId()); nlist++;
        }
      }
      if (const instance *in = any_cast<const instance *>((const any *)o)) {
        if (in->Typespecs()) for (auto *x : *in->Typespecs()) if ((const BaseClass *)x == t) { (void)x; }
      }
    }
    printf("  TOTALS refs=%d aliasrefs=%d listings=%d\n", nref, nal, nlist);
  }
  return 0;
}
