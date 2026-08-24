// r10earl82 — RANGE-BOUND CENSUS, read straight from a .uhdm database
// (never uhdm-dump: Earlgrey's dump is >1 GB and takes hours — the
// earl61-67/81 direct-reader rule).
//
// MEASUREMENT ONLY.  The official uhdm-cmp stays the sole judge.
//
// One line per RANGE SLOT (a range's Left_expr and its Right_expr):
//
//   RNG <chain> s=<slot> sp=<span> || K=<kind> <payload>
//
// * <chain> is the VpiParent walk (kinds + names, NO span).  It is what
//   separates the CONSUMERS this pass must key on — the DECLARATION-side copy
//   (`packed_array_var` / `array_var` / `logic_net` / `logic_var` ...) from the
//   TYPESPEC-side copy (`packed_array_typespec` / `logic_typespec` /
//   `array_typespec`) — and it separates the DEF listing from the ELABORATED
//   body by construction.  A second live copy under the same chain joins as a
//   multiset duplicate (RESUME §9: multiset joins, never a last-writer dict).
// * <span> LOCATES a cell; `nospan82.sh` strips it before scoring (earl60's
//   attrv60.py lesson — a span-carrying payload hides a flip inside
//   STILL-WRONG, and manufactures phantom AWAY cells wherever our spans differ
//   from golden's by a known law).
// * The payload carries ONLY fields the generated `Compare` reads
//   (constant: VpiType / VpiDecompile / VpiSize / Typespec / VpiConstType;
//   ref_obj: VpiName + whether Actual_group is bound and to what;
//   operation: VpiOpType) plus VpiValue, which the judge does NOT read but
//   which must follow the type.
//
//   build: g++ -O2 -std=c++17 rngcen82.cpp -I ~/.local/include \
//              -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o rngcen82
//   usage: rngcen82 <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/UhdmListener.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
#include <vector>
using namespace UHDM;

static std::string esc(std::string_view v) {
  std::string r;
  for (char c : v) r += (c == ' ' ? '_' : c);
  if (r.empty()) r = "-";
  return r;
}
static std::string tsKind(const ref_typespec* rt) {
  if (!rt) return "-";
  const typespec* at = rt->Actual_typespec();
  if (!at) return "REF_NO_ACTUAL";
  return std::string(UhdmName(at->UhdmType()));
}
static std::string chainOf(const any* o) {
  std::string r;
  const any* p = o->VpiParent();
  for (int i = 0; i < 40 && p; i++) {
    std::string e(UhdmName(p->UhdmType()));
    if (!p->VpiName().empty()) e += "(" + esc(p->VpiName()) + ")";
    r = r.empty() ? e : (e + "/" + r);
    p = p->VpiParent();
  }
  if (r.empty()) r = "-";
  return r;
}
static std::string spanOf(const any* o) {
  char b[256];
  std::string f(o->VpiFile());
  size_t sl = f.find_last_of('/');
  if (sl != std::string::npos) f = f.substr(sl + 1);
  if (f.empty()) f = "-";
  snprintf(b, sizeof b, "%s:%u:%hu-%u:%hu", f.c_str(), o->VpiLineNo(),
           o->VpiColumnNo(), o->VpiEndLineNo(), o->VpiEndColumnNo());
  return b;
}
static void payload(const any* e, char* pay, size_t n) {
  if (!e) { snprintf(pay, n, "K=<null>"); return; }
  std::string k(UhdmName(e->UhdmType()));
  switch (e->UhdmType()) {
    case uhdmconstant: {
      auto* c = (const constant*)e;
      snprintf(pay, n, "K=constant ct=%d sz=%d val=%s dec=%s ts=%s",
               c->VpiConstType(), c->VpiSize(), esc(c->VpiValue()).c_str(),
               esc(c->VpiDecompile()).c_str(), tsKind(c->Typespec()).c_str());
      break;
    }
    case uhdmref_obj: {
      auto* r = (const ref_obj*)e;
      const any* a = r->Actual_group();
      std::string ak = a ? std::string(UhdmName(a->UhdmType())) : std::string("-");
      std::string an = a ? esc(a->VpiName()) : std::string("-");
      snprintf(pay, n, "K=ref_obj nm=%s act=%s actnm=%s",
               esc(r->VpiName()).c_str(), ak.c_str(), an.c_str());
      break;
    }
    case uhdmoperation:
      snprintf(pay, n, "K=operation op=%d",
               ((const operation*)e)->VpiOpType());
      break;
    default:
      snprintf(pay, n, "K=%s nm=%s", k.c_str(), esc(e->VpiName()).c_str());
      break;
  }
}
// OUR ranges carry an EMPTY VpiFile (the same emitter fact RESUME §9 records
// for hier_paths), so the file is taken from the range and, failing that, from
// the BOUND EXPRESSION — and `score82.py` keys on the line/column part alone,
// never on the file, so a golden/ours file asymmetry can never manufacture a
// phantom cell.
static void row(const range* r, const char* slot, const any* e) {
  char pay[900];
  payload(e, pay, sizeof pay);
  std::string sp = spanOf(r);
  if (sp.compare(0, 2, "-:") == 0 && e) {
    std::string se = spanOf(e);
    size_t c = se.find(':');
    if (c != std::string::npos && se.compare(0, 2, "-:") != 0)
      sp = se.substr(0, c) + sp.substr(1);
  }
  printf("RNG %s s=%s sp=%s || %s\n", chainOf(r).c_str(), slot, sp.c_str(),
         pay);
}

struct Cen : public UhdmListener {
  void enterRange(const range* const o) final {
    row(o, "left", o->Left_expr());
    row(o, "right", o->Right_expr());
  }
};

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: rngcen82 <db.uhdm>\n"); return 2; }
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "EMPTY %s\n", argv[1]); return 3; }
  Cen c;
  for (vpiHandle h : restored) {
    const any* o = (const any*)((const uhdm_handle*)h)->object;
    if (auto* d = any_cast<const design*>(o)) c.listenDesign(d);
  }
  return 0;
}
