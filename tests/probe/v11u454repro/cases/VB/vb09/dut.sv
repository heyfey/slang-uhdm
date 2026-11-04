// § unpackedDimBasedLitKept454
package p;
  int pa [4'd1:4'd0];
  class C;
    int q [2'd1:0][];
    int r [1'b1:0][$];
    static logic [7:0] st [5'h1f:5'h1c];
  endclass
endpackage
module top;
  import p::*;
  C c;
  initial begin c = new; pa[0] = 1; end
endmodule
