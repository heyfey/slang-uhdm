// § tfArgTypedefLastWriter146
package p;
  typedef enum int {A, B} e_t;
  import "DPI-C" function int cf(input e_t x);
endpackage
module top(output int o);
  import p::*;
  initial o = cf(A);
endmodule
