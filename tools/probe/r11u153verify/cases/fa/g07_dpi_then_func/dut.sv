// § tfArgDpiNoWrite146v
package p;
typedef enum logic [1:0] {A, B, C} e_t;
import "DPI-C" context function int cf(input e_t x);
import "DPI-C" task ct(input e_t y);
function automatic int f(e_t z);
  return int'(z);
endfunction
endpackage
module top(output int o);
  assign o = p::f(p::A);
endmodule
