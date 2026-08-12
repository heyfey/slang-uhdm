// r10uvm61 ARM c4_edge — the edge cells the law must not over-fire on:
// declaration ORDER, STATIC properties, PARAMETERIZED classes (elaborated and
// not), NESTED scopes inside the method, a member of a base class reached
// through `super`, a class inside a MODULE (not a package), a member whose
// width is PARAMETER-dependent, and a `new` constructor body.
package c4_pkg;

  // R1: the member is declared AFTER the method that queries it.
  // THE CELL CANNOT EXIST: slang REJECTS it outright --
  //   "error: identifier 'm_late' used before its declaration"
  // (measured; the arm did not build until this row was removed).  Declaration
  // ORDER is therefore not an axis the fold predicate can be wrong about: no
  // database with such a reference ever reaches the emitter.
  class order_c;
    logic [4:0] m_late;
    function void r1(ref int o);
      o = $bits(m_late);
    endfunction
  endclass

  // R2: STATIC and CONST properties
  class static_c;
    static logic [5:0] m_st;
    const  logic [6:0] m_cst = 0;
    rand   logic [9:0] m_rand;
    function void r2(ref int o);
      o = $bits(m_st);
      o = $bits(m_cst);
      o = $bits(m_rand);
    endfunction
  endclass

  // R3: PARAMETERIZED class, width INDEPENDENT of the parameter
  class parm_c #(int W = 8);
    logic [3:0]   m_fixed;
    logic [W-1:0] m_dep;      // width DEPENDS on the parameter
    function void r3(ref int o);
      o = $bits(m_fixed);
      o = $bits(m_dep);
    endfunction
  endclass

  // R3b: parameter-dependent width reached through a TYPEDEF the class itself
  // declares, and through a packed STRUCT field -- the indirect forms of R3.
  class parmts_c #(int W = 8);
    typedef logic [W-1:0] dep_t;
    typedef struct packed { logic [W-1:0] a; logic [1:0] b; } deps_t;
    typedef logic [3:0]   fix_t;
    dep_t  m_tdep;
    deps_t m_sdep;
    fix_t  m_tfix;
    function void r3b(ref int o);
      o = $bits(m_tdep);
      o = $bits(m_sdep);
      o = $bits(m_tfix);
    endfunction
  endclass

  // R4: parameterized class that is NEVER instantiated (unelaborated)
  class unelab_c #(int W = 16);
    logic [3:0]   m_fixed;
    logic [W-1:0] m_dep;
    function void r4(ref int o);
      o = $bits(m_fixed);
      o = $bits(m_dep);
    endfunction
  endclass

  // R5: the query sits inside NESTED statement scopes, not at body top level
  class nest_c;
    logic [2:0] m_n;
    function void r5(ref int o);
      if (1) begin : blk
        for (int i = 0; i < 2; i++) begin
          o = $bits(m_n);
        end
      end
    endfunction
  endclass

  // R6: a member of the BASE class reached through `super.`
  class base_c;  logic [3:0] m_base; endclass
  class super_c extends base_c;
    logic [3:0] m_own;
    function void r6(ref int o);
      o = $bits(super.m_base);
      o = $bits(m_own);
    endfunction
  endclass

  // R7: the CONSTRUCTOR body
  class ctor_c;
    logic [10:0] m_c;
    int q;
    function new();
      q = $bits(m_c);
    endfunction
  endclass

  // R8: a member whose type is a TYPEDEF / packed struct / enum
  typedef struct packed { logic [3:0] a; logic [2:0] b; } st_t;
  typedef enum logic [1:0] { E0, E1 } en_t;
  typedef logic [12:0] al_t;
  class typ_c;
    st_t  m_s;
    en_t  m_e;
    al_t  m_a;
    string m_str;
    real   m_r;
    function void r8(ref int o);
      o = $bits(m_s);
      o = $bits(m_e);
      o = $bits(m_a);
      o = $bits(m_str);
      o = $bits(m_r);
    endfunction
  endclass

endpackage

// R9: a class declared inside a MODULE, not a package
module c4_top;
  import c4_pkg::*;
  class modcls_c;
    logic [13:0] m_m;
    function void r9(ref int o);
      o = $bits(m_m);
    endfunction
  endclass

  int o;
  initial begin
    order_c a = new(); static_c b = new(); parm_c#(8) c = new();
    nest_c e = new(); super_c f = new(); ctor_c g = new(); parmts_c#(8) j = new();
    typ_c h = new(); modcls_c i = new();
    a.r1(o); b.r2(o); c.r3(o); e.r5(o); f.r6(o); h.r8(o); i.r9(o); j.r3b(o);
    o = g.q;
  end
endmodule
