module m #(parameter int N = 3) (input logic clk, rst, a, b, c);
  property p1;
    @(posedge clk) a |-> b[*1:N];
  endproperty
  a1: assert property (p1);
endmodule
