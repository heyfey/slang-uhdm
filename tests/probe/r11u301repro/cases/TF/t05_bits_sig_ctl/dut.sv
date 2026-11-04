// § caTernTypeParamQueryNoFold301
module m #(parameter bit P = 0)();
  logic [11:0] q;
  logic [7:0] arr[2];
  assign arr[0] = (P) ? $bits(q) : 7;
endmodule
module dut;
  m #(.P(1)) u_a();
endmodule
