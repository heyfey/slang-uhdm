// § unsignedScalarParamTsAtKeyword145
package pk;
  parameter bit unsigned P = 1'b1;
endpackage
module top(output bit o);
  import pk::*;
  assign o = P;
endmodule
