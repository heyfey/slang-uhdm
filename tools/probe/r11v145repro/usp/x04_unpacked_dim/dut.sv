// § unsignedScalarParamTsAtKeyword145
module top(output bit o);
  parameter bit unsigned P [2] = '{1'b1, 1'b0};
  assign o = P[0];
endmodule
