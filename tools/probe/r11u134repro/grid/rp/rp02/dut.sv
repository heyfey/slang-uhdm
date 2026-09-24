// § pkgTsRefObjChainName134
package p;
   parameter int W = 8;
   typedef logic [W-1:0] seed_t;
   parameter seed_t S = 8'h5;
endpackage
module top(output logic [7:0] o);
   assign o = p::S;
endmodule
