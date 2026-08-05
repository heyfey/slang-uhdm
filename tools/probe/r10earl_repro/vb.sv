// r10earl10 control for va.sv row D: the SAME qualified package VECTOR
// typedef at MODULE scope, no generate anywhere.  If the `logic_typespec
// 'vl_t'` mismatch reproduces here it is independent of
// § defGenQualTypedefDecl.
package vbp;
  typedef logic [7:0] vl_t;
  typedef struct packed { logic [3:0] a; } vs_t;
endpackage

module vb (input logic clk_i, output logic [7:0] o);
  vbp::vl_t mv;
  vbp::vs_t ms;
  assign o = mv;
endmodule
