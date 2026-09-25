// § elabAggFoldYCopyDefNamed163
package pkg;
  typedef struct packed { logic [7:0] k; logic [7:0] m; } init_t;
  localparam init_t InitDefault = 16'hA5C3;
endpackage
module dut import pkg::*; #(parameter init_t Init = InitDefault) (output logic [7:0] o);
  assign o = Init.k;
endmodule
module dut2 import pkg::*; #(parameter init_t Init = InitDefault) (output logic [7:0] o);
  assign o = Init.m;
endmodule
module top(output logic [7:0] o1, o2); dut d(.o(o1)); dut2 e(.o(o2)); endmodule
