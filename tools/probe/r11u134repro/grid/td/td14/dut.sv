// § defNetTypedefEndWrite134
// § defNetTypedefArrayShares134
module sub;
   typedef struct packed {
      logic [7:0] x;
   } s_t;
   s_t a[2];
   s_t b;
   assign b = a[0];
endmodule
module top;
   sub u();
endmodule
