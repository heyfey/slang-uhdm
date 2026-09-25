// § elabPatOperandRefSpan140
package foo_pkg;
  parameter int VT = '{default: 3};
endpackage
module top();
  import foo_pkg::*;
  localparam int VALUE = (VT > 2) ? 5 : 6;
endmodule
