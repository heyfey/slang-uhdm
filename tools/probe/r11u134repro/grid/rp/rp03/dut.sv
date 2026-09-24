// § pkgTsRefObjChainName134
package p;
   parameter int N = 4;
   parameter logic [N-1:0] A = '0;
endpackage
module top(output logic [3:0] o);
   import p::*;
   assign o = A;
endmodule
