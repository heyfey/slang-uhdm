// § caSelLhsParamReuseAnyEnc301
module m #(parameter int Z = 5)();
  logic [7:0] v;
  assign v[3:0] = Z;
endmodule
module dut;
  m #(.Z(1)) u_a();
  m #(.Z(2)) u_b();
endmodule
