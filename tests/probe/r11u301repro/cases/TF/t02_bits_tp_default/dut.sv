// § caTernTypeParamQueryNoFold301
module m #(parameter type T = logic [7:0], parameter bit P = 1)();
  logic [7:0] arr[2];
  assign arr[0] = (P) ? $bits(T) : 7;
endmodule
module dut;
  m u_a();
endmodule
