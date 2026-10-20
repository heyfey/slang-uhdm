// § genGateTermGenNetBind418
module m (input [1:0] a, output [1:0] s);
  for (genvar i = 0; i < 2; i = i + 1) begin : b
    wire t1;
    xor (t1, a[i], a[0]);
    assign s[i] = t1;
  end
endmodule
