// § caSelLhsParamReuseAnyEnc301
module m #(parameter bit B = 1)();
  wire [7:0] w;
  assign w[0] = B;
endmodule
module dut;
  m u_a();
endmodule
