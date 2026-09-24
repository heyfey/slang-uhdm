// § pkgRefFoldClonesMultiDimOnly140
package pk;
  localparam int X = 4;
  parameter int Q = X;
endpackage
module cc import pk::*; #(parameter logic Z = 0) ();
endmodule
module top;
  cc #(.Z(1)) u();
endmodule
