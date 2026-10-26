// § caPlainLhsUnsizedClone438
package p; localparam K = 2; endpackage
module sub(input [15:0] b, output y);
  assign y = b[p::K + 'h1];
endmodule
module top(input [15:0] b, output y);
  sub u(.b(b), .y(y));
endmodule
