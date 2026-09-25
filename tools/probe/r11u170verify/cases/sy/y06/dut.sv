// § elabAggFoldYCopyDefNamed163
package pkg;
  parameter int Width = 32;
  typedef logic [Width-1:0] key_t;
  typedef struct packed { key_t key; logic [7:0] tag; } init_t;
  localparam init_t InitDefault = '1;
endpackage
module foo #(parameter logic [31:0] ResetValue = '0) (output logic [31:0] o); assign o = ResetValue; endmodule
module dut import pkg::*; #(parameter init_t Init = InitDefault) (output logic [31:0] o [2]);
  for (genvar g = 0; g < 2; g++) begin : G
    foo #(.ResetValue(Init.key)) f (.o(o[g]));
  end
endmodule
module top (output logic [31:0] o [2]); dut d(.o(o)); endmodule
