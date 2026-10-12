// § caSelLhsParamReuseAnyEnc301
module m #(parameter int Z = 5)();
  logic [7:0] v;
  assign v[3:0] = Z;
endmodule
module dut;
  m u_a();
  m u_b();
endmodule
