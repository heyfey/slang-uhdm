// § caSelLhsParamReuseAnyEnc301
module m #(parameter int Z = 5)();
  logic [7:0] arr[2];
  assign arr[1] = Z;
endmodule
module dut;
  m u_a();
endmodule
