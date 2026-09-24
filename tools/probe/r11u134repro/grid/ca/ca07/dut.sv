// § contAssignLhsTsUnparented134
module top;
   typedef struct packed {
      logic [3:0] x;
   } s_t;
   s_t a [2];
   assign a[0] = '0;
endmodule
