// § defNetTypedefEndWrite134
// § defNetTypedefArrayShares134
module top;
   typedef struct packed {
      logic [7:0] x;
      logic y;
   } s_t;
   s_t a[4];
   s_t b[2:0];
   s_t c;
   assign c = a[1] ^ b[2];
endmodule
