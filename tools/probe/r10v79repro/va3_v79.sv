// r10v79 adversarial arm 3 — a SIZE-form-only control: nothing here may move.
package pv3;
  parameter int unsigned PA = 5;
  parameter int          PB = 9;
endpackage
module sinkv3 import pv3::*; #(
  parameter int unsigned N = 4,
  parameter int          S = 6
) (
  input logic clk,
  output logic [7:0] o_n [N]
);
  localparam int unsigned LU = 7;
  localparam int          LS = 9;
  logic [7:0] a_n   [N];
  logic [7:0] a_s   [S];
  logic [7:0] a_lu  [LU];
  logic [7:0] a_ls  [LS];
  logic [7:0] a_pa  [PA];
  logic [7:0] a_qpa [pv3::PA];
  logic [7:0] a_qpb [pv3::PB];
  logic [7:0] a_lit [12];
  wire  [7:0] w_n   [N];
  logic [N-1:0] pk_n;
  for (genvar gi = 0; gi < 2; gi++) begin : gg
    logic [7:0] g_n [N];
    logic [7:0] g_s [S];
  end
  assign o_n = a_n;
endmodule
module topv3;
  logic clk;
  logic [7:0] q1 [3], q2 [5], q3 [7];
  sinkv3 #(.N(3), .S(4)) u_a (.clk(clk), .o_n(q1));
  sinkv3 #(.N(5), .S(8)) u_b (.clk(clk), .o_n(q2));
  sinkv3 #(.N(7), .S(2)) u_c (.clk(clk), .o_n(q3));
endmodule
