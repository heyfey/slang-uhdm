// § defNetTypedefEndWrite134
package p;
   typedef struct packed {
      logic [7:0] x;
   } t;
endpackage
module top;
   import p::*;
   t a[2];
   logic [7:0] o;
   assign o = a[1].x;
endmodule
