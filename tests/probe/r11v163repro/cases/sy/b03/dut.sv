// § elabAggFoldYCopyDefNamed163
package pkg;
  typedef union packed { logic [15:0] k; logic [15:0] m; } init_t;
  localparam init_t InitDefault = 16'hA5C3;
endpackage
module dut import pkg::*; #(parameter init_t Init = InitDefault) (output logic [15:0] o);
  assign o = Init.k;
endmodule
module top(output logic [15:0] o1); dut d(.o(o1)); endmodule
