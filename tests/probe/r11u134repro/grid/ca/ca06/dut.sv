// § contAssignLhsTsUnparented134
module top;
   typedef struct packed {
      logic [3:0] x;
      logic y;
   } s_t;
   s_t a;
   assign a.x = 4'h1;
   assign a.y = 1'b0;
endmodule
