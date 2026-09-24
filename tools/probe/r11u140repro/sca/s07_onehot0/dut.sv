// § sysArgUnaryWholeSpan140
module top(input logic [7:0] a, input logic [7:0] b, output wire [31:0] out);
  assign out = $onehot0(~a);
endmodule
