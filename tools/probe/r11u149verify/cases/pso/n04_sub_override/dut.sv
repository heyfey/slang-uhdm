// § elabPatOperandRefSpan140
package foo_pkg;
  parameter int VT = '{default: 3};
endpackage
module sub #(parameter int A = 0) ();
endmodule
module top();
  import foo_pkg::*;
  parameter int VALUE = VT - 1;
  sub #(.A(VALUE)) u();
endmodule
