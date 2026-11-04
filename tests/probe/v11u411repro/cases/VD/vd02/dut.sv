// § gateGenvarDivShiftFold411
module top;
  wire [7:0] a, y;
  for (genvar i = 2; i < 4; i++) begin : g
    or o1 (y[(i<<1)-1], a[i/2+1], a[(i-4)/2+4]);
  end
endmodule
