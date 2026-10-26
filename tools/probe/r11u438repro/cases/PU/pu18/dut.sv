// § caPlainLhsUnsizedClone438 (a named delay: the delay leg clones first)
module sub #(parameter D = 2) (input [15:0] b, output y);
  assign #D y = b['hA];
endmodule
module top(input [15:0] b, output y);
  sub u(.b(b), .y(y));
endmodule
