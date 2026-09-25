// § unsignedScalarParamTsAtKeyword145
module child #(parameter bit unsigned P = 1'b0) (output bit o);
  assign o = P;
endmodule
module top(output bit a, output bit b);
  child #(.P(1'b1)) u0(a);
  child u1(b);
endmodule
