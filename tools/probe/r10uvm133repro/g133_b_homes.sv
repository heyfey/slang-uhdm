// r10uvm133 arm B - the SAME `$bits(<call>)` in EVERY HOME the emitter has a
// separate road for.  MEASUREMENT ONLY.  LHS is always golden (Surelog).
`define B133_QBITS(A) $bits(A.size())
`define B133_FBITS(F) $bits(F())

package p133_b;
  function automatic int fb133_free();
    return 2;
  endfunction
  function automatic int fb133_const();
    return 4;
  endfunction
  class qb133_c;
    int qq[$];
    function int m133(); return 1; endfunction
    function void inclass133();
      int r;
      r = $bits(qq.size());            // B01 class method body
      r = `B133_QBITS(qq);             // B02 macro expansion, class method
      r = $bits(m133());               // B03 own method call
      if (r == 0) r = 1;
    endfunction
  endclass
  function automatic int fb133_home();
    int r;
    r = $bits(fb133_free());           // B04 package free function body
    r = `B133_FBITS(fb133_free);       // B05 macro expansion, free function
    return r;
  endfunction
endpackage

module sub133_b #(parameter int WB = 8) (input logic [WB-1:0] a, output logic [7:0] y);
  assign y = a[7:0];
endmodule

module m133_b;
  import p133_b::*;
  logic [7:0] w;
  logic [7:0] yy;
  int    rq;
  int    dq[$];
  localparam int LB133 = $bits(fb133_const());   // B06 param_assign init

  function automatic int fm133_mod();
    return 3;
  endfunction

  initial begin
    rq = $bits(fm133_mod());           // B07 module initial, free function
    rq = $bits(dq.size());             // B08 module initial, queue method
    rq = `B133_QBITS(dq);              // B09 macro expansion, module
  end

  always_comb begin
    rq = $bits(fm133_mod());           // B10 always_comb
  end

  assign w = 8'($bits(dq.size()));      // B11 continuous assign rhs

  sub133_b #(.WB($bits(fb133_const()))) u133 (.a(w), .y(yy));  // B12 High_conn / param override

  generate
    if (LB133 > 0) begin : g133
      int rg;
      initial rg = $bits(fm133_mod()); // B13 inside a generate block
    end
  endgenerate
endmodule
