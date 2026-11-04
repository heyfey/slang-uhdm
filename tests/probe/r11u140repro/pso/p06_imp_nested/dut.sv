// § elabPatOperandRefSpan140
package foo_pkg;
  parameter int VALUE_TEMP = '{default: 1};
endpackage
module top();
  import foo_pkg::*;
  parameter int VALUE = (VALUE_TEMP + 2) * 3;
endmodule
