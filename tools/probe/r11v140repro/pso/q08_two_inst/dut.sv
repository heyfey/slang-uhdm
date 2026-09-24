// § elabPatOperandRefSpan140
package foo_pkg;
  parameter int VALUE_TEMP = '{default: 1};
endpackage
module sub();
  import foo_pkg::*;
  parameter int VALUE = VALUE_TEMP * 3;
endmodule
module top(); sub a(); sub #(.VALUE(4)) b(); endmodule
