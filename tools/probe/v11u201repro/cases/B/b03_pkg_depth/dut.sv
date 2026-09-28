// § unitBoundFoldAtLeftOperand200
package p;
  parameter int W = 4;
  parameter [(W*2)-1:0] A = 1;
  parameter [W*2*2-1:0] B = 2;
  parameter [-1+8:0] C = 3;
  parameter [W-1-1:0] D = 4;
  parameter [0:W*2-1] E = 5;
endpackage
module top;
  logic [31:0] y;
  assign y = p::A + p::B + p::C + p::D + p::E;
endmodule
