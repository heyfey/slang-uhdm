// § anonMemberRefChainName134
// § memberAnonUnionAtKeyword134
module top;
   typedef struct packed {
      union packed {
         logic [1:0] B;
         logic [1:0] C;
      } U;
      logic D;
   } s_t;
   s_t a;
   logic [1:0] o;
   assign o = a.U.C;
endmodule
