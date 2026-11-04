// § unitBoundFoldAtLeftOperand200
`define PW 2*4
package q;
  parameter [`PW-1:0] A = 1;
  parameter [`PW*2-1:0] B = 2;
endpackage
parameter [`PW+`PW-1:0] U = 3;
module top;
  logic [31:0] y;
  assign y = q::A + q::B + U;
endmodule
