// § caSelLhsParamReuseAnyEnc301
module m #(parameter int Z = 5)(output logic [7:0] o);
  assign o = Z;
endmodule
module dut (output logic [7:0] o);
  m u_a(.o(o));
endmodule
