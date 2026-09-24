// § elabPatOperandRefSpan140
package foo_pkg;
  parameter int VALUE_TEMP = '{default: 1};
endpackage
module bottom();
  parameter int VALUE = 8;
endmodule
module top();
  import foo_pkg::*;
  parameter int VALUE = VALUE_TEMP + 2;
  bottom #(.VALUE(VALUE)) u();
endmodule
