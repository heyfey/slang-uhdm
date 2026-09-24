// § contAssignLhsTsUnparented134
module top;
   typedef enum logic [1:0] {A, B, C} e_t;
   e_t s;
   assign s = B;
endmodule
