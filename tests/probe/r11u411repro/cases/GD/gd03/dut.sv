// § gateGenvarDivShiftFold411 § gateGenvarParenLeftSpan411
module top;
  wire [7:0] a, y;
  for (genvar i = 0; i < 3; i++) begin : g
    and a1 (y[(i+2)/2], a[i], a[i*2>>1]);
  end
endmodule
