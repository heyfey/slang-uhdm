// § elabAggFoldYCopyDefNamed163
package pkg;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } s_t;
  localparam s_t X = '{a: 8'd1, b: 8'd2};
endpackage
module leaf #(parameter logic [7:0] V = 0)();
endmodule
module dut import pkg::*; #(parameter s_t P = X) ();
  leaf #(.V(P.a)) l();
endmodule
module top(); dut d(); endmodule
