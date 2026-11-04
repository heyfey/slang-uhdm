// § typedefParentLastWriter134
package p;
   typedef struct packed {
      logic [7:0] x;
      logic y;
   } t;
endpackage
package q;
   import p::*;
   typedef t [1:0] tt;
endpackage
module top(output logic [7:0] o);
   q::tt a;
   assign o = a[0].x;
endmodule
