// § unitBoundFoldAtLeftOperand200
localparam [2*8-1:0] A = 16'h10;
localparam int B = (A << 2) + 3 - 1;
parameter [3*4-1:0] C = 12'h3 + 2 * 3;
localparam [8-1-1:0] D = 7'h1 | 7'h2 | 7'h4;
module f01(output logic [31:0] o);
  assign o = A + B + C + D;
endmodule
