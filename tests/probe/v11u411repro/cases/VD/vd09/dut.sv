// § gateGenvarModFold411v
module top;
  wire [7:0] a, y;
  for (genvar i = 1; i < 4; i++) begin : g
    buf b1 (y[i%2], a[(i % 3)]);
    not n1 (y[i+4], a[i%2<<1]);
  end
endmodule
