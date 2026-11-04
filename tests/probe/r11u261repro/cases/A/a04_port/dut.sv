// § sysArgFoldTsUnitName261
package hp;
  parameter int NumRound = 64;
  parameter logic [7:0] W8 = 8'd12;
endpackage
module sha2 import hp::*; (input logic [$clog2(NumRound)-1:0] sel, output logic o);
  assign o = sel[0];
endmodule
module top;
  logic [5:0] s; logic o;
  sha2 u (.sel(s), .o(o));
endmodule
