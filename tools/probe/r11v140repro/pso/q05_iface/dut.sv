// § elabPatOperandRefSpan140
package foo_pkg;
  parameter int VALUE_TEMP = '{default: 1};
endpackage
interface ifc();
  import foo_pkg::*;
  parameter int VALUE = VALUE_TEMP + 2;
  logic [VALUE-1:0] d;
endinterface
module top; ifc i(); endmodule
