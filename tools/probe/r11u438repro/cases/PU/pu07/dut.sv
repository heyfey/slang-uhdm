// § caPlainLhsUnsizedClone438
module sub(input [15:0] b, output y);
  if (1) begin : g
    assign y = b['hA];
  end
endmodule
module top(input [15:0] b, output y);
  sub u(.b(b), .y(y));
endmodule
