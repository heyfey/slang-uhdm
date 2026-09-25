// § unsignedScalarParamTsAtKeyword145 (control: signed)
module top(output bit o);
  parameter bit signed P = 1'sb1;
  assign o = P;
endmodule
