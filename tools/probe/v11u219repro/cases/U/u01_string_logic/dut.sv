// § unitImportCopyValueFollowsPkg214 § unitImportCopyOwnTsRef214 — $unit-imported string, logic-vector, real-free arithmetic and unsigned parameters, read by a module
package p;
  parameter string S = "abc";
  parameter logic [7:0] L = 8'h3C;
  parameter W = 7;
  parameter M = W * 3 - 1;
  parameter int unsigned U = 9;
  localparam bit [3:0] LB = 4'b1010;
endpackage
import p::*;
module top(output int o, output logic [7:0] ol);
  assign o = M + U + LB;
  assign ol = L;
endmodule
