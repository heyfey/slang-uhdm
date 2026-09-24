// r10uvm219 grid arm B — THE ORDER *WITHIN* THE FORWARDED BLOCK.
// Three out-of-body methods leave one hoisted name each; the bare `this` sits
// in the MIDDLE one, after that method's own hoisted name and before the third
// method's.  Golden's forwarded block is the late-binding stream in order, so
// the `this` wire must land BETWEEN them — not at the front of the block and
// not at its end.
package pb0;
  class Cb0;
    int pb_a;
    int pb_b;
    int pb_c;
    extern function void f1();
    extern function void f2();
    extern function void f3();
  endclass
  function void Cb0::f1();
    int lb_a; pb_a = lb_a;
  endfunction
  function void Cb0::f2();
    int lb_b; pb_b = lb_b; $display("%p", this);
  endfunction
  function void Cb0::f3();
    int lb_c; pb_c = lb_c;
  endfunction
endpackage

module gb_interleave;
  import pb0::*;
  logic gb_clk;
  initial $dumpvars(0, gb_interleave);
endmodule
