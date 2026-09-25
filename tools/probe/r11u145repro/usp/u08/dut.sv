// § unsignedScalarParamTsAtKeyword145
package pk;
  localparam logic unsigned P = 1'b1;
endpackage
module top(output logic o);
  import pk::*;
  assign o = P;
endmodule
