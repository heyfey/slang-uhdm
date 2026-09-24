// § sysArgUnaryWholeSpan140
module sub #(parameter int P = 1) (output int o);
  assign o = P;
endmodule
module top(input logic [7:0] a, output int o);
  sub #(.P($bits(~a))) u(.o(o));
endmodule
