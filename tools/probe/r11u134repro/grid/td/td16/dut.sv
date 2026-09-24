// § defNetTypedefEndWrite134
// § defNetTypedefArrayShares134
module top;
   typedef struct packed {
      logic [7:0] x;
   } s_t;
   s_t a[4], b;
   assign b = a[0];
endmodule
