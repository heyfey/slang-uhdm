// r10earl81 — SELECT INDEX / BOUND CENSUS, read straight from a .uhdm database
// (never uhdm-dump: Earlgrey's dump is >1 GB and takes hours — the earl61-67
// direct-reader rule).
//
// MEASUREMENT ONLY.  The official uhdm-cmp stays the sole judge.
//
// One line per SELECT SLOT (a bit_select's VpiIndex, a part_select's
// Left_range / Right_range, an indexed_part_select's Base_expr / Width_expr):
//
//   SEL <chain> k=<selkind> s=<slot> b=<base> sp=<span> || K=<kind> <payload>
//
// * <chain> is the VpiParent walk (kinds + names, NO span), so the DEF listing
//   and the ELABORATED body separate by construction, the POSITION (a port
//   High_conn / a cont_assign / a process) is readable straight off it, and a
//   second live copy under the same chain joins as a multiset duplicate
//   (RESUME §9: multiset joins, never a last-writer dict).
// * <span> is carried for LOCATING a cell only; `nospan81.sh` strips it before
//   scoring (earl60's attrv60.py lesson: a span-carrying payload hides flips
//   inside STILL-WRONG, and our spans differ from golden's on rvalue selects
//   by a known law, which would manufacture phantom AWAY cells).
// * The payload carries ONLY fields the generated Compare reads (constant:
//   VpiType/VpiDecompile/VpiSize/Typespec/VpiConstType; ref_obj: VpiName and
//   whether Actual_group is bound and to what; operation: VpiOpType) plus
//   VpiValue, which the judge does NOT read but which must follow the type.
//
//   build: g++ -O2 -std=c++17 selcen81.cpp -I ~/.local/include \
//              -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o selcen81
//   usage: selcen81 <db.uhdm>
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
static void row(const any* sel, const char* kind, const char* slot,
                const any* e) {
  char pay[900];
  payload(e, pay, sizeof pay);
  printf("SEL %s k=%s s=%s b=%s sp=%s || %s\n", chainOf(sel).c_str(), kind,
         slot, esc(sel->VpiName()).c_str(), spanOf(sel).c_str(), pay);
}

struct Cen : public UhdmListener {
  void enterBit_select(const bit_select* const o) final {
    row(o, "bit_select", "idx", o->VpiIndex());
  }
  void enterPart_select(const part_select* const o) final {
    row(o, "part_select", "left", o->Left_range());
    row(o, "part_select", "right", o->Right_range());
  }
  void enterIndexed_part_select(const indexed_part_select* const o) final {
    row(o, "ips", "base", o->Base_expr());
    row(o, "ips", "width", o->Width_expr());
  }
};

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: selcen81 <db.uhdm>\n"); return 2; }
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
