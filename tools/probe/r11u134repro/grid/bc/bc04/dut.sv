// § defNetScopedPkgVecTdShares134
// § pkgTdCloneBoundLoc134
package p;
   parameter int X = 8;
   typedef logic [X-1:0] t;
endpackage
module top(output logic [7:0] o);
   p::t v = 8'h5C;
   assign o = v;
endmodule
