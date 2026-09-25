// § elabPatOperandRefSpan140
package foo_pkg;
  parameter int VT = '{default: 3};
endpackage
module top();
  import foo_pkg::*;
  parameter int VALUE = (VT + 1) * 2;
endmodule
