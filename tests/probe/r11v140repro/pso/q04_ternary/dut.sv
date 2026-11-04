// § elabPatOperandRefSpan140
package foo_pkg;
  parameter int VALUE_TEMP = '{default: 1};
endpackage
module top #(parameter bit C = 1) ();
  import foo_pkg::*;
  parameter int VALUE = C ? VALUE_TEMP : 2;
endmodule
