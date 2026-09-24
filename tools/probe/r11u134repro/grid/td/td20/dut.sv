// § defNetTypedefEndWrite134
module top;
   typedef struct packed {
      logic [7:0] x;
   } s_t;
   s_t a[2];
   s_t b = 8'h5;
   logic [7:0] o;
   assign o = a[1].x ^ b.x;
endmodule
