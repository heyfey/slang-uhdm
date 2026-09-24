// § pkgRefFoldClonesMultiDimOnly140
package pk;
  parameter logic [1:0][3:0] X = 8'h5a;
  parameter logic [1:0][3:0] Q = X;
endpackage
module cc #(parameter logic Z = 0) ();
  import pk::*;
  localparam logic [1:0][3:0] R = Q;
endmodule
module top;
  cc #(.Z(1)) u();
endmodule
