// r10earl88 — FIELD TABLE reader for one named signal.  Earlgrey's uhdm-dump is
// >1 GB (earl61's lesson: never a whole-dump diff on Earlgrey), so this reads
// the database DIRECTLY and prints every judge-visible field of the
// Nets/Variables/Array_nets entry called <signame> in every owner whose
// fullname contains <ownerfilter>.  MEASUREMENT ONLY.
//   build: g++ -O2 -std=c++17 pafld88.cpp -I ~/.local/include \
//              -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o pafld88
//   usage: pafld88 <db.uhdm> <ownerfilter> <signame>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/Serializer.h>
#include <cstdio>
#include <string>
#include <vector>
using namespace UHDM;

static void ts(const char* tag, const ref_typespec* rt, int ind) {
  std::string p(ind, ' ');
  if (!rt) { printf("%s%s: <no ref_typespec>\n", p.c_str(), tag); return; }
  const typespec* t = rt->Actual_typespec();
  printf("%s%s: ref_typespec fullname='%s' actual=%s name='%s'\n", p.c_str(), tag,
         std::string(rt->VpiFullName()).c_str(),
         t ? UhdmName(t->UhdmType()).data() : "<null>",
         t ? std::string(t->VpiName()).c_str() : "");
}
static void expr1(const char* tag, const any* e, int ind) {
  std::string p(ind, ' ');
  if (!e) { printf("%s%s: <null>\n", p.c_str(), tag); return; }
  printf("%s%s: %s", p.c_str(), tag, UhdmName(e->UhdmType()).data());
  if (e->UhdmType() == uhdmconstant) {
    const constant* c = (const constant*)e;
    printf(" decompile='%s' size=%d constType=%d value='%s'",
           std::string(c->VpiDecompile()).c_str(), c->VpiSize(),
           c->VpiConstType(), std::string(c->VpiValue()).c_str());
    printf(" ts=%s", c->Typespec() && c->Typespec()->Actual_typespec()
                         ? UhdmName(c->Typespec()->Actual_typespec()->UhdmType()).data()
                         : "-");
  }
  printf(" loc=%d:%d-%d:%d\n", e->VpiLineNo(), e->VpiColumnNo(),
         e->VpiEndLineNo(), e->VpiEndColumnNo());
}
static void ranges(const std::vector<range*>* rs, int ind) {
  std::string p(ind, ' ');
  if (!rs) { printf("%sRanges: <none>\n", p.c_str()); return; }
  printf("%sRanges: %zu\n", p.c_str(), rs->size());
  for (auto* r : *rs) {
    printf("%s  range size=%d loc=%d:%d-%d:%d\n", p.c_str(), r->VpiSize(),
           r->VpiLineNo(), r->VpiColumnNo(), r->VpiEndLineNo(), r->VpiEndColumnNo());
    expr1("Left ", r->Left_expr(), ind + 4);
    expr1("Right", r->Right_expr(), ind + 4);
  }
}
static void one(const any* o, const char* cont) {
  printf("  [%s] %s loc=%d:%d-%d:%d\n", cont, UhdmName(o->UhdmType()).data(),
         o->VpiLineNo(), o->VpiColumnNo(), o->VpiEndLineNo(), o->VpiColumnNo());
  if (const packed_array_var* p = any_cast<const packed_array_var*>(o)) {
    printf("    name='%s' fullname='%s' visibility=%d size=%d\n",
           std::string(p->VpiName()).c_str(), std::string(p->VpiFullName()).c_str(),
           p->VpiVisibility(), p->VpiSize());
    ts("Typespec", p->Typespec(), 4);
    ranges(p->Ranges(), 4);
    if (p->Elements()) for (auto* e : *p->Elements()) {
      printf("    Element: %s loc=%d:%d-%d:%d\n", UhdmName(e->UhdmType()).data(),
             e->VpiLineNo(), e->VpiColumnNo(), e->VpiEndLineNo(), e->VpiEndColumnNo());
      if (const variables* v = any_cast<const variables*>(e)) {
        printf("      name='%s' fullname='%s' visibility=%d\n",
               std::string(v->VpiName()).c_str(),
               std::string(v->VpiFullName()).c_str(), v->VpiVisibility());
        ts("Typespec", v->Typespec(), 6);
      }
    }
  } else if (const packed_array_net* p = any_cast<const packed_array_net*>(o)) {
    printf("    name='%s' fullname='%s' netType=%d size=%d\n",
           std::string(p->VpiName()).c_str(), std::string(p->VpiFullName()).c_str(),
           p->VpiNetType(), p->VpiSize());
    ts("Typespec", p->Typespec(), 4);
    ranges(p->Ranges(), 4);
    if (p->Elements()) for (auto* e : *p->Elements()) {
      printf("    Element: %s loc=%d:%d-%d:%d\n", UhdmName(e->UhdmType()).data(),
             e->VpiLineNo(), e->VpiColumnNo(), e->VpiEndLineNo(), e->VpiEndColumnNo());
      if (const net* n = any_cast<const net*>(e)) {
        printf("      name='%s' fullname='%s' netType=%d\n",
               std::string(n->VpiName()).c_str(),
               std::string(n->VpiFullName()).c_str(), n->VpiNetType());
        ts("Typespec", n->Typespec(), 6);
      }
    }
  } else if (const variables* v = any_cast<const variables*>(o)) {
    printf("    name='%s' fullname='%s' visibility=%d\n",
           std::string(v->VpiName()).c_str(),
           std::string(v->VpiFullName()).c_str(), v->VpiVisibility());
    ts("Typespec", v->Typespec(), 4);
  } else if (const net* n = any_cast<const net*>(o)) {
    printf("    name='%s' fullname='%s' netType=%d\n",
           std::string(n->VpiName()).c_str(),
           std::string(n->VpiFullName()).c_str(), n->VpiNetType());
    ts("Typespec", n->Typespec(), 4);
  }
}
int main(int argc, char** argv) {
  if (argc < 4) { fprintf(stderr, "usage: pafld88 <db> <ownerfilter> <signame>\n"); return 2; }
  std::string of(argv[2]), sn(argv[3]);
  Serializer s;
  if (s.Restore(std::string(argv[1])).empty()) { fprintf(stderr, "EMPTY\n"); return 3; }
  for (const auto& [obj, id] : s.AllObjects()) {
    std::string owner;
    const std::vector<net*>* nets = nullptr;
    const std::vector<variables*>* vars = nullptr;
    const std::vector<array_net*>* anets = nullptr;
    const std::vector<port*>* ports = nullptr;
    if (const module_inst* m = any_cast<const module_inst*>(obj)) {
      owner = m->VpiFullName(); nets = m->Nets(); vars = m->Variables();
      anets = m->Array_nets(); ports = m->Ports();
    } else if (const gen_scope* g = any_cast<const gen_scope*>(obj)) {
      owner = g->VpiFullName(); nets = g->Nets(); vars = g->Variables(); anets = g->Array_nets();
    } else if (const interface_inst* i = any_cast<const interface_inst*>(obj)) {
      owner = i->VpiFullName(); nets = i->Nets(); vars = i->Variables();
      anets = i->Array_nets(); ports = i->Ports();
    } else continue;
    if (owner.find(of) == std::string::npos) continue;
    bool hit = false;
    if (nets)  for (auto* n : *nets)  if (std::string(n->VpiName()) == sn) { if(!hit){printf("OWNER %s\n", owner.c_str());hit=true;} one(n, "NET"); }
    if (vars)  for (auto* v : *vars)  if (std::string(v->VpiName()) == sn) { if(!hit){printf("OWNER %s\n", owner.c_str());hit=true;} one(v, "VAR"); }
    if (anets) for (auto* a : *anets) if (std::string(a->VpiName()) == sn) { if(!hit){printf("OWNER %s\n", owner.c_str());hit=true;} one(a, "ANET"); }
    if (hit && ports) for (auto* p : *ports) if (std::string(p->VpiName()) == sn) {
      const any* l = p->Low_conn();
      printf("  PORT dir=%d lowconn=%s", p->VpiDirection(), l ? UhdmName(l->UhdmType()).data() : "<null>");
      if (l && l->UhdmType() == uhdmref_obj) {
        const any* a = ((const ref_obj*)l)->Actual_group();
        printf("->%s", a ? UhdmName(a->UhdmType()).data() : "<null>");
      }
      ts(" portTs", p->Typespec(), 1);
    }
  }
  return 0;
}
