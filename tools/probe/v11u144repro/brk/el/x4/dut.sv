// § elabCloneInstTreeUnstored144
module m(input logic clk, input logic [1:0] a, b);
  property p1(x, y);
    @(posedge clk) x |=> y;
  endproperty
  for (genvar i = 0; i < 2; i++) begin : g
    ap: assert property (p1(a[i], b[i]));
  end
  always @(posedge clk) begin
    cp: cover property (p1(a[0], b[1]));
  end
endmodule
