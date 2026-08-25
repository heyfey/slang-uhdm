// r10uvm127 — CALL-ARGUMENT TYPESPEC CENSUS.  MEASUREMENT ONLY.
// The official uhdm-cmp stays the sole acceptance judge.
//
// One row per ARGUMENT of every tf_call the UhdmListener reaches:
//   CALL   = call kind + name              CID = the call's UhdmId
//   BOUND  = the callee the call is bound to (vpiFunction/vpiTask), or '-'
//   IDX    = argument position
//   AKIND  = the argument object's kind     ASPAN = its span   AID = its id
//   ANAME  = the argument's VpiName
//   ATS    = the argument's ref_typespec ACTUAL kind (or 'none')
//   ATSID  = the ACTUAL typespec's UhdmId (id-identity decides sharing)
//   ATSSPAN= the ACTUAL typespec's span
//   RTSID  = the ref_typespec's own UhdmId
//   ACT    = the argument's vpiActual kind (+ name)
//   ACTTS  = the vpiActual's own ref_typespec ACTUAL kind / id / span
//   FML    = the callee's formal at IDX: name / direction / typespec kind / id / span
//   PATH   = the listener callstack (kinds+names, no spans)
//
//   build: g++ -O2 -std=c++17 ct127cen.cpp -I ~/.local/include \
//              -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct127cen
//   usage: ct127cen <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/UhdmListener.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
#include <vector>
using namespace UHDM;

static std::string esc(std::string_view v) {
  std::string r;
  for (char c : v) r += ((c == ' ' || c == '\t') ? '_' : c);
  if (r.empty()) r = "-";
  return r;
}
static std::string spanOf(const any* o) {
  if (!o) return "-";
  char b[80];
  snprintf(b, sizeof b, "%u:%hu-%u:%hu", (unsigned)o->VpiLineNo(),
           o->VpiColumnNo(), (unsigned)o->VpiEndLineNo(), o->VpiEndColumnNo());
  return b;
}
static std::string chainOf(const any* o) {
  std::string r;
  const any* p = o ? o->VpiParent() : nullptr;
  for (int i = 0; i < 40 && p; i++) {
    std::string e(UhdmName(p->UhdmType()));
    if (!p->VpiName().empty()) e += "(" + esc(p->VpiName()) + ")";
    e += "#" + std::to_string((unsigned)p->UhdmId());
    r = r.empty() ? e : (e + "/" + r);
    p = p->VpiParent();
  }
  if (r.empty()) r = "-";
  return r;
}
static std::string kindOf(const any* o) {
  return o ? std::string(UhdmName(o->UhdmType())) : std::string("-");
}
// the ref_typespec slot of any expr / io_decl / variables, rendered
struct TsInfo { std::string kind = "none"; unsigned id = 0; std::string span = "-"; unsigned rtid = 0; };
static TsInfo tsOfRef(const ref_typespec* rt) {
  TsInfo t;
  if (!rt) return t;
  t.rtid = (unsigned)rt->UhdmId();
  const typespec* a = rt->Actual_typespec();
  if (!a) { t.kind = "refonly"; return t; }
  t.kind = UhdmName(a->UhdmType());
  t.id = (unsigned)a->UhdmId();
  t.span = spanOf(a);
  return t;
}
static TsInfo tsOfAny(const any* o) {
  TsInfo t;
  if (!o) return t;
  if (auto* e = any_cast<const expr*>(o)) return tsOfRef(e->Typespec());
  if (auto* d = any_cast<const io_decl*>(o)) return tsOfRef(d->Typespec());
  if (auto* v = any_cast<const variables*>(o)) return tsOfRef(v->Typespec());
  if (auto* p = any_cast<const parameter*>(o)) return tsOfRef(p->Typespec());
  return t;
}

static const char* g_lst = "-";
struct Cen : public UhdmListener {
  std::string pathOf() {
    std::string r;
    for (const any* p : getCallstack()) {
      std::string e(UhdmName(p->UhdmType()));
      if (!p->VpiName().empty()) e += "(" + esc(p->VpiName()) + ")";
      r = r.empty() ? e : (r + "/" + e);
    }
    if (r.empty()) r = "-";
    return r;
  }
  void emit(const any* call, const VectorOfany* args, const any* callee,
            const VectorOfio_decl* ios) {
    if (!args) return;
    std::string pth = pathOf();
    std::string ck = kindOf(call);
    std::string cn = esc(call->VpiName());
    std::string bn = callee ? (kindOf(callee) + "(" + esc(callee->VpiName()) + ")")
                            : std::string("-");
    for (size_t i = 0; i < args->size(); i++) {
      const any* a = (*args)[i];
      TsInfo at = tsOfAny(a);
      const any* act = nullptr;
      if (auto* r = any_cast<const ref_obj*>(a)) act = r->Actual_group();
      TsInfo actt = tsOfAny(act);
      const io_decl* fml = (ios && i < ios->size()) ? (*ios)[i] : nullptr;
      TsInfo ft = tsOfAny(fml);
      printf("ARG CALL=%s NAME=%s CID=%u BOUND=%s IDX=%zu AKIND=%s ANAME=%s "
             "ASPAN=%s AID=%u ATS=%s ATSID=%u ATSSPAN=%s RTSID=%u "
             "ACT=%s ACTN=%s ACTTS=%s ACTTSID=%u "
             "LST=%s FML=%s FDIR=%d FTS=%s FTSID=%u FTSSPAN=%s CH=%s PATH=%s\n",
             ck.c_str(), cn.c_str(), (unsigned)call->UhdmId(), bn.c_str(), i,
             kindOf(a).c_str(), esc(a->VpiName()).c_str(), spanOf(a).c_str(),
             (unsigned)a->UhdmId(), at.kind.c_str(), at.id, at.span.c_str(), at.rtid,
             kindOf(act).c_str(), act ? esc(act->VpiName()).c_str() : "-",
             actt.kind.c_str(), actt.id,
             g_lst,
             fml ? esc(fml->VpiName()).c_str() : "-",
             fml ? (int)fml->VpiDirection() : -1,
             ft.kind.c_str(), ft.id, ft.span.c_str(), chainOf(call).c_str(), pth.c_str());
    }
  }
  void enterFunc_call(const func_call* const c) final {
    const function* f = c->Function();
    emit(c, c->Tf_call_args(), f, f ? f->Io_decls() : nullptr);
  }
  void enterTask_call(const task_call* const c) final {
    const task* t = c->Task();
    emit(c, c->Tf_call_args(), t, t ? t->Io_decls() : nullptr);
  }
  void enterMethod_func_call(const method_func_call* const c) final {
    emit(c, c->Tf_call_args(), nullptr, nullptr);
  }
  void enterMethod_task_call(const method_task_call* const c) final {
    emit(c, c->Tf_call_args(), nullptr, nullptr);
  }
  void enterSys_func_call(const sys_func_call* const c) final {
    emit(c, c->Tf_call_args(), nullptr, nullptr);
  }
  void enterSys_task_call(const sys_task_call* const c) final {
    emit(c, c->Tf_call_args(), nullptr, nullptr);
  }
};
int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: ct127cen <db.uhdm>\n"); return 2; }
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "EMPTY %s\n", argv[1]); return 3; }
  for (vpiHandle h : restored) {
    const any* o = (const any*)((const uhdm_handle*)h)->object;
    const design* d = any_cast<const design*>(o);
    if (!d) continue;
    printf("LISTING ALLPKG:");
    if (d->AllPackages()) for (auto* p : *d->AllPackages()) printf(" %s#%u", std::string(p->VpiName()).c_str(), (unsigned)p->UhdmId());
    printf("\nLISTING TOPPKG:");
    if (d->TopPackages()) for (auto* p : *d->TopPackages()) printf(" %s#%u", std::string(p->VpiName()).c_str(), (unsigned)p->UhdmId());
    printf("\n");
    Cen c;
    if (d->AllPackages()) { g_lst = "ALLPKG"; for (auto* p : *d->AllPackages()) c.listenAny(p); }
    if (d->TopPackages()) { g_lst = "TOPPKG"; for (auto* p : *d->TopPackages()) c.listenAny(p); }
    if (d->AllClasses())  { g_lst = "ALLCLS"; for (auto* p : *d->AllClasses())  c.listenAny(p); }
    if (d->TopModules())  { g_lst = "TOPMOD"; for (auto* p : *d->TopModules())  c.listenAny(p); }
    if (d->AllModules())  { g_lst = "ALLMOD"; for (auto* p : *d->AllModules())  c.listenAny(p); }
  }
  return 0;
}
