// § anonMemberRefChainName134
module top;
   struct packed {
      struct packed {
         logic B;
         logic [1:0] C;
      } BC1;
      logic D;
   } a;
   logic o;
   assign o = a.BC1.B;
endmodule
