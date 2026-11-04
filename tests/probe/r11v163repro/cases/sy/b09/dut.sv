// § elabAggFoldYCopyDefNamed163
package pkg;
  typedef struct packed { logic [7:0] k; logic [7:0] m; } init_t;
  localparam init_t InitDefault = 16'hA5C3;
endpackage
module leaf #(parameter logic [7:0] V = 0)(); endmodule
module dut import pkg::*; ();
  localparam init_t Init = InitDefault;
  leaf #(.V(Init.k)) l();
endmodule
module top; dut d(); endmodule
