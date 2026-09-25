// § elabAggFoldYCopyDefNamed163
package pkg;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } s_t;
  localparam s_t X = 16'h00ff;
endpackage
module dut import pkg::*; ();
  localparam s_t P = X;
  logic [7:0] o;
  assign o = P.a;
endmodule
module top(); dut d(); endmodule
