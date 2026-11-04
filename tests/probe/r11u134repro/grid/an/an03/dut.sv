// § anonMemberRefChainName134
module top;
   typedef union packed {
      struct packed {
         logic [3:0] hi;
         logic [3:0] lo;
      } byte4;
      logic [7:0] w;
   } u_t;
   u_t a;
   logic [3:0] o;
   assign o = a.byte4.lo;
endmodule
