// § gateExprTermByGrammar402v
module top(output o1, output [1:0] o2, input [1:0] i);
  buf b1 (o1, o2[1], i[0]);
endmodule
