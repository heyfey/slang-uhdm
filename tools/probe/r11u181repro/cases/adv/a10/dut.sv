// § rootPathFullNameByChain181 § rootNetPathOwnNames181 — break hunt: a macro-born $root path from an included file, a $root path in an elaborated continuous-assignment clone with an operation, a $root path as an inc/dec operand
`include "a10_inc.svh"
module top; logic [3:0] v; int i; sub u(); endmodule
module sub;
  logic [3:0] w, x;
  assign w = `RV & 4'hF;
  assign x = $root.top.v ^ w;
  initial $root.top.i++;
endmodule
