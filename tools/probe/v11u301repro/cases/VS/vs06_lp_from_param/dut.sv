// § caSelLhsParamReuseAnyEnc301
module m #(parameter int Z = 5)();
  logic [7:0] v;
  localparam int L = Z * 2;
  assign v[7:4] = L;
endmodule
module dut;
  m #(.Z(3)) u_a();
endmodule
