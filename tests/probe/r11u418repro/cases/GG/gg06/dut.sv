// § genGateTermGenNetBind418
module m (input [1:0] a, output [1:0] s);
  wire t;
  and g0 (t, a[0], a[1]);
  for (genvar i = 0; i < 2; i = i + 1) begin : b
    xor g1 (s[i], t, a[i]);
  end
endmodule
