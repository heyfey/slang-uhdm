// § unsignedScalarParamTsAtKeyword145
package pk;
  parameter bit unsigned P = 1'b1;
endpackage
module top(output bit o);
  assign o = pk::P;
endmodule
