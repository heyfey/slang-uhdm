// § genGateTermGenNetBind418
module m (input [1:0] a, output [1:0] s);
  for (genvar i = 0; i < 2; i = i + 1) begin : o
    wire t;
    for (genvar j = 0; j < 1; j = j + 1) begin : n
      xor g1 (t, a[i], a[j]);
    end
    assign s[i] = t;
  end
endmodule
