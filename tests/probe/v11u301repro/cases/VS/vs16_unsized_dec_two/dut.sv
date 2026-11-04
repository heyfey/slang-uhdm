// § caSelLhsParamReuseAnyEnc301
module m #(parameter Z = 5)();
  logic [7:0] v;
  assign v[3:0] = Z;
  assign v[7:4] = Z;
endmodule
module dut;
  m #(.Z(3)) u_a();
  m u_b();
endmodule
