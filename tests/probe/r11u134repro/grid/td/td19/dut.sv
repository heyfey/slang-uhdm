// § defNetTypedefEndWrite134
module top;
   typedef struct {
      logic [7:0] x;
      int y;
   } s_t;
   s_t a[2];
   initial a[0].y = 1;
endmodule
