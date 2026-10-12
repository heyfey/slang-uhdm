// § caSelLhsParamReuseAnyEnc301
module m #(parameter real R = 2.0)();
  logic [7:0] v;
  assign v[3:0] = R;
endmodule
module dut;
  m u_a();
endmodule
