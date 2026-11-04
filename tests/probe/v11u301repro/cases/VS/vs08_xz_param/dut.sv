// § caSelLhsParamReuseAnyEnc301
module m #(parameter logic [3:0] X = 4'bx01x)();
  logic [7:0] v;
  assign v[3:0] = X;
endmodule
module dut;
  m u_a();
endmodule
