// § pkgEnumCastTargetTs411
module top (output [31:0] o);
  typedef enum { A, B, C } e_t;
  parameter e_t P = e_t'(1);
  assign o = P;
endmodule
