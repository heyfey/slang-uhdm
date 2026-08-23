// r10earl76 — QUESTION 1: what IS golden's `enum_const`?
//
// A flat `Serializer::AllObjects` walk (NOT the listener route cscen76 takes)
// that answers, for one database:
//   * every `enum_const` object: its judged fields, its VpiParent chain, its
//     span, and HOW MANY `ref_obj`s bind to it (`Actual_group`), so a SHARED
//     object and a per-reference clone are distinguishable;
//   * every `ref_obj` whose `Actual_group` is an `enum_const`: the ref's
//     fullname and span and the target's identity.
// MEASUREMENT ONLY; the official uhdm-cmp is the judge.
//   build: g++ -O2 -std=c++17 ecprobe76.cpp -I ~/.local/include \
//              -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ecprobe76
//   usage: ecprobe76 <db.uhdm> [name-substring]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/Serializer.h>
#include <cstdio>
#include <cstring>
#include <map>
#include <string>
using namespace UHDM;
static std::string esc(std::string_view v) {
  std::string r;
  for (char c : v) r += (c == ' ' ? '_' : c);
  if (r.empty()) r = "-";
  return r;
}
static std::string base(std::string_view f) {
  std::string s(f);
  size_t sl = s.find_last_of('/');
  if (sl != std::string::npos) s = s.substr(sl + 1);
  if (s.empty()) s = "-";
  return s;
}
static std::string span(const any* o) {
  char b[256];
  snprintf(b, sizeof b, "%s:%u:%u-%u:%u", base(o->VpiFile()).c_str(),
           o->VpiLineNo(), o->VpiColumnNo(), o->VpiEndLineNo(),
           o->VpiEndColumnNo());
  return b;
}
static std::string chainOf(const any* o) {
  std::string r;
  const any* p = o->VpiParent();
  for (int i = 0; i < 40 && p; i++) {
    std::string e(UhdmName(p->UhdmType()).data());
    if (!p->VpiName().empty()) e += "(" + esc(p->VpiName()) + ")";
    r = r.empty() ? e : (e + "/" + r);
    p = p->VpiParent();
  }
  if (r.empty()) r = "<UNPARENTED>";
  return r;
}
int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: ecprobe76 <db.uhdm> [substr]\n"); return 2; }
  const char* want = argc > 2 ? argv[2] : nullptr;
  Serializer s;
  if (s.Restore(std::string(argv[1])).empty()) { fprintf(stderr, "EMPTY\n"); return 3; }
  std::map<const any*, int> binders;
  for (const auto& [obj, id] : s.AllObjects()) {
    if (const ref_obj* r = any_cast<const ref_obj*>(obj))
      if (const any* a = r->Actual_group())
        if (a->UhdmType() == uhdmenum_const) binders[a]++;
  }
  int nec = 0;
  for (const auto& [obj, id] : s.AllObjects()) {
    const enum_const* e = any_cast<const enum_const*>(obj);
    if (!e) continue;
    nec++;
    if (want && std::string(e->VpiName()).find(want) == std::string::npos) continue;
    printf("EC name=%s val=%s dec=%s sz=%d span=%s binders=%d parent=%s\n",
           esc(e->VpiName()).c_str(), esc(e->VpiValue()).c_str(),
           esc(e->VpiDecompile()).c_str(), e->VpiSize(), span(e).c_str(),
           binders.count(e) ? binders[e] : 0, chainOf(e).c_str());
  }
  for (const auto& [obj, id] : s.AllObjects()) {
    const ref_obj* r = any_cast<const ref_obj*>(obj);
    if (!r) continue;
    const any* a = r->Actual_group();
    if (!a || a->UhdmType() != uhdmenum_const) continue;
    if (want && std::string(r->VpiName()).find(want) == std::string::npos) continue;
    const enum_const* e = (const enum_const*)a;
    printf("RB ref=%s full=%s span=%s -> ec name=%s val=%s sz=%d ecspan=%s "
           "ecparent=%s binders=%d refparent=%s\n",
           esc(r->VpiName()).c_str(), esc(r->VpiFullName()).c_str(),
           span(r).c_str(), esc(e->VpiName()).c_str(),
           esc(e->VpiValue()).c_str(), e->VpiSize(), span(e).c_str(),
           chainOf(e).c_str(), binders[e], chainOf(r).c_str());
  }
  fprintf(stderr, "TOTAL enum_const=%d bound-distinct=%zu\n", nec, binders.size());
  return 0;
}
