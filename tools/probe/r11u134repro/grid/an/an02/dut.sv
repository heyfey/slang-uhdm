// § anonMemberRefChainName134
module top;
   typedef struct packed {
      struct packed {
         logic B;
         logic [1:0] C;
      } BC1, BC2;
   } s_t;
   s_t a;
   logic o;
   assign o = a.BC2.B;
endmodule
