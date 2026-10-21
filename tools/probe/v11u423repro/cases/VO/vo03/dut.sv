// § octUnszElabRespell423
module sub #(parameter O = 'o17) (output int o);
  assign o = O + 0;
endmodule
module top(output int y, output int z);
  sub #(.O('o5)) u1(.o(y));
  sub u2(.o(z));
endmodule
