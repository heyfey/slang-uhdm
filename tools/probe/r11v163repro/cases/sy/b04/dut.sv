// § elabAggFoldYCopyDefNamed163
package pkg;
  typedef struct packed { logic [7:0] k; logic [7:0] m; } init_t;
  localparam init_t InitDefault = 16'hA5C3;
endpackage
module leaf #(parameter logic [7:0] V = 0)(); endmodule
module mid import pkg::*; #(parameter init_t Init = InitDefault) ();
  leaf #(.V(Init.m)) l();
endmodule
module dut; mid m1(); endmodule
module top; dut d(); dut d2(); endmodule
