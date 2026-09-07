// v196 arm X12 — a module whose OWN parameter SHADOWS a wildcard-imported
// package parameter name, in a file carrying a file-scope import.
import quarryPkg::*;
module xShadow(input int a, output int b);
  parameter int QUARRY_DEPTH = 999;   // shadows quarryPkg::QUARRY_DEPTH
  parameter int X12_OWN = 5;
  assign b = a + QUARRY_DEPTH + X12_OWN;
endmodule
