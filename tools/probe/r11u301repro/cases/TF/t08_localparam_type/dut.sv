// § caTernTypeParamQueryNoFold301
module m #(parameter bit P = 0)();
  localparam type T = logic [5:0];
  logic [7:0] arr[2];
  assign arr[0] = (P) ? $bits(T) : 7;
endmodule
module dut;
  m #(.P(1)) u_a();
endmodule
