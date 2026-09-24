// § contAssignLhsTsUnparented134
package p;
   typedef struct packed {
      logic [7:0] x;
      logic y;
   } t;
endpackage
module top(input logic [8:0] i);
   p::t a;
   assign a = i;
endmodule
