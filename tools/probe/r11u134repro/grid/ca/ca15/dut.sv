// § contAssignLhsTsUnparented134
package p;
   typedef struct packed {
      logic [7:0] x;
   } t;
endpackage
module sub(input p::t q);
endmodule
module top;
   import p::*;
   t a;
   assign a = '0;
   sub u(.q(a));
endmodule
