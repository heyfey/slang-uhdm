// § elabCloneInstTreeUnstored144
module m(input logic a, b, c, clk1);
  property p(x, y); @(posedge clk1) x |=> y; endproperty
  always @(posedge clk1) begin
    a3: assert property (p(a, b));
  end
endmodule
