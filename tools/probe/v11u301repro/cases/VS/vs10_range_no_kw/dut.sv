// § caSelLhsParamReuseAnyEnc301
module m #(parameter [3:0] Z = 4'd9)();
  logic [7:0] v;
  assign v[7:4] = Z;
endmodule
module dut;
  m u_a();
endmodule
