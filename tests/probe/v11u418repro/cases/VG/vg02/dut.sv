// § genGateTermGenNetBind418
module sub (input [1:0] a, output [1:0] s);
  for (genvar i = 0; i < 2; i = i + 1) begin : b
    wire t;
    xor g1 (t, a[i], a[0]);
    assign s[i] = t;
  end
endmodule
module top (input [1:0] a, output [1:0] s1, s2);
  sub u1 (a, s1);
  sub u2 (a, s2);
endmodule
