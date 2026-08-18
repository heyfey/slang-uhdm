// r10rgg17/hpcensus17.cpp — MEASUREMENT ONLY.  The official uhdm-cmp is judge.
//
// THE CENSUS THIS PASS IS DECIDED BY: every `hier_path` in a database, with the
// Compare-VISIBLE payload of the object and of every one of its Path_elems.
//
// `hier_path::Compare` (UHDM/build/generated/src/hier_path.cpp:110) reads, in
// order:  basetype expr::Compare  ->  BaseClass::Compare (VpiType, VpiName,
// VpiDefName), then VpiDecompile, VpiSize, Typespec;  then Path_elems (the
// VECTOR SafeCompare: size first, then element by element);  then Root_value;
// then VpiName a SECOND time.  So VpiName is read FIRST, inside
// BaseClass::Compare — before any element is looked at.  Every field this
// census prints is one of those; NO span and NO fullname is in the payload,
// because no generated Compare reads either.
//
// The span (file:line:col) IS printed, in the KEY only, as the cross-side
// OBJECT IDENTITY for the multiset join — the same use r10rgg14 made of it.
//
// Objects are enumerated by UhdmListener::listenDesign — the REACHABLE walk that
// uhdm-dump makes (AllObjects also returns the weakly-referenced TAIL; see the
// REACHABILITY note at line ~127).  Each hier_path is classified by
// walking VpiParent to the root: ROOT is the root ancestor's full name, which
// separates the DEF listing (root == the def module itself) from the ELABORATED
// one (root == the top instance) without trusting a path string.
//
// TRAP (r10rgg11/12/13/15/16): UhdmName()/Vpi*() return string_views; handing
// one to printf("%s") writes raw bytes plus NULs and turns the census file
// BINARY, after which grep prints nothing.  Everything is materialised first.
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/UhdmListener.h>
#include <cstdio>
#include <string>
#include <vector>
#include <map>
#include <algorithm>

using namespace UHDM;

static std::string S(std::string_view v) { return std::string(v); }
static std::string kindOf(const any* o) {
  return o ? S(UhdmName(o->UhdmType())) : std::string("-");
}
static std::string fullOf(const any* o) {
  if (!o) return "-";
  std::string f;
  if (auto* sc = any_cast<const scope*>(o)) f = S(sc->VpiFullName());
  else if (auto* ro = any_cast<const ref_obj*>(o)) f = S(ro->VpiFullName());
  else if (auto* hp = any_cast<const hier_path*>(o)) f = S(hp->VpiFullName());
  else if (auto* nt = any_cast<const nets*>(o)) f = S(nt->VpiFullName());
  else if (auto* vr = any_cast<const variables*>(o)) f = S(vr->VpiFullName());
  else if (auto* ia = any_cast<const instance_array*>(o)) f = S(ia->VpiFullName());
  else if (auto* ga = any_cast<const gen_scope_array*>(o)) f = S(ga->VpiFullName());
  if (f.empty()) f = S(o->VpiName());
  if (f.empty()) f = kindOf(o);
  return f;
}

// The Compare-visible encoding of an arbitrary sub-expression.
static std::string enc(const any* e, int depth = 0) {
  if (!e) return "<null>";
  if (depth > 6) return "...";
  switch (e->UhdmType()) {
    case uhdmconstant: {
      auto* c = (const constant*)e;
      char b[512];
      snprintf(b, sizeof b, "C{%s,sz%d,ct%d,d=%s}", S(c->VpiValue()).c_str(),
               (int)c->VpiSize(), (int)c->VpiConstType(),
               S(c->VpiDecompile()).c_str());
      return b;
    }
    case uhdmref_obj: return "R{" + S(((const ref_obj*)e)->VpiName()) + "}";
    case uhdmoperation: {
      auto* o = (const operation*)e;
      std::string r = "O" + std::to_string(o->VpiOpType()) + "(";
      if (auto* ops = o->Operands())
        for (size_t i = 0; i < ops->size(); i++)
          r += (i ? "," : "") + enc(ops->at(i), depth + 1);
      return r + ")";
    }
    case uhdmbit_select: {
      auto* b = (const bit_select*)e;
      return "BS{" + S(b->VpiName()) + ",i=" + enc(b->VpiIndex(), depth + 1) + "}";
    }
    case uhdmpart_select: {
      auto* p = (const part_select*)e;
      return "PS{" + S(p->VpiName()) + ",cs" +
             std::to_string(p->VpiConstantSelect()) + ",l=" +
             enc(p->Left_range(), depth + 1) + ",r=" +
             enc(p->Right_range(), depth + 1) + "}";
    }
    case uhdmindexed_part_select: {
      auto* p = (const indexed_part_select*)e;
      return "IPS{" + S(p->VpiName()) + ",cs" +
             std::to_string(p->VpiConstantSelect()) + ",t" +
             std::to_string(p->VpiIndexedPartSelectType()) + ",b=" +
             enc(p->Base_expr(), depth + 1) + ",w=" +
             enc(p->Width_expr(), depth + 1) + "}";
    }
    case uhdmvar_select: {
      auto* v = (const var_select*)e;
      std::string r = "VS{" + S(v->VpiName()) + ",[";
      if (auto* xs = v->Exprs())
        for (size_t i = 0; i < xs->size(); i++)
          r += (i ? "," : "") + enc(xs->at(i), depth + 1);
      return r + "]}";
    }
    case uhdmhier_path: {
      auto* h = (const hier_path*)e;
      std::string r = "HP{" + S(h->VpiName()) + ",[";
      if (auto* xs = h->Path_elems())
        for (size_t i = 0; i < xs->size(); i++)
          r += (i ? "," : "") + enc(xs->at(i), depth + 1);
      return r + "]}";
    }
    default: {
      return kindOf(e) + "{" + S(e->VpiName()) + "}";
    }
  }
}

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: hpcensus17 <db.uhdm> [tag]\n"); return 2; }
  const char* tag = argc > 2 ? argv[2] : "";
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "EMPTY %s\n", argv[1]); return 3; }
  // REACHABILITY.  Serializer::AllObjects() also returns the WEAKLY-REFERENCED
  // TAIL — objects in the arena that no relation reaches, which uhdm-dump does
  // not print and the judge never compares (RESUME §9).  On Rggen that tail
  // holds 156 of our port-actual hier_paths, so a census over AllObjects
  // MANUFACTURES 156 phantom "ours-only" keys.  The population is therefore
  // taken from UhdmListener::listenDesign, the same reachable walk uhdm-dump
  // makes, and AllObjects is used only to COUNT the tail.
  struct HpCollect final : public UhdmListener {
    std::vector<const hier_path*> hps;
    std::set<const void*> once;   // the listener reaches one object through
                                  // SEVERAL relations (High_conn, Actual, ...)
    void enterHier_path(const hier_path* const o) override {
      if (once.insert(o).second) hps.push_back(o);
    }
  } coll;
  size_t arenaHp = 0;
  for (auto& [obj, id] : s.AllObjects())
    if (obj && obj->UhdmType() == uhdmhier_path) arenaHp++;
  for (auto h : restored)
    coll.listenDesign((design*)((uhdm_handle*)h)->object);
  std::vector<std::string> rows;
  for (auto* hp : coll.hps) {
    const BaseClass* obj = hp;
    const any* par = hp->VpiParent();
    const any* own = par ? par->VpiParent() : nullptr;
    const BaseClass* root = obj;
    for (int g = 0; g < 64 && root->VpiParent(); g++) root = root->VpiParent();
    // The nearest ancestor that HAS a full name: without it a key like
    // `OWN=operation PAR=operation AT=68:49` collapses all 45 gen-scope copies
    // of one cont_assign into ONE key and the join reports a phantom
    // multiplicity mismatch (measured: 10 "families" of which 6 were this).
    std::string scpath = "-";
    for (const BaseClass* a = hp->VpiParent(); a; a = a->VpiParent()) {
      if (auto* sc = any_cast<const scope*>(a)) {
        std::string f = S(sc->VpiFullName());
        if (!f.empty()) { scpath = f; break; }
      }
    }
    std::string key = std::string(tag) + "\tROOT=" + fullOf(root) +
                      "\tSCOPE=" + scpath +
                      "\tOWN=" + kindOf(own) + ":" + fullOf(own) +
                      "\tPAR=" + kindOf(par) + ":" + (par ? S(par->VpiName()) : std::string()) +
                      "\tAT=" +
                      std::to_string(hp->VpiLineNo()) + ":" +
                      std::to_string(hp->VpiColumnNo()) + "-" +
                      std::to_string(hp->VpiEndLineNo()) + ":" +
                      std::to_string(hp->VpiEndColumnNo());
    std::string pay = "HPNAME=" + S(hp->VpiName()) +
                      "\tHPDEF=" + S(hp->VpiDefName()) +
                      "\tHPDEC=" + S(hp->VpiDecompile()) +
                      "\tHPSZ=" + std::to_string(hp->VpiSize()) +
                      "\tRV=" + (hp->Root_value() ? kindOf(hp->Root_value()) : "-") +
                      "\tNEL=";
    auto* els = hp->Path_elems();
    pay += std::to_string(els ? els->size() : 0);
    if (els)
      for (size_t i = 0; i < els->size(); i++)
        pay += "\tE" + std::to_string(i) + "=" + kindOf(els->at(i)) + "|" +
               enc(els->at(i));
    rows.push_back(key + "\t||\t" + pay);
  }
  std::sort(rows.begin(), rows.end());
  for (auto& r : rows) printf("%s\n", r.c_str());
  fprintf(stderr, "hier_paths_reachable=%zu arena_hier_paths=%zu unreachable_tail=%zu\n",
          rows.size(), arenaHp,
          arenaHp > coll.hps.size() ? arenaHp - coll.hps.size() : 0);
  return 0;
}
