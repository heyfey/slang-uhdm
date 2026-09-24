// § defNetTypedefEndWrite134
module top;
   typedef union packed {
      logic [7:0] b;
      logic [7:0] c;
   } u_t;
   u_t m[2];
   logic [7:0] o;
   assign o = m[1].b;
endmodule
