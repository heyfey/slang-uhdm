// § elabAggFoldYCopyDefNamed163
package pkg;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } s_t;
  localparam s_t X = 16'h00ff;
endpackage
interface bus_if import pkg::*; #(parameter s_t P = X) ();
  logic [7:0] a;
  assign a = P.b;
endinterface
module top(); bus_if b(); endmodule
