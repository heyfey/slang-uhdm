// r10earl95 arm g1 — the prim_lfsr.sv:308 shape: a select on a LOCALPARAM
// UNPACKED ARRAY inside an if-generate body of a parameterized module,
// instantiated at three different widths.  MEASUREMENT ONLY.
module m95 #(
  parameter int unsigned W = 32
) (
  input  logic [7:0]   e_i,
  output logic [W-1:0] o_o
);
  localparam int unsigned KOFF = 4;
  localparam logic [63:0] TAB [8] =
    '{ 64'h9, 64'h12, 64'h21, 64'h41, 64'h8E, 64'h108, 64'h204, 64'h402 };
  localparam int unsigned PW = 8;

  logic [W-1:0] c1, c2, c3, c4, c5, c6, c7, c8;
  logic [W-1:0] m_arr [8];
  logic [63:0]  m_net;
  logic [63:0]  m_var;

  if (1) begin : gsel
    // R0 row: the head's exact shape (var_select on a localparam unpacked
    // array, param-op-param index, param part-select bound)
    assign c1 = TAB[W-KOFF][W-1:0];
    // index only, no part select
    assign c2 = TAB[W-KOFF];
    // bare (single-operand) parameter index
    assign c3 = TAB[W-1];
    // literal index, param part-select bound
    assign c4 = TAB[1][W-1:0];
    // a NET base, same index shape
    assign c5 = m_net[W-1:0];
    // a VARIABLE unpacked array base
    assign c6 = m_arr[W-KOFF];
    // a bit_select index on a net
    assign c7 = m_net[W-KOFF];
    // the replication-count control (folds in golden at prim_lfsr.sv:315)
    assign c8 = {W{e_i[0]}} & c1;
  end
  assign o_o = c1 ^ c2 ^ c3 ^ c4 ^ c5 ^ c6 ^ c7 ^ c8;
endmodule

module top95;
  logic [7:0] e;
  logic [4:0] o5;
  logic [5:0] o6;
  logic [7:0] o8;
  m95 #(.W(5)) u5 (.e_i(e), .o_o(o5));
  m95 #(.W(6)) u6 (.e_i(e), .o_o(o6));
  m95 #(.W(8)) u8 (.e_i(e), .o_o(o8));
endmodule
