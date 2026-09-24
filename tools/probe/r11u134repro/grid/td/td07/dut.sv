// § defNetTypedefEndWrite134
module top;
   typedef enum logic [1:0] {A, B, C} e_t;
   e_t s = B;
   logic [1:0] o;
   assign o = s;
endmodule
