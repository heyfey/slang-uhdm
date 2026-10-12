// § caSelLhsParamReuseAnyEnc301
module m #(parameter int A = 5)();
  localparam int Z = A * 2;
  logic [7:0] arr[2];
  assign arr[0] = Z;
endmodule
module dut;
  m #(.A(3)) u_a();
endmodule
