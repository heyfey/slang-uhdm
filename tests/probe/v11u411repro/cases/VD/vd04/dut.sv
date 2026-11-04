// § gateGenvarParenWsSpan411v
module top;
  wire [7:0] a, y;
  for (genvar i = 0; i < 3; i++) begin : g
    and a1 (y[( i+1)*2], a[(i+1 )+1], a[ (i+1) +2]);
  end
endmodule
