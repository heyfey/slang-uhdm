// § caSelLhsParamReuseAnyEnc301
module m #(parameter bit Z = 1)(output logic [3:0] o);
  assign o[2] = Z;
  assign o[1:0] = 2'b00;
  assign o[3] = 1'b0;
endmodule
module dut (output logic [3:0] o);
  m u_a(.o(o));
endmodule
