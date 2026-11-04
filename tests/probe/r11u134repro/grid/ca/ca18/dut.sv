// § contAssignLhsTsUnparented134
module top;
   typedef struct packed {
      logic [3:0] x;
   } s_t;
   s_t a;
   for (genvar i = 0; i < 1; i++) begin : g
      assign a = '0;
   end
endmodule
