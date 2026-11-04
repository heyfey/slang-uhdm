// § tfArgTypedefLastWriter146
module top(output int o);
  typedef enum int {A, B} e_t;
  import "DPI-C" function int cf(input e_t x);
  function automatic int g(e_t y); return int'(y); endfunction
  initial o = g(A);
endmodule
