// § contAssignLhsTsUnparented134
module top;
   typedef struct packed {
      logic [3:0] x;
   } s_t;
   s_t a;
   if (1) begin : g
      assign a = '0;
   end
endmodule
