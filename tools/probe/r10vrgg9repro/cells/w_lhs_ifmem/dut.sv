interface bif;
  logic [7:0] d;
endinterface
module m #(parameter bit P = 0)(bif b);
  assign b.d = (P) ? 8'd42 : 8'd7;
endmodule
module top;
  bif bi();
  m #(.P(1)) u_a(bi);
endmodule
