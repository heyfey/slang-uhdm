// § gateGenvarModFold411v
module top;
  wire [7:0] a, y;
  for (genvar i = 1; i < 4; i++) begin : g
    and a1 (y[i>>>1], a[i%2], a[(i-1)>>1]);
  end
endmodule
