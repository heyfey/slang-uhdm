// § pkgRefFoldClonesMultiDimOnly140
package pk;
  localparam int X = 4;
  parameter int Q = X;
endpackage
module cc #(parameter logic Z = 0) ();
  import pk::*;
  localparam int R = Q + 1;
endmodule
module top;
  cc #(.Z(1)) u();
endmodule
