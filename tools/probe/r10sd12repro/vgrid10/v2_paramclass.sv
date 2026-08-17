// vsd10 adversarial cell v2 — PARAMETERIZED-class scopes.  slang models every
// specialization as its own ClassType with the SAME `name`, so the law's
// sibling ORDER test (`owner.name < ctx.cls->name`) compares two equal strings
// and always answers "not compiled".  Surelog's map key for a specialization
// is not the bare name.
package px2;

  class zparm2 #(type T = int);
    typedef struct { int a; } prec_t;
    typedef T pt_t;
  endclass

  class auser2;
    function void f();
      zparm2#(int)::prec_t a_int;
      zparm2#(bit)::prec_t a_bit;
      zparm2#(int)::pt_t   a_pt;
      a_int.a = 1;
    endfunction
  endclass

  // a parameterized class using its OWN typedef, bare and self-scoped
  class zself2 #(type T = int);
    typedef struct { int a; } srec_t;
    function void f();
      srec_t s_bare;
      s_bare.a = 1;
    endfunction
  endclass

  // a parameterized class whose typedef a LATE-sorting parameterized owner owns
  class zother2 #(type T = int);
    typedef struct { int b; } orec_t;
  endclass

  class buser2 #(type T = int);
    function void f();
      zother2#(int)::orec_t b_o;
      b_o.b = 1;
    endfunction
  endclass

endpackage

module top2;
  px2::auser2      u;
  px2::zself2#(int) v;
  px2::buser2#(int) w;
  initial begin u = new(); v = new(); w = new(); end
endmodule
