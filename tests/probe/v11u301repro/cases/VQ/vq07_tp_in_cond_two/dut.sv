// § caTernTypeParamQueryNoFold301
module m #(parameter type T = logic [7:0])();
  logic [7:0] arr[2];
  assign arr[0] = ($bits(T) > 8) ? 1 : 7;
  assign arr[1] = ($bits(T) > 8) ? $bits(T) : 7;
endmodule
module dut;
  m #(.T(logic [15:0])) u_a();
  m u_b();
endmodule
