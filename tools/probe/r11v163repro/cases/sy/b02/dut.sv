// § elabAggFoldYCopyDefNamed163
package pkg;
  typedef struct packed { logic [7:0] k; logic [7:0] m; } init_t;
  localparam init_t InitDefault = 16'hA5C3;
endpackage
module dut import pkg::InitDefault, pkg::init_t; #(parameter init_t Init = InitDefault) (output logic [7:0] o);
  assign o = Init.k;
endmodule
module top(output logic [7:0] o1); dut d(.o(o1)); endmodule
