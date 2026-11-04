// § defNetTypedefEndWrite134
// § defNetTypedefArrayShares134
module top;
   typedef struct packed {
      logic [7:0] x;
   } s_t;
   var s_t a[2];
   logic [7:0] o;
   assign o = a[1].x;
endmodule
