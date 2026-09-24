// r10v111 ARM B6 — TOPS AND INSTANCES.  A home package, an importer, one module
// that instantiates a child THREE times, and a second top that imports nothing.
package v111b6p;
  class Six6;
    extern static function int mk6();
  endclass
  function int Six6::mk6();
    mk6 = 6;
  endfunction
  int h_v6 = Six6::mk6();
endpackage

package v111b6w;
  import v111b6p::*;
  int w_v6 = Six6::mk6();
endpackage

module v111b6child (input logic ck, output int o6);
  import v111b6w::*;
  assign o6 = w_v6;
endmodule

module v111b6top (input logic ck);
  int r0, r1, r2;
  v111b6child u0 (.ck(ck), .o6(r0));
  v111b6child u1 (.ck(ck), .o6(r1));
  v111b6child u2 (.ck(ck), .o6(r2));
endmodule

module v111b6other (input logic ck);
  int n6;
  always_comb n6 = 1;
endmodule
