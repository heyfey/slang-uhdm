// § gateGenvarModFold411v
module top;
  wire [7:0] a, y;
  for (genvar i = 0; i < 4; i++) begin : g
    and a1 (y[(i+1)%4], a[i%3+1], a[2*i%5]);
  end
endmodule
