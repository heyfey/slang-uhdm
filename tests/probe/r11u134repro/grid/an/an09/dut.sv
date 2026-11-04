// § anonMemberRefChainName134
module top(input logic [3:0] i, output logic o);
   typedef struct packed {
      struct packed {
         logic B;
         logic [2:0] C;
      } BC1;
   } s_t;
   s_t a;
   assign a = i;
   assign o = a.BC1.B;
endmodule
