// § elabAggFoldYCopyDefNamed163
package pkg;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } sub_t;
  typedef struct packed { sub_t k; logic [7:0] m; } init_t;
  localparam init_t InitDefault = 16'hA5C3;
endpackage
module leaf #(parameter logic [3:0] V = 0)(); endmodule
module dut import pkg::*; #(parameter init_t Init = InitDefault) ();
  leaf #(.V(Init.k.b)) l();
endmodule
module top; dut d(); endmodule
