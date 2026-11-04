// § pkgUnbasedParamElab401
package p;
  typedef enum logic [3:0] { e_a = 4'b0000, e_b = 4'b0001 } e_t;
  localparam lvl0 = '0;
  localparam lvl1 = lvl0 | (1 << e_b);
endpackage
module top; endmodule
