// § pkgTdCloneBoundLoc134
package p;
   parameter int X = 8;
   typedef logic [X-1:0] t;
endpackage
module top(output logic [7:0] o);
   import p::*;
   t v;
   assign v = 8'h5;
   assign o = v;
endmodule
