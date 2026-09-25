// § elabAggFoldYCopyDefNamed163
package pkg;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } s_t;
  localparam s_t X = '1;
endpackage
module leaf #(parameter logic [7:0] V = 0)();
endmodule
module dut import pkg::*; #(parameter s_t P = X) ();
  leaf #(.V(P.b)) l();
endmodule
module top(); dut d1(); dut d2(); endmodule
