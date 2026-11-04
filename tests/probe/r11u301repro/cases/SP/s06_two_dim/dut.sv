// § caSelLhsParamReuseAnyEnc301
module m #(parameter int Z = 7)();
  logic [7:0] arr[2][3];
  assign arr[1][2] = Z;
endmodule
module dut;
  m u_a();
endmodule
