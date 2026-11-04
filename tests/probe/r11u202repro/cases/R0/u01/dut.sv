// § unitBoundFoldAtLeftOperand200
localparam int M = 2;
localparam int X = (M << 3) | 4 | 1;
localparam int Y = M * 2 + 3 - 1;
module u01(output logic [31:0] o);
  assign o = X + Y;
endmodule
