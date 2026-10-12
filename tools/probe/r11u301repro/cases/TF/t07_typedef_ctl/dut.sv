// § caTernTypeParamQueryNoFold301
module m #(parameter bit P = 0)();
  typedef logic [9:0] w_t;
  logic [7:0] arr[2];
  assign arr[0] = (P) ? $bits(w_t) : 7;
endmodule
module dut;
  m #(.P(1)) u_a();
endmodule
