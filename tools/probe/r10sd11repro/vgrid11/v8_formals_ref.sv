// vsd11 v8 — THE FORMAL SITE, which the patch deliberately does NOT touch
// (residues R1 and R2).  Read here so the boundary is measured rather than
// asserted: a DEGRADING scoped typedef and a CLAIMING one, at a plain formal, a
// `ref` formal, an `input` formal, an `output` formal and a RETURN type, on both
// binaries.
package pv8;
  class zel8v;
    int q;
  endclass
  class zk8v;
    int q;
  endclass

  typedef zel8v pk8v_t;        // package claimant -> z8v::d_t degrades

  class z8v;
    typedef zel8v d_t;         // DEGRADES
    typedef zk8v  k_t;         // CLAIMS
  endclass

  class user8v;
    function z8v::d_t f_ret_d(z8v::d_t a, ref z8v::d_t b, input z8v::d_t c,
                              output z8v::d_t d);
      z8v::d_t loc;
      loc = a;
      d = a;
      f_ret_d = a;
    endfunction
    function z8v::k_t f_ret_k(z8v::k_t a, ref z8v::k_t b, input z8v::k_t c,
                              output z8v::k_t d);
      z8v::k_t loc;
      loc = a;
      d = a;
      f_ret_k = a;
    endfunction
    task t8v(ref z8v::d_t r, input z8v::k_t k);
      z8v::d_t tl;
      tl = r;
    endtask
  endclass
endpackage

module topv8;
  initial begin
    pv8::user8v u = new();
    pv8::z8v::d_t x, y, z;
    void'(u.f_ret_d(x, y, x, z));
  end
endmodule
