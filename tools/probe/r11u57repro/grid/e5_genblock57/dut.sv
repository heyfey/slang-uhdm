// r11u57 — THE GENERATE-BLOCK CONTROL.  r11v53's R2: a generate-block
// localparam is out of BOTH halves' reach (in the DEF view we keep both the
// type-parameter cell and the control golden folds; in the ELAB view we fold
// both where golden keeps the type-parameter one).  It is a pre-existing
// gen-scope divergence and this pass must leave the arm byte-UNCHANGED.
package pk;
  typedef struct packed { logic [2:0] a; } req_t;                   // 3
endpackage
module dut #(parameter type TP = logic [1:0]) (output logic o);
  generate
    if (1) begin : g
      localparam int G1 = (1 << $bits(TP));
      localparam int G2 = (1 << $bits(pk::req_t));   // CONTROL
    end
  endgenerate
  assign o = ^{g.G1[0], g.G2[0]};
endmodule
