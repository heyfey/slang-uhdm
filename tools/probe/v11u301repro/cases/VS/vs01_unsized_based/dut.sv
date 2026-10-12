// § caSelLhsParamReuseAnyEnc301
module m #(parameter Z = 'hF)();
  logic [7:0] v;
  assign v[3:0] = Z;
endmodule
module dut;
  m u_a();
endmodule
