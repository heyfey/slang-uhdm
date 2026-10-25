// § sgnBinPkgCopyAbstain427v
package p;
  parameter D = 4'sb1010;
endpackage
module top(output [7:0] o);
  import p::*;
  assign o = D;
endmodule
