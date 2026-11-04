// § gateExprTermByGrammar402v
module top(output o1, output [1:0] o2, input [1:0] i);
  not (o1, o2[0], i[1]);
endmodule
