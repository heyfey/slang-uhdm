// vsd10 adversarial cell v7 — the CONTAINER SCOPES the `nameableScope` test
// enumerates and the ones it does NOT: a module body (InstanceBody), an
// interface, a program, and a GENERATE BLOCK.  A class whose parent scope is
// not Package / ClassType / InstanceBody is answered `class_var` by the
// predicate even for its OWN self-qualified typedef.
interface ifc7;
  class zif7;
    typedef struct { int a; } r_t;
  endclass
  class aif7;
    function void f();
      zif7::r_t v_if_sib;      // sibling in an INTERFACE, owner sorts LATE
      v_if_sib.a = 1;
    endfunction
  endclass
endinterface

module top7;
  class zmod7;
    typedef struct { int a; } r_t;
  endclass
  class amod7;
    typedef struct { int m; } own_t;
    function void f();
      zmod7::r_t  v_mod_sib_late;   // MODULE sibling, owner sorts LATE
      amod7::own_t v_mod_self;      // MODULE class, OWN typedef, self-scoped
      own_t        v_mod_self_bare; // ... and bare
      v_mod_sib_late.a = 1;
      v_mod_self.m = 2;
      v_mod_self_bare.m = 3;
    endfunction
  endclass
  amod7 a;
  initial a = new();
endmodule
