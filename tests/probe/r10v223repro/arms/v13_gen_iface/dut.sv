// v13 — an interface with a GENERATE block and a MODPORT, importing a
// package; instantiated inside a generate loop.
package pv13;
  int gv13 = 1;
  string gs13 = "g";
endpackage

interface if_v13 #(parameter int N = 2);
  import pv13::*;
  logic own_v13;
  generate
    if (N > 1) begin : g_blk
      logic gen_net13;
    end
  endgenerate
  modport mp13 (input own_v13);
endinterface

module top_v13;
  genvar i;
  generate
    for (i = 0; i < 2; i++) begin : g_loop
      if_v13 #(.N(2)) u_if();
    end
  endgenerate
endmodule
