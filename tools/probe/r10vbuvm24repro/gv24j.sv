// r10vbuvm24repro/gv24j.sv — CHAINED and NESTED call syntax around an empty
// slot: a method call on the RESULT of a call with an empty slot, an element
// select of such a result, a call inside a constraint, and a call inside a
// `$display` argument.  MEASUREMENT ONLY.
package pz24;
  class box24;
    int q[4];
    function int val(int a = 1, int b = 2, int c = 3); return a + b + c; endfunction
  endclass
  function automatic box24 mk(int a = 1, int b = 2, int c = 3);
    box24 b0 = new();
    b0.q[0] = a + b + c;
    return b0;
  endfunction
  function automatic int z3(int a = 1, int b = 2, int c = 3); return a + b + c; endfunction

  class rnd24;
    rand int r;
    int lim = 4;
    constraint c1 { r < z3(1,,3); }
  endclass
endpackage

module topz24;
  import pz24::*;
  int rr;
  box24 bx;
  rnd24 rn;
  initial begin
    bx = mk(1,,3);
    rr  = mk(1,,3).val(1,,3);
    // `mk(1,,3).q[0]` is a SURELOG PARSE ERROR (no viable alternative at `q[`),
    // so it cannot be scored against a golden; recorded, not exercised.
    rr += z3(1,, z3(1,, z3(1,,3)));
    $display("%0d", z3(1,,3));
    rn = new();
    rr += rn.r;
  end
endmodule
