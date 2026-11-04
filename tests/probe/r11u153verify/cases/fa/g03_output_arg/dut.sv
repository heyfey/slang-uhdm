// § tfArgTypedefLastWriter146
package p;
typedef enum logic [1:0] {A, B, C} e_t;
function automatic void f(input int i, output e_t x);
  x = e_t'(i);
endfunction
endpackage
module top(output int o);
  assign o = 0;
endmodule
