// § typedefParentLastWriter134
package p;
   typedef struct packed {
      logic [7:0] x;
      logic y;
   } t;
endpackage
module top import p::*; (output logic [7:0] o);
   t a;
   assign o = a.x;
endmodule
