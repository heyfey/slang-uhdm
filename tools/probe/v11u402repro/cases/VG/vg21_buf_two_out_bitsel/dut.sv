// § gateExprTermByGrammar402v
module top(output [1:0] o, input [1:0] i);
  buf b1 (o[0], o[1], i[1]);
endmodule
