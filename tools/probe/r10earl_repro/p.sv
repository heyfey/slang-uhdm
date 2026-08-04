module pm #(
  parameter byte         AB1 = 'b1,
  parameter byte         AB0 = 'b0,
  parameter shortint     AS1 = 'b1,
  parameter longint      AL1 = 'b1,
  parameter integer      AG0 = 'b0,
  parameter bit          AT1 = 'b1,
  parameter logic        AO1 = 'b1,
  parameter int unsigned AUI = 'b1,
  parameter int          AI1 = 'b1,
  parameter int          AI0 = 'b0,
  parameter bit [31:0]   AV1 = 'b1
) (
  input clk_i
);
endmodule
