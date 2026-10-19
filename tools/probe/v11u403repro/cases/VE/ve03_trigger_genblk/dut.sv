// § unboundEventImplicitNet403
module top;
  if (1) begin : g
    event e;
  end
  initial -> g.e;
endmodule
