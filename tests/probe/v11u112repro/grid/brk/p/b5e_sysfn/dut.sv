module m(input logic clk, rst, en, a, b);
  property p1;
    @(posedge clk) disable iff (rst || !en) $rose(a) |=> $fell(b);
  endproperty
  a1: assert property (p1) else $error("bad");
endmodule
