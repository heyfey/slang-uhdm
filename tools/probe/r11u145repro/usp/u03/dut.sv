// § unsignedScalarParamTsAtKeyword145
module top #(parameter reg unsigned P = 1'b0) (output logic o);
  assign o = P;
endmodule
