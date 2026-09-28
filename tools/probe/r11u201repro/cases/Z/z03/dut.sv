// § unitBoundFoldAtLeftOperand200
localparam [4*8-1:0] A = 32'h10;
localparam [16/2-1:0] B = 8'h3;
localparam [(3+5)-1:0] C = 8'h3;
module z03(output logic [31:0] o);
  assign o = A + B + C;
endmodule
