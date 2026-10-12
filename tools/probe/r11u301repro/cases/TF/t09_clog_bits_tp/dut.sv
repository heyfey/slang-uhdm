// § caTernTypeParamQueryNoFold301
module m #(parameter type T = logic [7:0], parameter bit P = 0)();
  logic [7:0] arr[2];
  assign arr[0] = (P) ? $clog2($bits(T)) : 7;
endmodule
module dut;
  m #(.T(logic [15:0]), .P(1)) u_a();
endmodule
