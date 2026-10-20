// § genGateTermGenNetBind418
module m (input [1:0] a, output [1:0] s);
  for (genvar i = 0; i < 2; i = i + 1) begin : b
    tri t;
    supply0 z;
    nand g1 (t, a[i], z);
    assign s[i] = t;
  end
endmodule
