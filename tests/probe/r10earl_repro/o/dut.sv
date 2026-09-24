module om #(
  parameter int          I1  = 'b1,
  parameter int          I0  = 'b0,
  parameter integer      G1  = 'b1,
  parameter bit [7:0]    B1  = 'b1,
  parameter logic [7:0]  L1  = 'b1,
  parameter logic [7:0]  U1  = '1,
  parameter logic [7:0]  U0  = '0,
  parameter int          IU1 = '1,
  parameter logic [7:0]  O0  = 'o0,
  parameter logic [7:0]  D0  = 'd0,
  parameter logic [7:0]  H0  = 'h0,
  parameter shortint     S1  = 'ha,
  parameter byte         Y1  = 'o3
) (
  input clk_i
);
endmodule
