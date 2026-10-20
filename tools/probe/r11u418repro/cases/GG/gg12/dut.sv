// § genGateTermGenNetBind418
module m (input [1:0] a, output [1:0] s);
  for (genvar i = 0; i < 2; i = i + 1) begin : b
    wire [1:0] t;
    xor g1 [1:0] (t, a, a);
    assign s[i] = t[i];
  end
endmodule
