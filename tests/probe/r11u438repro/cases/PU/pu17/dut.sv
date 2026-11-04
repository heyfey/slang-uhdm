// § caPlainLhsUnsizedClone438 (a module localparam index)
module sub(input [15:0] b, output y);
  localparam K = 'hA;
  assign y = b[K];
endmodule
module top(input [15:0] b, output y);
  sub u(.b(b), .y(y));
endmodule
