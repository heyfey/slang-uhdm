// § unitBoundFoldAtLeftOperand200
parameter [`SW-1:0] U2 = 2;
parameter [`RW/2-1:0] U3 = 3;
package pp;
  parameter [`RW-1:0] P1 = 3;
  parameter [`SW*2-1:0] P2 = 4;
endpackage
module top;
  logic [31:0] y;
  assign y = D1 + U2 + U3 + pp::P1 + pp::P2;
endmodule
