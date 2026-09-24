// § pkgTsRefObjChainName134
package p;
   parameter int N = 4;
   parameter logic [N-1:0] A = '0;
   parameter logic [N:0] B = '0;
endpackage
module top(output logic [4:0] o);
   assign o = p::B;
endmodule
