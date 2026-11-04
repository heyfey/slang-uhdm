// § elabMosPullPrims402
module top(output [1:0] o, input [1:0] i, input en);
  bufif1 b[1:0] (o, i, en);
endmodule
