// § unitBoundFoldAtLeftOperand200
package q;
  parameter int W = 4;
  localparam [W*2-1:0] E = 8'h3;
  localparam [2*4*2-1:0] F = 16'h3;
  localparam [8-1-1:0] G = 7'h3;
endpackage
module z04(output logic [31:0] o);
  assign o = q::E + q::F + q::G;
endmodule
