// § macroVecLitTokenText403
`define W(n) n``'d5
module top(output [7:0] o);
  assign o = `W(8);
endmodule
