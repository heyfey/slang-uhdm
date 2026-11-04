// § pkgRefFoldClonesMultiDimOnly140
package p;
  parameter logic [1:0][3:0] X = 8'h5a;
endpackage
module cc #(parameter int Z = 0) (output int o);
  import p::*;
  localparam int P = X;
  assign o = P;
endmodule
module top(output int o); cc u(.o(o)); endmodule
