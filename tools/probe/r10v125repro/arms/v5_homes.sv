// v125 arm V5 — HOMES and INSTANCE COUNT.  Three differently parameterised
// instances, and the converting output call written in a module task, a module
// function, an initial, an always and a generate block.
package Home_Pkg;
  function automatic int fill(output logic [63:0] d); d = 64'd3; return 0; endfunction
endpackage

module Home_Leaf #(parameter int WIDE = 8) ();
  import Home_Pkg::*;
  logic [WIDE-1:0] slot;
  int              rc;
  task automatic doTask(); rc = fill(slot); endtask
  function automatic int doFunc(); return fill(slot); endfunction
  initial rc = fill(slot);
  always @* rc = fill(slot);
  if (WIDE > 4) begin : g_wide
    initial begin
      logic [WIDE-1:0] genSlot;
      int              genRc;
      genRc = fill(genSlot);
    end
  end
endmodule

module Home_Top;
  Home_Leaf #(.WIDE(8))  i_a ();
  Home_Leaf #(.WIDE(64)) i_b ();
  Home_Leaf #(.WIDE(3))  i_c ();
endmodule
