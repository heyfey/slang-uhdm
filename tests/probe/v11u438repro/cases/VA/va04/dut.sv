// § caPlainLhsUnsizedClone438
module sub(input [15:0] b, output y);
  assign y = b['h3];
endmodule
module top(input [15:0] b, output [1:0] y);
  for (genvar i = 0; i < 2; i++) begin : g
    sub u(.b(b), .y(y[i]));
  end
endmodule
