// § anonMemberRefChainName134
module top;
   typedef struct packed {
      struct packed {
         logic B;
         logic [1:0] C;
      } BC1;
      logic D;
   } s_t;
   s_t a;
   logic o;
   assign o = a.BC1.B;
endmodule
