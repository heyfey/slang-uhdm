// § anonMemberRefChainName134
package p;
   typedef struct packed {
      struct packed {
         logic B;
         logic [1:0] C;
      } BC1;
      logic D;
   } s_t;
endpackage
module top;
   p::s_t a;
   logic o;
   assign o = a.BC1.B;
endmodule
