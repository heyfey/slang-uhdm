// vsd10 adversarial cell v3 (rev) — DECLARATION MODIFIERS: static vs automatic
// lifetime, an INITIALIZED local, a foreach iterator, formals (input/output/ref)
// and the RETURN temp.
package px3;

  class zhold3;
    typedef struct { int a; } r_t;
    typedef int d_t[];
    typedef enum { X3, Y3 } e_t;
  endclass

  class auser3;
    function void f();
      static    zhold3::r_t s_stat;
      automatic zhold3::r_t s_auto;
      zhold3::r_t s_init = '{a:1};
      zhold3::e_t e_init = zhold3::X3;
      s_stat.a = 1;
      s_auto.a = 2;
    endfunction

    function void h(input zhold3::r_t ip, output zhold3::r_t op,
                    ref zhold3::r_t rp);
      op = ip;
      rp = ip;
    endfunction

    function zhold3::r_t ret_scoped();
      ret_scoped.a = 1;
    endfunction

    task fe();
      zhold3::d_t qq;
      qq = new[2];
      foreach (qq[i]) qq[i] = i;
    endtask
  endclass

endpackage

module top3;
  px3::auser3 u;
  initial u = new();
endmodule
