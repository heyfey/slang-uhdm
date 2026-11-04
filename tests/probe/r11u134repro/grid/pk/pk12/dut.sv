// § typedefParentLastWriter134
package p;
   typedef struct packed {
      logic [7:0] x;
      logic y;
   } t;
endpackage
import p::*;
module top(output logic [7:0] o);
   t a;
   assign o = a.x;
endmodule
