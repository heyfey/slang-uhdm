// § caSelLhsParamReuseAnyEnc301
module m #(parameter byte Z = 8'sd7)();
  logic [7:0] v;
  assign v[3:0] = Z;
endmodule
module dut;
  m u_a();
endmodule
