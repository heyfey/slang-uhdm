// § tfArgDpiNoWrite146v
package p;
typedef enum logic [1:0] {A, B, C} e_t;
function automatic int f(e_t z);
  return int'(z);
endfunction
import "DPI-C" pure function int cf(input e_t x);
endpackage
module top(output int o);
  assign o = p::f(p::A);
endmodule
