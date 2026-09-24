// § defNetTypedefEndWrite134
package p;
   typedef struct packed {
      logic [7:0] x;
   } t;
endpackage
module sub;
   import p::*;
   t q[3];
endmodule
module top;
   import p::*;
   t a[2];
   sub u();
endmodule
