// § elabPatOperandRefSpan140
package foo_pkg;
  parameter int VALUE_TEMP = '{default: 1};
endpackage
module top();
  import foo_pkg::*;
  parameter int VALUE = 3 +
                        VALUE_TEMP;
endmodule
