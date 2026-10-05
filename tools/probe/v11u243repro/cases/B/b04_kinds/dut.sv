// § unitImpPaRhsOwnCopy243
// real, string, localparam and a parameter read by another, imported through $unit
package p;
  parameter real R = 1.5;
  parameter string S = "ab";
  localparam L = 'h10;
  parameter M = L + 'h1;
  parameter int N = 7;
  parameter time T = 10;
endpackage
import p::*;
class env;
  int v;
endclass
module top;
  env e;
endmodule
