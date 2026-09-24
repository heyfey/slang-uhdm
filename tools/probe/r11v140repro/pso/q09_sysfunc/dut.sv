// § elabPatOperandRefSpan140
package foo_pkg;
  parameter int VALUE_TEMP = '{default: 1};
endpackage
module top();
  import foo_pkg::*;
  parameter int VALUE = $clog2(VALUE_TEMP + 7);
endmodule
