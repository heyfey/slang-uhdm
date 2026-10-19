// § genGateTermGenvarFold409
module top;
  wire [3:0] a, y;
  genvar i;
  generate for (i = 0; i < 2; i = i + 1) begin : g
    and g1 (y[i], a[i], a[i+2]);
  end endgenerate
  and g2 (y[3], a[0], a[1]);
endmodule
