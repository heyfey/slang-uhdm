// § contAssignLhsTsUnparented134
module top;
   typedef struct packed {
      logic [3:0] x;
   } s_t;
   s_t a;
   always_comb a = '0;
endmodule
