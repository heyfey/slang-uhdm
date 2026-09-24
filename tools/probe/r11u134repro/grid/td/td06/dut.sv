// § defNetTypedefEndWrite134
module top;
   typedef enum logic [1:0] {A, B, C} e_t;
   e_t s[3];
   logic [1:0] o;
   assign o = s[2];
endmodule
