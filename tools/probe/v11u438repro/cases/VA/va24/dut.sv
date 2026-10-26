// § caPlainLhsUnsizedClone438
module sub(input [15:0] b, output y);
  if (1) begin : g
    assign y = b['hB];
  end
endmodule
module top(input [15:0] b, output y);
  sub u(.b(b), .y(y));
  sub v(.b(~b), .y());
endmodule
