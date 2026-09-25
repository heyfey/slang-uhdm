// § tfArgTypedefLastWriter146 law tfArgDpiExportFirstNoWrite153v
package p;
typedef enum logic [1:0] {A, B, C} e_t;
export "DPI-C" function f;
function automatic int f(e_t z);
  return int'(z);
endfunction
endpackage
module top(output int o);
  assign o = p::f(p::A);
endmodule
