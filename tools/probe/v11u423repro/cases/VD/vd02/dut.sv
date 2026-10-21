// § decUnszElabRespellKeepsM1_423
module sub #(parameter T = 'd12) (output int o);
  assign o = T + 0;
endmodule
module top(output int y, output int z, output int w);
  sub #(.T(5)) u1(.o(y));
  sub #(.T(8'd5)) u2(.o(z));
  sub #(.T('d7)) u3(.o(w));
endmodule
