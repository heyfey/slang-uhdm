// vsd10 adversarial cell v5 — OUT-OF-BODY (`extern`) definitions, in a package
// and in $unit, with the owner EARLY, LATE and SELF, plus a return temp.
package px5;

  class zhold5;
    typedef struct { int a; } r_t;
  endclass

  class auser5;
    typedef struct { int m; } own_t;
    extern function void f();
    extern function own_t retown();
    extern task t();
  endclass

  function void auser5::f();
    own_t       v_ext_bare;
    auser5::own_t v_ext_self_scoped;
    zhold5::r_t v_ext_scoped;
    v_ext_bare.m = 1;
    v_ext_self_scoped.m = 2;
    v_ext_scoped.a = 3;
  endfunction

  function auser5::own_t auser5::retown();
    retown.m = 1;
  endfunction

  task auser5::t();
    begin
      zhold5::r_t b_ext_scoped;
      b_ext_scoped.a = 1;
    end
  endtask

endpackage

module top5;
  px5::auser5 u;
  initial u = new();
endmodule
