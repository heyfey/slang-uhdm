// r10v190 arm 5, file 2 — the enum-base typedefs, in a LATER file.
// Cells: a cross-file parameter bound, a cross-file localparam bound, a
// compilation-unit ($unit) typedef, and the same typedef used by TWO enums.
typedef bit [pv5_a::AW-1 : 0] t_unit5;               // $unit home
typedef enum t_unit5 { u5_a = 0, u5_b = 1 } e_unit5;

package pv5_b;
  import pv5_a::*;
  typedef bit [pv5_a::AW-1 : 0] t_x5;
  typedef enum t_x5 { x5_a = 0, x5_b = 1 } e_x5_one;
  typedef enum t_x5 { y5_a = 0, y5_b = 1 } e_x5_two;   // same base, 2nd enum

  typedef logic [pv5_a::AL : 1] t_l5;
  typedef enum t_l5 { l5_a = 0, l5_b = 1 } e_l5;
endpackage

module v190_5_xfile;
  e_unit5      v0;
  pv5_b::e_x5_one v1;
  pv5_b::e_x5_two v2;
  pv5_b::e_l5     v3;
  initial begin
    v0 = u5_b; v1 = pv5_b::x5_b; v2 = pv5_b::y5_b; v3 = pv5_b::l5_b;
  end
endmodule
