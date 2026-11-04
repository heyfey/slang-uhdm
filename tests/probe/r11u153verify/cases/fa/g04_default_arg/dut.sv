// § tfArgTypedefLastWriter146
package p;
typedef enum logic [1:0] {A, B, C} e_t;
function automatic int f(e_t x = B);
  return int'(x);
endfunction
endpackage
module top(output int o);
  assign o = p::f();
endmodule
