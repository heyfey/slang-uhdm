// law tfArgDpiExportFirstNoWrite153v (control)
package p;
typedef enum logic [1:0] {A, B, C} e_t;
function automatic int f(e_t z);
  return int'(z);
endfunction
export "DPI-C" function f;
endpackage
module top(output int o);
  assign o = p::f(p::A);
endmodule
