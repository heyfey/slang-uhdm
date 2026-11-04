// § unitBoundFoldAtLeftOperand200
`define XL 4*8
`define YL (16)
parameter [`XL-1:0] Q1 = 1;
parameter [`YL-1:0] Q2 = 2;
parameter [`XL/2-1:0] Q3 = 3;
module top;
  logic [31:0] y;
  assign y = Q1 + Q2 + Q3;
endmodule
