// § typedefParentLastWriter134
package p;
   typedef struct packed {
      logic [7:0] x;
      logic y;
   } t;
endpackage
module top(output logic o);
   import p::*;
   assign o = 1'b0;
endmodule
