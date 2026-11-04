// § genGateTermGenNetBind418
module m (input [1:0] a, output [1:0] s);
  for (genvar i = 0; i < 2; i = i + 1) begin : b
    wire t = a[i];
    xor g1 (s[i], t, a[0]);
  end
endmodule
