// r10earl95 arm g2 — the NESTING DEPTH grid.  One statement shape
// (`c = TAB[W-KOFF][W-1:0]`, the prim_lfsr.sv:308 shape) placed at gen-scope
// depth 1, 2 and 3, plus a depth-2 row that reads the PARENT gen scope's own
// localparam and a depth-2 row that reads its OWN localparam.
// MEASUREMENT ONLY.
module d95 #(
  parameter int unsigned W = 32
) (
  input  logic [7:0]   e_i,
  output logic [W-1:0] o_o
);
  localparam int unsigned KOFF = 4;
  localparam logic [63:0] TAB [8] =
    '{ 64'h9, 64'h12, 64'h21, 64'h41, 64'h8E, 64'h108, 64'h204, 64'h402 };

  logic [W-1:0] a1, a2, a3, b1, b2, b3, b4;
  logic [63:0]  m_net;

  // depth 1
  if (1) begin : g1
    localparam int unsigned P1 = 6;
    assign a1 = TAB[W-KOFF][W-1:0];
    assign b1 = {W{e_i[0]}};
    // depth 2
    if (1) begin : g2
      localparam int unsigned LOC2 = 5;
      assign a2 = TAB[W-KOFF][W-1:0];
      assign b2 = {W{e_i[1]}};
      // a PARENT-gen-scope name (g1 declares P1)
      assign b3 = m_net[P1-1:0];
      // its OWN localparam
      assign b4 = m_net[LOC2-1:0];
      // depth 3
      if (1) begin : g3
        assign a3 = TAB[W-KOFF][W-1:0];
      end
    end
  end

  assign o_o = a1 ^ a2 ^ a3 ^ b1 ^ b2 ^ b3 ^ b4;
endmodule

module topd95;
  logic [7:0] e;
  logic [4:0] o5;
  logic [5:0] o6;
  logic [7:0] o8;
  d95 #(.W(5)) u5 (.e_i(e), .o_o(o5));
  d95 #(.W(6)) u6 (.e_i(e), .o_o(o6));
  d95 #(.W(8)) u8 (.e_i(e), .o_o(o8));
endmodule
