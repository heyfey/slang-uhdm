// § genGateTermGenvarFold409
module top;
  wire [7:0] a, b, y;
  for (genvar i = 1; i < 4; i++) begin : g
    and g1 (y[i-1], a[i], b[i-1]);
  end
endmodule
