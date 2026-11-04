// § genGateTermGenNetBind418
module m (input [1:0] a, output [1:0] s);
  for (genvar i = 0; i < 2; i = i + 1) begin : b
    reg r;
    wire t;
    xor g1 (t, a[i], r);
    assign s[i] = t;
  end
endmodule
