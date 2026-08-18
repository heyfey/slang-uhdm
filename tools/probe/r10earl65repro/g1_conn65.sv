// r10earl65 GRID ARM 1 — where does a FOLDED PARAMETER READ carry a typespec?
// Three parameter ORIGINS (package localparam / module-body localparam /
// port parameter) x eight POSITIONS (ips WIDTH, ips BASE, bit-select index,
// part-select left/right, bare actual, operation operand, cont_assign) x three
// HOMES (module body / gen-for / gen-if), in the ELABORATED port connection and
// in the cont_assign.  MEASUREMENT ONLY.
package p65;
  localparam int PW  = 5;
  localparam int PB  = 2;
endpackage

module leaf65 #(parameter int LW = 5) (
  input  logic [31:0] a_i,
  input  logic [4:0]  s_i,
  input  logic        b_i,
  output logic        o_o
);
  assign o_o = ^a_i ^ ^s_i ^ b_i;
endmodule

module g1_conn65 import p65::*; #(
  parameter int PP = 5              // PORT parameter
) (
  input  logic [63:0] d_i,
  input  logic        clk_i,
  output logic [7:0]  o_o
);
  localparam int LP = 5;            // MODULE-BODY localparam
  localparam int LB = 2;

  logic [31:0] w32;
  logic [4:0]  w5;
  assign w32 = d_i[31:0];
  assign w5  = d_i[4:0];

  // ---- module body: ELAB port connection, three origins x three positions
  leaf65 u_pkg_w (.a_i(d_i[0    +: PW]), .s_i(w5), .b_i(d_i[PB]), .o_o(o_o[0]));
  leaf65 u_pkg_b (.a_i(d_i[PB   +: 32]), .s_i(w5), .b_i(d_i[0]),  .o_o(o_o[1]));
  leaf65 u_loc_w (.a_i(d_i[0    +: LP]), .s_i(w5), .b_i(d_i[LB]), .o_o(o_o[2]));
  leaf65 u_por_w (.a_i(d_i[0    +: PP]), .s_i(w5), .b_i(d_i[0]),  .o_o(o_o[3]));
  // part-select bounds (the NEGATIVE control of the ips law)
  leaf65 u_pkg_ps (.a_i({27'b0, d_i[PW-1:PB]}), .s_i(w5), .b_i(d_i[0]), .o_o(o_o[4]));
  leaf65 u_loc_ps (.a_i({27'b0, d_i[LP-1:LB]}), .s_i(w5), .b_i(d_i[0]), .o_o(o_o[5]));
  // bare actual + operation operand
  leaf65 u_bare   (.a_i(32'(PW)), .s_i(w5), .b_i(d_i[0]), .o_o(o_o[6]));
  leaf65 u_op     (.a_i(32'(PW + 1)), .s_i(w5), .b_i(d_i[0]), .o_o(o_o[7]));

  // ---- cont_assign homes for the same three origins
  logic [4:0] ca_pkg, ca_loc, ca_por;
  assign ca_pkg = d_i[0  +: PW];
  assign ca_loc = d_i[0  +: LP];
  assign ca_por = d_i[0  +: PP];

  // ---- gen-for home
  logic [3:0] gf;
  for (genvar i = 0; i < 2; i++) begin : gen_for
    logic [4:0] gca;
    assign gca = d_i[i*8 +: PW];
    leaf65 u_gf_w (.a_i(d_i[0 +: PW]), .s_i(w5), .b_i(d_i[PB]), .o_o(gf[i]));
    leaf65 u_gf_l (.a_i(d_i[0 +: LP]), .s_i(w5), .b_i(d_i[LB]), .o_o(gf[i+2]));
  end

  // ---- gen-if home
  logic [1:0] gi;
  if (PP == 5) begin : gen_if
    leaf65 u_gi_w (.a_i(d_i[0 +: PW]), .s_i(w5), .b_i(d_i[PB]), .o_o(gi[0]));
    leaf65 u_gi_l (.a_i(d_i[0 +: LP]), .s_i(w5), .b_i(d_i[LB]), .o_o(gi[1]));
  end else begin : gen_if
    assign gi = 2'b0;
  end
endmodule
