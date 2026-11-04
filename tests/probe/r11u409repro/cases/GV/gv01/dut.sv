// § genGateTermGenvarFold409
module top;
  wire [3:0] t [1:3];
  wire [3:0] a;
  genvar i;
  for (i = 0; i < 2; i = i + 1) begin : g
    xor g1 (t[1][i], a[i], a[i]);
  end
endmodule
