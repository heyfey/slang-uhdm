// § unitBoundFoldAtLeftOperand200
parameter [7:0] R1 = 1;
parameter [$clog2(16)-1:0] R2 = 2;
parameter [8'd7:0] R3 = 3;
localparam [3*2+1:0] R4 = 4;
parameter [1+1+1:0] R5 = 5;
module top;
  logic [31:0] y;
  assign y = R1 + R2 + R3 + R4 + R5;
endmodule
