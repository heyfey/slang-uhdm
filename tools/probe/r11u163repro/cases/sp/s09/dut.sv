// § elabAggFoldYCopyDefNamed163
package pkg;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } s_t;
  localparam s_t X = 16'h00ff;
endpackage
module dut import pkg::*; #(parameter s_t P = X) (output logic [7:0] o);
  assign o = P.a;
endmodule
module top(output logic [7:0] o); dut d(.o(o)); endmodule
