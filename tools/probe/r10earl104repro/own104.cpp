// r10earl102 -- MEASUREMENT ONLY.  THE RANGE-OWNER FINDER.
//
//   own102 <db.uhdm> <uhdmId> [<uhdmId> ...]
//
// For each named object id (a `range`, or any object), print:
//   * the object itself, its span and its VpiParent chain;
//   * EVERY object in the arena whose Ranges() vector CONTAINS it -- scanned
//     over every UHDM class that declares a `Ranges()` accessor (the 16 the
//     headers list), each printed with its own parent chain;
//   * every object whose Left_expr/Right_expr IS it (for a bound expression).
// The parent chain is a HINT; the CONTAINING VECTOR is the field the judge
// walks, so both are printed and the count of containers is asserted.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstdlib>
#include <string>
#include <vector>
#include <map>
#include <set>
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
  std::string c; int n = 0;
  for (const BaseClass *p = o ? o->VpiParent() : nullptr; p && n < depth; p = p->VpiParent(), ++n) {
    c += " <- " + kn(p) + "[" + nm(p) + "]";
    std::string f = fn(p);
    if (!f.empty() && f != nm(p)) c += "{" + f + "}";
    c += "@" + sp(p) + "#" + std::to_string(p->UhdmId());
  }
  return c.empty() ? std::string(" <- <null>") : c;
}

static const VectorOfrange *rangesOf(const BaseClass *o) {
  const any *a = (const any *)o;
#define TRY(T) if (const T *x = any_cast<const T *>(a)) return x->Ranges();
  TRY(array_net) TRY(array_var) TRY(array_typespec) TRY(bit_var)
  TRY(instance_array) TRY(int_typespec) TRY(packed_array_typespec)
  TRY(packed_array_net) TRY(logic_var) TRY(io_decl) TRY(logic_typespec)
  TRY(packed_array_var) TRY(parameter) TRY(unsupported_typespec)
  TRY(logic_net) TRY(bit_typespec)
#undef TRY
  return nullptr;
}

int main(int argc, char **argv) {
  if (argc < 3) { fprintf(stderr, "usage: own102 <db.uhdm> <id>...\n"); return 2; }
  Serializer s;
  auto r = s.Restore(std::string(argv[1]));
  if (r.empty()) { fprintf(stderr, "RESTORE_FAILED\n"); return 3; }
  std::set<uint32_t> want;
  for (int i = 2; i < argc; ++i) want.insert((uint32_t)atoi(argv[i]));
  std::map<uint32_t, const BaseClass *> byId;
  std::vector<const BaseClass *> all;
  for (auto &pr : s.AllObjects()) if (pr.first) { all.push_back(pr.first); byId[pr.first->UhdmId()] = pr.first; }
  fprintf(stderr, "ARENA %zu objects\n", all.size());

  for (uint32_t id : want) {
    const BaseClass *t = byId.count(id) ? byId[id] : nullptr;
    if (!t) { printf("=== id %u NOT FOUND\n", id); continue; }
    printf("=== OBJ #%u %s name=%s span=%s file=%s\n     SELFPAR%s\n", id, kn(t).c_str(),
           nm(t).c_str(), sp(t).c_str(), std::string(t->VpiFile()).c_str(), chain(t, 8).c_str());
    if (const range *rg = any_cast<const range *>((const any *)t)) {
      const expr *le = rg->Left_expr(), *re = rg->Right_expr();
      printf("     LEFT  %s#%u %s\n", kn(le).c_str(), le ? le->UhdmId() : 0, sp(le).c_str());
      printf("     RIGHT %s#%u %s\n", kn(re).c_str(), re ? re->UhdmId() : 0, sp(re).c_str());
    }
    int nc = 0, nb = 0;
    for (const BaseClass *o : all) {
      if (const VectorOfrange *rs = rangesOf(o))
        for (auto *x : *rs) if ((const BaseClass *)x == t) {
          printf("  CONTAINER %s[%s]{%s}@%s#%u%s\n", kn(o).c_str(), nm(o).c_str(),
                 fn(o).c_str(), sp(o).c_str(), o->UhdmId(), chain(o, 6).c_str());
          nc++;
        }
      if (o->UhdmType() == uhdmref_typespec) {
        const ref_typespec *rt = (const ref_typespec *)o;
        if ((const BaseClass *)rt->Actual_typespec() == t) {
          printf("  TSREF     ref#%-8u full=%-30s%s\n", o->UhdmId(), fn(o).c_str(), chain(o, 7).c_str());
          nc++;
        }
      }
      if (const range *rg2 = any_cast<const range *>((const any *)o)) {
        if ((const BaseClass *)rg2->Left_expr() == t || (const BaseClass *)rg2->Right_expr() == t) {
          printf("  BOUNDOF   range#%u @%s%s\n", o->UhdmId(), sp(o).c_str(), chain(o, 6).c_str());
          nb++;
        }
      }
    }
    printf("  TOTALS containers=%d boundof=%d\n", nc, nb);
  }
  return 0;
}
