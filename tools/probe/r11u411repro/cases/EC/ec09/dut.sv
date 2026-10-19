// § pkgAliasCastTargetTs411
module top (output [31:0] o);
  typedef int i_t;
  parameter i_t P = i_t'(3);
  assign o = P;
endmodule
