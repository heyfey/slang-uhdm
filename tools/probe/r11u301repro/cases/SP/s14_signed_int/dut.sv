// § caSelLhsParamReuseAnyEnc301
module m #(parameter int Z = -3)();
  logic [7:0] arr[2];
  assign arr[0] = Z;
endmodule
module dut;
  m u_a();
endmodule
