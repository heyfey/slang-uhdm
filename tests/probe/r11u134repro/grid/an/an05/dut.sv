// § anonMemberRefChainName134
module top;
   typedef struct packed {
      struct packed {
         struct packed {
            logic y;
            logic z;
         } X;
         logic B;
      } BC1;
      logic D;
   } s_t;
   s_t a;
   logic o;
   assign o = a.BC1.X.z;
endmodule
