// § elabPatOperandRefSpan140
package foo_pkg;
  parameter int VALUE_TEMP = '{default: 1};
endpackage
module top();
  parameter int VALUE = foo_pkg::VALUE_TEMP + 2;
endmodule
