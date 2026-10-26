// § ndaUnsizedRhsFreshLhs438
module top(input [15:0] b, output y);
  module nest(input [15:0] q, output r);
    wire w = q['h9];
    assign r = w;
  endmodule
  nest n(.q(b), .r(y));
endmodule
