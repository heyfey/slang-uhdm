// § genGateTermGenNetBind418
module m (input [1:0] a, output [1:0] s);
  for (genvar i = 0; i < 2; i = i + 1) begin : b
    wire t1, t2;
    bufif1 g1 (t1, a[i], a[0]);
    tran g2 (t1, t2);
    assign s[i] = t2;
  end
endmodule
