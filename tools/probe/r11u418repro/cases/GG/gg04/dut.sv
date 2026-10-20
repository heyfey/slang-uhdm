// § genGateTermGenNetBind418
module m (input [1:0] a, output [1:0] s);
  for (genvar i = 0; i < 2; i = i + 1) begin : b
    wire [1:0] t;
    and g1 (t[0], a[i], a[0]);
    or g2 (s[i], t[0], a[1]);
  end
endmodule
