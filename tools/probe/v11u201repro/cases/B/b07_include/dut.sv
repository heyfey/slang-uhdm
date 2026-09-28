// § unitBoundFoldAtLeftOperand200
`include "defs.svh"
parameter [`IW-1:0] U1 = 1;
parameter [`JW-1:0] U2 = 2;
package pp;
  parameter [`IW-1:0] P1 = 3;
  parameter [`JW-1:0] P2 = 4;
endpackage
module top;
  logic [31:0] y;
  assign y = U1 + U2 + pp::P1 + pp::P2;
endmodule
