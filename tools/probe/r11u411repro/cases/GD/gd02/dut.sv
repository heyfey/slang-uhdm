// § gateGenvarDivShiftFold411
module top;
  wire [7:0] a, y;
  for (genvar i = 0; i < 3; i++) begin : g
    buf b1 (y[i<<1], a[i>>1]);
  end
endmodule
