// r10earl93 g2 -- THE CONTEXT GRID.  The SAME size cast in every context the
// law could reach, in a CHILD module so DEF and ELAB really differ.
// MEASUREMENT ONLY.
module g2_child #(parameter int unsigned W = 64) (
  input  logic         clk,
  input  logic [W-1:0] i1,
  output logic [W-1:0] o1
);
  parameter  logic [W-1:0] PP_par = W'(64'd1);
  localparam logic [W-1:0] LP_loc = W'(64'hFFFFFFFFFFFFFFFF);
  localparam               LP_unt = W'(64'd3);
  wire  [W-1:0] w_ca;
  assign w_ca = W'(64'd5);
  logic [W-1:0] r_pr;
  always_comb r_pr = W'(64'd7);
  assign o1 = w_ca ^ r_pr ^ i1 ^ PP_par ^ LP_loc ^ W'(LP_unt);
endmodule

module g2;
  logic clk;
  logic [63:0] o64;  logic [95:0] o96;  logic [127:0] o128;
  g2_child #(.W(64))  u64  (.clk(clk), .i1(64'(64'd9)),                    .o1(o64));
  g2_child #(.W(96))  u96  (.clk(clk), .i1(96'(64'hFFFFFFFFFFFFFFFF)),     .o1(o96));
  g2_child #(.W(128)) u128 (.clk(clk), .i1(128'(64'd11)),                  .o1(o128));
endmodule
