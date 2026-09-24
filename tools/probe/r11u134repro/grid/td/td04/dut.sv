// § defNetTypedefEndWrite134
module top;
   typedef struct packed {
      logic [3:0] x;
      logic [1:0] y;
   } s_t;
   s_t a = '{x: 4'h3, y: 2'b01};
   logic [3:0] o;
   assign o = a.x;
endmodule
