// § elabPatOperandRefSpan140
package foo_pkg;
  parameter int VALUE_TEMP = '{default: 1};
endpackage
module top();
  localparam int T = '{default: 1};
  parameter int VALUE = T + 2;
endmodule
