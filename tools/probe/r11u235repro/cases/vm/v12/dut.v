// § vlogEnumBaseKwSpan235
module top(output [2:0] o);
  typedef enum bit   [2:0]   {A, B, C} e_t;
  typedef enum bit[1:0]{P, Q} f_t;
  e_t x;
  assign o = x;
endmodule
