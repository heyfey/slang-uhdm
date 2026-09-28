// § unitBoundFoldAtLeftOperand200
parameter W = 8;
parameter [W-1:0] P1 = 3;
parameter [2*W-1:0] P2 = 5;
parameter [(W+W)-1:0] P3 = 7;
parameter [0:W-1] P4 = 1;
module top;
  logic [15:0] y;
  assign y = P1 + P2 + P3 + P4;
endmodule
