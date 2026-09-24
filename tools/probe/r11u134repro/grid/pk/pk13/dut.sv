// § typedefParentLastWriter134
package p;
   typedef struct packed {
      logic [7:0] x;
      logic y;
   } t;
endpackage
module top(input p::t i, output logic [7:0] o);
   import p::*;
   assign o = i.x;
endmodule
