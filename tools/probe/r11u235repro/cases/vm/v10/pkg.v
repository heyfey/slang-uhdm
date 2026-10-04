// § vlogEnumBaseKwSpan235
package p;
  typedef enum bit [2:0] {A, B, C} e_t;
  typedef enum logic [3:0] {D, E} f_t;
endpackage
module top(output [2:0] o);
  p::e_t x;
  assign o = x;
endmodule
