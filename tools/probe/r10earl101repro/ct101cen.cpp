// r10earl101 -- MEASUREMENT ONLY.  THE PACKAGE-TYPEDEF TYPESPEC CENSUS.
//
//   ct101cen <db.uhdm>
//
// For every ROOT (module_inst / interface_inst / package / program) it walks
// the typespec-bearing SITES -- ports, nets, variables, parameters, the root's
// own Typespecs listing, task_func io_decls / variables / returns, and struct
// members -- and, for each, the typespec CHAIN reached by FIELD PATH:
//
//   ts            the bound typespec itself
//   ts>a          its Typedef_alias -> Actual_typespec
//   ts>e          its Elem_typespec -> Actual_typespec
//   ts>e>a  ...   (depth 3)
//
// keyed TOP-DOWN by the field path, NEVER by VpiParent (the two producers park
// these objects on different parents and no generated Compare reads VpiParent).
//
// The payload is COMPARE-VISIBLE ONLY -- the fields typespec::Compare reads:
//   kind | VpiName | the vpiInstance's kind+name
// plus the span, so a cell names a source position.  It carries NO id and no
// fullname, so object identity and parenting are invisible to the scorer, as
// they are to the judge.
//
// A row is emitted ONLY when the chain ORIGINATES IN A PACKAGE TYPEDEF: some
// link's Instance() is a package, or its name carries "::".
//
// Row format (tab separated), one per (site, path):
//   SIG <view> <ownerkind> <ownerfullname> <site> <signal> <path> <payload>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>
#include <map>
#include <set>
#include <algorithm>
using namespace UHDM;

static std::vector<std::string> rows;

static std::string kn(const BaseClass *o) {
  return o ? std::string(UHDM::UhdmName(o->UhdmType())) : std::string("<null>");
}
static std::string nmv(const BaseClass *o) {
  if (!o) return "-";
  std::string n(((const any *)o)->VpiName());
  return n.empty() ? std::string("~") : n;
}
static std::string spn(const BaseClass *o) {
  if (!o) return "-";
  char b[64];
  snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(), o->VpiColumnNo(),
           o->VpiEndLineNo(), o->VpiEndColumnNo());
  return b;
}
static std::string basefile(const BaseClass *o) {
  if (!o) return "-";
  std::string f(o->VpiFile());
  size_t p = f.rfind('/');
  return p == std::string::npos ? f : f.substr(p + 1);
}

struct Chain {
  bool pkgOrigin = false;
  std::vector<std::pair<std::string, std::string>> links;  // path -> payload
};

static void walkTs(const typespec *ts, const std::string &path, int depth, Chain &out) {
  if (!ts || depth > 3) return;
  const BaseClass *inst = ts->Instance();
  std::string iname = inst ? kn(inst) + "[" + nmv(inst) + "]" : std::string("-");
  std::string name(ts->VpiName());
  if (inst && inst->UhdmType() == uhdmpackage) out.pkgOrigin = true;
  if (name.find("::") != std::string::npos) out.pkgOrigin = true;
  std::string payload = kn(ts) + "|" + (name.empty() ? "~" : name) + "|" + iname + "|" +
                        basefile(ts) + ":" + spn(ts);
  out.links.push_back({path, payload});
  if (const ref_typespec *al = ts->Typedef_alias())
    walkTs(al->Actual_typespec(), path + ">a", depth + 1, out);
  const ref_typespec *el = nullptr;
  switch (ts->UhdmType()) {
    case uhdmlogic_typespec: el = ((const logic_typespec *)ts)->Elem_typespec(); break;
    case uhdmarray_typespec: el = ((const array_typespec *)ts)->Elem_typespec(); break;
    case uhdmpacked_array_typespec: el = ((const packed_array_typespec *)ts)->Elem_typespec(); break;
    default: break;
  }
  if (el) walkTs(el->Actual_typespec(), path + ">e", depth + 1, out);
}

static void emit(const std::string &view, const BaseClass *root, const char *site,
                 const std::string &sig, const ref_typespec *rt) {
  if (!rt || !rt->Actual_typespec()) return;
  Chain c;
  walkTs(rt->Actual_typespec(), "ts", 0, c);
  if (!c.pkgOrigin) return;
  std::string rf;
  if (const scope *sc = any_cast<const scope *>((const any *)root)) rf = std::string(sc->VpiFullName());
  if (rf.empty()) rf = nmv(root);
  for (auto &l : c.links) {
    char b[4096];
    snprintf(b, sizeof b, "SIG\t%s\t%s\t%s\t%s\t%s\t%s\t%s", view.c_str(), kn(root).c_str(),
             rf.c_str(), site, sig.c_str(), l.first.c_str(), l.second.c_str());
    rows.push_back(b);
  }
}

static void doScope(const std::string &view, const BaseClass *root, const scope *sc) {
  if (!sc) return;
  if (sc->Typespecs())
    for (auto *t : *sc->Typespecs()) {
      Chain c;
      walkTs(t, "ts", 0, c);
      if (!c.pkgOrigin) continue;
      std::string rf(sc->VpiFullName());
      if (rf.empty()) rf = nmv(root);
      for (auto &l : c.links) {
        char b[4096];
        snprintf(b, sizeof b, "SIG\t%s\t%s\t%s\t%s\t%s\t%s\t%s", view.c_str(), kn(root).c_str(),
                 rf.c_str(), "LISTING", nmv(t).c_str(), l.first.c_str(), l.second.c_str());
        rows.push_back(b);
      }
    }
  if (sc->Variables())
    for (auto *v : *sc->Variables()) emit(view, root, "VAR", std::string(v->VpiName()), v->Typespec());
  if (sc->Param_assigns())
    for (auto *pa : *sc->Param_assigns()) {
      const any *l = pa->Lhs();
      if (l && l->UhdmType() == uhdmparameter)
        emit(view, root, "PARAM", std::string(l->VpiName()), ((const parameter *)l)->Typespec());
    }
  if (sc->Parameters())
    for (auto *p : *sc->Parameters())
      if (p->UhdmType() == uhdmparameter)
        emit(view, root, "PARAM", std::string(p->VpiName()), ((const parameter *)p)->Typespec());
  const instance *inx = any_cast<const instance *>((const any *)root);
  if (inx && inx->Task_funcs())
    for (auto *tf : *inx->Task_funcs()) {
      std::string tn(tf->VpiName());
      if (tf->Io_decls())
        for (auto *io : *tf->Io_decls()) emit(view, root, "FUNC_IO", tn + "." + std::string(io->VpiName()), io->Typespec());
      if (tf->Variables())
        for (auto *v : *tf->Variables()) emit(view, root, "FUNC_VAR", tn + "." + std::string(v->VpiName()), v->Typespec());
      if (tf->UhdmType() == uhdmfunction)
        if (const variables *rv = ((const function *)tf)->Return())
          emit(view, root, "FUNC_RET", tn, rv->Typespec());
    }
}

int main(int argc, char **argv) {
  if (argc < 2) { fprintf(stderr, "usage: ct101cen <db.uhdm>\n"); return 2; }
  Serializer s;
  auto r = s.Restore(std::string(argv[1]));
  if (r.empty()) { fprintf(stderr, "RESTORE_FAILED\n"); return 3; }

  // view: E for anything under a TopModules root, D otherwise.  Computed from
  // the design's own two lists, not from a name heuristic.
  std::set<const BaseClass *> defRoots;
  const design *dsn = nullptr;
  for (auto &pr : s.AllObjects()) if (pr.first && pr.first->UhdmType() == uhdmdesign) dsn = (const design *)pr.first;
  if (dsn && dsn->AllModules()) for (auto *m : *dsn->AllModules()) defRoots.insert(m);
  if (dsn && dsn->AllInterfaces()) for (auto *m : *dsn->AllInterfaces()) defRoots.insert(m);

  for (auto &pr : s.AllObjects()) {
    const BaseClass *o = pr.first;
    if (!o) continue;
    auto t = o->UhdmType();
    if (t != uhdmmodule_inst && t != uhdminterface_inst && t != uhdmpackage && t != uhdmprogram)
      continue;
    std::string view = (t == uhdmpackage) ? "P" : (defRoots.count(o) ? "D" : "E");
    const scope *sc = any_cast<const scope *>((const any *)o);
    doScope(view, o, sc);
    if (const instance *in = any_cast<const instance *>((const any *)o)) {
      if (in->Nets()) for (auto *n : *in->Nets()) emit(view, o, "NET", std::string(n->VpiName()), n->Typespec());
      if (in->Array_nets()) for (auto *n : *in->Array_nets()) emit(view, o, "ARRNET", std::string(n->VpiName()), n->Typespec());
    }
    if (t == uhdmmodule_inst) {
      const module_inst *m = (const module_inst *)o;
      if (m->Ports()) for (auto *p : *m->Ports()) emit(view, o, "PORT", std::string(p->VpiName()), p->Typespec());
    }
    if (t == uhdminterface_inst) {
      const interface_inst *m = (const interface_inst *)o;
      if (m->Ports()) for (auto *p : *m->Ports()) emit(view, o, "PORT", std::string(p->VpiName()), p->Typespec());
    }
  }
  std::sort(rows.begin(), rows.end());
  for (auto &l : rows) printf("%s\n", l.c_str());
  return 0;
}
