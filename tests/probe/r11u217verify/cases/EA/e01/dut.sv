// § pkgEnumAliasListingParent212 — r11u217 e01: a package alias of an enum typedef read by TWO importing modules (a wildcard import and an explicit import) as a port type and a variable type
package p;
  typedef enum logic [1:0] { A, B, C } e_t;
  typedef e_t f_t;
endpackage
module m1 import p::*; (input f_t i, output logic o);
  assign o = i == B;
endmodule
module dut (input logic [1:0] i, output logic o, output logic q);
  import p::f_t;
  f_t v;
  assign v = p::e_t'(i);
  assign q = v == p::C;
  m1 u (.i(v), .o(o));
endmodule
