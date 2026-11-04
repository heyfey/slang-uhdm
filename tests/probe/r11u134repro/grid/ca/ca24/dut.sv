// § contAssignLhsTsUnparented134
package p;
   typedef struct packed {
      logic [3:0] x;
   } t;
endpackage
module top;
   import p::*;
   p::t a;
   logic [7:0] b;
   for (genvar i = 0; i < 1; i++) begin : g
      logic [31:0] a;
      assign a = 32'd1;
   end
   assign b = g[0].a;
endmodule
