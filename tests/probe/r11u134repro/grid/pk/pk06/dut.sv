// § typedefParentLastWriter134
package p;
   typedef struct packed {
      logic [7:0] x;
      logic y;
   } t;
endpackage
module top(input logic [8:0] i, output logic [7:0] o);
   import p::*;
   t a;
   assign a = i;
   assign o = a.x;
endmodule
