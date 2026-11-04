// § contAssignLhsTsUnparented134
package p;
   typedef struct packed {
      logic [3:0] x;
   } t;
endpackage
module top;
   import p::*;
   p::t a;
   assign a = '0;
endmodule
