// § decUnszElabRespellKeepsM1_423
module sub #(parameter T = 'd12) (output int o);
  assign o = T + 0;
endmodule
module top(output int y);
  defparam u.T = 4;
  sub u(.o(y));
endmodule
