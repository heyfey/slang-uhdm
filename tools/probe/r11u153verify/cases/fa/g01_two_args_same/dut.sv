// § tfArgTypedefLastWriter146
package p;
typedef enum logic [1:0] {A, B, C} e_t;
function automatic int f(e_t x, e_t y);
  return int'(x) + int'(y);
endfunction
endpackage
module top(output int o);
  assign o = p::f(p::A, p::B);
endmodule
