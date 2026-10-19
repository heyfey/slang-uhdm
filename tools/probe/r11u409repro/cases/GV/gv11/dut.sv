// § genGateTermGenvarFold409
module top;
  wire [7:0] a, y;
  genvar i;
  for (i = 1; i < 3; i = i + 1) begin : g
    and g1 (y[i*2], a[i-1], a[2*i+1]);
  end
endmodule
