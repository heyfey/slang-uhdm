// § elabMosPullPrims402
module top(input [3:0] in, input en, output [3:0] out);
  bufif0 ar[3:0] (out, in, en);
endmodule
