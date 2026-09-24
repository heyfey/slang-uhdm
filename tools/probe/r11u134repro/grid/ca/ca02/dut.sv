// § contAssignLhsTsUnparented134
module top;
   typedef struct packed {
      logic [3:0] x;
   } s_t;
   s_t a = '0;
   logic [3:0] o;
   assign o = a.x;
endmodule
