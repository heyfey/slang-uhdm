// § caPlainLhsUnsizedClone438
module sub(input [15:0] b, output y);
  localparam int L = 'h3;
  assign y = b[L];
endmodule
module top(input [15:0] b, output y);
  sub u(.b(b), .y(y));
endmodule
