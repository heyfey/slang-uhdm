// § unsignedScalarParamTsAtKeyword145
module top(output bit o, output bit p);
  parameter bit unsigned P = 1'b1, Q = 1'b0;
  assign o = P;
  assign p = Q;
endmodule
