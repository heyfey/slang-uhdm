// § caSelLhsParamReuseAnyEnc301
module m #(parameter logic [3:0] Z = 4'b1010)();
  logic [7:0] arr[2];
  assign arr[0] = Z;
endmodule
module dut;
  m u_a();
endmodule
