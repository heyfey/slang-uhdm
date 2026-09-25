module top(output wire o);
  for (genvar k = 0; k < 2; k++) begin : g
    wire x;
  end
  assign g[0].x = 1'b0;
  assign g[1].x = 1'b1;
  assign o = g[0].x;
endmodule
