// § gateGenvarDivShiftFold411 § gateGenvarParenLeftSpan411
module top;
  wire [7:0] a, y;
  wire en;
  for (genvar i = 1; i < 3; i++) begin : g
    bufif0 b1 (y[i/2+3], a[(i<<1)+1], en);
  end
endmodule
