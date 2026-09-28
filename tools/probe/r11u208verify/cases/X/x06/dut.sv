// § unitBoundFoldAtLeftOperand200
localparam int M = 3;
localparam [M*4-1:0] R = (M << 2) | 1;
localparam [2*M-1:0] S = M * 2 + 1 - 1;
module x06(output logic [31:0] o, output logic [R-1:0] p);
  assign o = R + S;
  assign p = '0;
endmodule
