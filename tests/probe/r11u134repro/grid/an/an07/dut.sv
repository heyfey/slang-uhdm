// § anonMemberRefChainName134
module top;
   typedef struct {
      int A;
      struct {
         logic B;
         int C;
      } BC1;
   } s_t;
   s_t a;
   initial a.BC1.C = 1;
endmodule
