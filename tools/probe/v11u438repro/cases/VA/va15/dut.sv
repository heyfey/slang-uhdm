// § caPlainLhsUnsizedClone438
module top(input [15:0] b, output y);
  module nest(input [15:0] q, output r);
    assign r = q['h7];
  endmodule
  nest n(.q(b), .r(y));
endmodule
