// § defNetTypedefEndWrite134
// § defNetTypedefArrayShares134
module top;
   typedef struct packed {
      logic [7:0] x;
   } s_t;
   s_t [1:0] a;
   s_t b[2];
   assign b[0] = a[0];
endmodule
