// § typedefParentLastWriter134
package p;
   typedef struct packed {
      logic [7:0] x;
      logic y;
   } t;
endpackage
interface ifc;
   import p::*;
   t a;
endinterface
module top;
   ifc i();
endmodule
