// § pkgTsRefObjChainName134
package p;
   parameter int W = 8;
   typedef logic [W-1:0] seed_t;
   typedef struct packed {
      seed_t s;
      logic [W-1:0] t;
   } st_t;
   parameter st_t C = '0;
endpackage
module top(output logic [15:0] o);
   assign o = p::C;
endmodule
