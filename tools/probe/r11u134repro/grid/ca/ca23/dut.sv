// § contAssignLhsTsUnparented134
package p;
   typedef struct packed {
      logic [3:0] x;
   } t;
endpackage
module top;
   import p::*;
   p::t a;
   for (genvar i = 0; i < 1; i++) begin : g
      logic [3:0] a;
      assign a = '0;
   end
endmodule
