// § caSelLhsParamReuseAnyEnc301
module dut #(parameter int Z = 5)(output logic [7:0] v);
  assign v[3:0] = Z;
  assign v[7:4] = 4'h0;
endmodule
