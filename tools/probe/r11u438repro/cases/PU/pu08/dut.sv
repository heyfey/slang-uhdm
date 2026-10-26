// § caPlainLhsUnsizedClone438
module sub(input [15:0] b, output [4:0] y);
  assign y = $countones(b['hF:'h0]);
endmodule
module top(input [15:0] b, output [4:0] y);
  sub u(.b(b), .y(y));
endmodule
