// law tfArgDpiExportFirstNoWrite153v
module top(output int o);
typedef enum logic [1:0] {A, B, C} e_t;
export "DPI-C" function f;
function automatic int f(e_t z);
  return int'(z);
endfunction
  assign o = f(A);
endmodule
