// § contAssignLhsTsUnparented134
module top;
   localparam int W = 4;
   typedef struct packed {
      logic [W-1:0] x;
      logic y;
   } s_t;
   s_t a;
   assign a = '0;
endmodule
