// § gateInBitSelIndexSpan402
module top(output [1:0] o, input [1:0] i, input c);
  nmos n1 (o[1], i[0], c);
endmodule
