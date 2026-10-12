// § caSelLhsParamReuseAnyEnc301
module m #(parameter int Z = 5)();
  logic [7:0] v;
  assign v[7 -: 4] = Z;
endmodule
module dut;
  m u_a();
endmodule
