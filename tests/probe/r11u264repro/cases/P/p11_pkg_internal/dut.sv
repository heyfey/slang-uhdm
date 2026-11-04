// § elabParamRefSignedTsUnlocated264
package pk;
  parameter int A = 3;
  parameter int B = A;
  localparam int C = (A > 2) ? B : 0;
endpackage
module top import pk::*; (output logic [7:0] o);
  localparam int D = B;
  assign o = C + D;
endmodule
