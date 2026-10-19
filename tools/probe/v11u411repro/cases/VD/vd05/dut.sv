// § gateGenvarDivShiftFold411
module top;
  wire [15:0] a, y;
  for (genvar i = 0; i < 3; i++) begin : g
    buf b1 (y[i<<2], a[i<<1<<1]);
    not n1 (y[i*4>>1], a[16/(i+1)-1]);
  end
endmodule
