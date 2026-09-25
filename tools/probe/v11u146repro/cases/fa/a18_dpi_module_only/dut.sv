// § tfArgDpiNoWrite146v
module top(output int o);
  typedef enum int {A, B} e_t;
  import "DPI-C" function int cf(input e_t x);
  initial o = cf(A);
endmodule
