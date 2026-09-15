// r11u46 GRID-2 — a PACKAGE parameter read inside a signed'/unsigned' cast in
// a def-view gen_for condition (does the landed pkg-param fold reach INTO the
// cast argument?), plus the elaborated view of the same loops.
package p46;
  parameter int unsigned PN = 5;
endpackage

module grid2
  import p46::*;
#(
    parameter int unsigned N = 4
) (
    input  logic [7:0] in_i,
    output logic [7:0] out_o
);
  // Q: bare package param inside the cast argument
  for (genvar q = 0; q < unsigned'(PN); q++) begin : g_q
    assign out_o[0] = in_i[0];
  end

  // R: QUALIFIED package param inside the cast argument
  for (genvar r = 0; r < unsigned'(p46::PN); r++) begin : g_r
    assign out_o[1] = in_i[1];
  end

  // S: package param OUTSIDE the cast, genvar cast inside (the corpus shape)
  for (genvar s = 0; unsigned'(s) < PN; s++) begin : g_s
    assign out_o[2] = in_i[2];
  end

  // T: cast of a genvar in a nested BIT-SELECT index inside the loop body
  logic [7:0] tnet;
  for (genvar t = 0; unsigned'(t) < N; t++) begin : g_t
    assign tnet[unsigned'(t)] = in_i[t];
  end
endmodule

module grid2top (input logic [7:0] i_i, output logic [7:0] o_o);
  grid2 #(.N(4)) u (.in_i(i_i), .out_o(o_o));
endmodule
