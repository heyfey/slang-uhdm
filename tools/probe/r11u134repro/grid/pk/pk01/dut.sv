// § typedefParentLastWriter134
package p;
   typedef struct packed {
      logic [7:0] x;
      logic y;
   } t;
endpackage
module top(output logic [7:0] o);
   import p::*;
   t a;
   assign o = a.x;
endmodule
