module m(input logic clk, rst, input logic [1:0] a, b);
  for (genvar i = 0; i < 2; i++) begin : g
    property p1;
      @(posedge clk) disable iff (rst) a[i] |-> b[i];
    endproperty
    a1: assert property (p1);
  end
endmodule
