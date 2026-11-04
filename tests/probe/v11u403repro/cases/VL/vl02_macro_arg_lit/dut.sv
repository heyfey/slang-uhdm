// § macroVecLitTokenText403
`define PAIR(x, y) {x, y}
module top(output [7:0] o);
  assign o = `PAIR(4'b1010, 4'h3);
endmodule
