// § pkgTsForeignQualRefUnstored144
package p;
  localparam int W = 8;
endpackage
package q;
  class C;
    logic [p::W-1:0] m;
  endclass
endpackage
module top; endmodule
