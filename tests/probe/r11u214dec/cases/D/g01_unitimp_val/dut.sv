// § unitImportCopyValueFollowsPkg214 — a $unit-scope import hoists package parameters into the design listing (Scoreboard N0691/N0692: UVM_LARGE_STRING INT vs UINT)
package p;
  parameter W = 120;
  parameter N = 16;
  parameter S = W*8-1;
  parameter L = W*N*8-1;
  parameter int unsigned U = 5;
  localparam logic [7:0] B8 = 8'hA5;
endpackage
import p::*;
module top(output int o);
  assign o = 0;
endmodule
