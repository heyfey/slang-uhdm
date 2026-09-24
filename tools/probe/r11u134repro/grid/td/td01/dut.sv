// § defNetTypedefEndWrite134
// § defNetTypedefArrayShares134
module top;
   typedef struct packed {
      logic [7:0] source;
   } tl_h2d_t;
   tl_h2d_t a[4];
   tl_h2d_t b;
   logic c = a[0].source[6 -: 2];
endmodule
