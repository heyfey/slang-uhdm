// § elabAggFoldYCopyDefNamed163
package pkg;
  parameter int Width = 16;
  typedef logic [Width-1:0] key_t;
  typedef struct packed { key_t key; } init_t;
  localparam init_t InitDefault = '0;
endpackage
module foo #(parameter logic [15:0] ResetValue = '1) (output logic [15:0] o); assign o = ResetValue; endmodule
module dut import pkg::*; #(parameter init_t Init = InitDefault) (output logic [15:0] o, output logic [15:0] p);
  foo #(.ResetValue(Init.key)) f (.o(o));
  foo #(.ResetValue(Init.key ^ 16'h00FF)) g (.o(p));
endmodule
module top (output logic [15:0] o, output logic [15:0] p); dut d(.o(o), .p(p)); endmodule
