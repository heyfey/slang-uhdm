// § sysArgUnaryWholeSpan140
module top(input logic [7:0] a, output int o);
  assign o = $bits(~a) + 1;
endmodule
