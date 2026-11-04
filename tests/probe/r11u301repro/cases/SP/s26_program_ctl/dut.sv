// § caSelLhsParamReuseAnyEnc301
program p #(parameter int Z = 5)();
  logic [7:0] arr[2];
  assign arr[0] = Z;
endprogram
module dut;
  p u_p();
endmodule
