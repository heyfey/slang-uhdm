// § sysArgFoldTsUnitName261
package hp;
  parameter int NumRound = 64;
  parameter logic [7:0] W8 = 8'd12;
endpackage
module sha2 import hp::*; (input logic clk, output logic [7:0] o);
  typedef struct packed { logic [$clog2(NumRound)-1:0] a; logic b; } s_t;
  s_t s;
  assign o = s;
endmodule
module top;
  logic [7:0] o;
  sha2 u (.clk(1'b0), .o(o));
endmodule
